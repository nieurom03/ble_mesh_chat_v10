import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/app_localizations.dart';
import 'l10n/l10n.dart';
import 'pages/chat_page.dart';
import 'pages/chats_tab.dart';
import 'pages/network_tab.dart';
import 'pages/nodes_tab.dart';
import 'pages/settings_tab.dart';
import 'services/ble_chat_v10.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MeshChatApp());
}

// ─────────────────────────────────────────────
//  Root app
// ─────────────────────────────────────────────

class MeshChatApp extends StatefulWidget {
  const MeshChatApp({super.key});

  /// Allows any descendant to change the app locale.
  static void setLocale(BuildContext context, Locale? locale) {
    context.findAncestorStateOfType<_MeshChatAppState>()?.setLocale(locale);
  }

  @override
  State<MeshChatApp> createState() => _MeshChatAppState();
}

class _MeshChatAppState extends State<MeshChatApp> {
  // null = follow system locale
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('app_locale');
    if (code != null && mounted) {
      setState(() => _locale = Locale(code));
    }
  }

  void setLocale(Locale? locale) => setState(() => _locale = locale);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BLE Mesh Chat',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      locale: _locale,
      localizationsDelegates: const [
        AppL10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi'),
        Locale('en'),
      ],
      home: const HomePage(),
    );
  }
}

// ─────────────────────────────────────────────
//  Home — manages BLE controller lifecycle,
//  stream subscriptions, and tab navigation.
// ─────────────────────────────────────────────

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final BleChatV10Controller ble;
  StreamSubscription? _requestSub;
  StreamSubscription? _messageSub;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    ble = BleChatV10Controller();
    ble.addListener(_rebuild);

    // Subscribe BEFORE init/startAdvertising so no broadcast events are lost.
    _requestSub = ble.incomingRequests.listen(_onIncomingRequest);
    _messageSub = ble.incomingMessages.listen(_onIncomingMessage);

    // Defer BLE init until the first frame so Navigator/Scaffold are mounted.
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    await ble.init();
    await ble.startAdvertising();
    if (mounted) setState(() {});
  }

  void _rebuild() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  // ── Incoming connection request dialog ──────────────────────────

  void _onIncomingRequest(IncomingConnectionRequest request) {
    if (!mounted) return;
    _showConnectionRequestDialog(request);
  }

  Future<void> _showConnectionRequestDialog(
    IncomingConnectionRequest request,
  ) async {
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ConnectionRequestDialog(request: request),
    );
    await ble.respondToIncomingRequest(
      request: request,
      accepted: accepted == true,
    );
    if (accepted == true && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatPage(ble: ble, peerName: request.remoteName),
        ),
      );
    }
  }

  // ── In-app message notification (snackbar) ──────────────────────

  void _onIncomingMessage(V10ChatMessage message) {
    if (!mounted || ble.isChatOpen) return;
    _showMessageSnackBar(message);
  }

  void _showMessageSnackBar(V10ChatMessage message) {
    final l = context.l10n;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.gray900,
          margin: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          content: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.indigo600,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: const Icon(
                  Icons.chat_bubble_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ble.connectedName ?? l.newMessage,
                      style: AppTextStyle.semibold.copyWith(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      message.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.sm.copyWith(
                        color: Colors.white.withAlpha(180),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          action: SnackBarAction(
            label: l.snackView,
            textColor: AppColors.indigo100,
            onPressed: () {
              final peer = ble.connectedName;
              if (peer == null || !mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatPage(ble: ble, peerName: peer),
                ),
              );
            },
          ),
          duration: const Duration(seconds: 4),
        ),
      );
  }

  // ── Build ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: SafeArea(
        child: IndexedStack(
          index: _tab,
          children: [
            ChatsTab(ble: ble),
            NodesTab(ble: ble),
            NetworkTab(ble: ble),
            SettingsTab(ble: ble),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNav(
        current: _tab,
        unreadCount: ble.unreadCount,
        onTap: (i) => setState(() => _tab = i),
      ),
    );
  }

  @override
  void dispose() {
    _requestSub?.cancel();
    _messageSub?.cancel();
    ble.removeListener(_rebuild);
    ble.dispose();
    super.dispose();
  }
}

// ─────────────────────────────────────────────
//  Bottom navigation bar
// ─────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int current;
  final int unreadCount;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.current,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.gray200)),
      ),
      child: NavigationBar(
        selectedIndex: current,
        onDestinationSelected: onTap,
        destinations: [
          NavigationDestination(
            icon: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text('$unreadCount'),
              child: const Icon(Icons.chat_bubble_outline_rounded),
            ),
            selectedIcon: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text('$unreadCount'),
              child: const Icon(Icons.chat_bubble_rounded),
            ),
            label: l.navChats,
          ),
          NavigationDestination(
            icon: const Icon(Icons.devices_outlined),
            selectedIcon: const Icon(Icons.devices_rounded),
            label: l.navNodes,
          ),
          NavigationDestination(
            icon: const Icon(Icons.hub_outlined),
            selectedIcon: const Icon(Icons.hub_rounded),
            label: l.navNetwork,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings_rounded),
            label: l.navSettings,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Connection request dialog
// ─────────────────────────────────────────────

class _ConnectionRequestDialog extends StatelessWidget {
  final IncomingConnectionRequest request;
  const _ConnectionRequestDialog({required this.request});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.indigo100,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: const Icon(
                Icons.bluetooth_connected_rounded,
                color: AppColors.indigo600,
                size: 28,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l.connectionRequestTitle,
              style: AppTextStyle.lg.copyWith(color: AppColors.gray900),
            ),
            const SizedBox(height: AppSpacing.xs),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: AppTextStyle.base.copyWith(color: AppColors.gray600),
                children: [
                  TextSpan(
                    text: request.remoteName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray900,
                    ),
                  ),
                  TextSpan(text: l.connectionRequestBody),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.gray600,
                      side: const BorderSide(color: AppColors.gray200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(l.connectionRequestReject),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(l.connectionRequestAccept),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

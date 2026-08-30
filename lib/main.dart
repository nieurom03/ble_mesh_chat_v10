import 'dart:async';

import 'package:flutter/material.dart';

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

class MeshChatApp extends StatelessWidget {
  const MeshChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BLE Mesh Chat',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
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
                      ble.connectedName ?? 'Tin nhắn mới',
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
            label: 'Xem',
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
            label: 'Chats',
          ),
          const NavigationDestination(
            icon: Icon(Icons.devices_outlined),
            selectedIcon: Icon(Icons.devices_rounded),
            label: 'Nodes',
          ),
          const NavigationDestination(
            icon: Icon(Icons.hub_outlined),
            selectedIcon: Icon(Icons.hub_rounded),
            label: 'Network',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Cài đặt',
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
            // Icon
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
              'Yêu cầu kết nối',
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
                  const TextSpan(
                    text: ' muốn kết nối để chat qua BLE.',
                  ),
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
                    child: const Text('Từ chối'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Chấp nhận'),
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

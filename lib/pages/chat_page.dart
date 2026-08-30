import 'package:flutter/material.dart';

import '../services/ble_chat_v10.dart';
import '../theme/app_theme.dart';

class ChatPage extends StatefulWidget {
  final BleChatV10Controller ble;
  final String peerName;
  const ChatPage({super.key, required this.ble, required this.peerName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.ble.setChatOpen(true);
    widget.ble.addListener(_refresh);
  }

  void _refresh() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    if (_scroll.hasClients) {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    await widget.ble.sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.ble.messages;
    final connected = widget.ble.connected;

    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: _ChatAppBar(
        peerName: widget.peerName,
        connected: connected,
      ),
      body: Column(
        children: [
          // ── Message list ───────────────────────────────────────
          Expanded(
            child: messages.isEmpty
                ? _EmptyChat(peerName: widget.peerName)
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (_, i) {
                      final msg = messages[i];
                      final prevMine = i > 0 ? messages[i - 1].mine : null;
                      final showAvatar =
                          !msg.mine && (prevMine == null || prevMine);
                      return _MessageBubble(
                        message: msg,
                        showAvatar: showAvatar,
                        peerName: widget.peerName,
                      );
                    },
                  ),
          ),

          // ── Disconnected banner ────────────────────────────────
          if (!connected) const _DisconnectedBanner(),

          // ── Input bar ──────────────────────────────────────────
          _InputBar(
            controller: _input,
            enabled: connected,
            onSend: _send,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.ble.setChatOpen(false);
    widget.ble.removeListener(_refresh);
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }
}

// ── AppBar ───────────────────────────────────────────────────────────────────

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String peerName;
  final bool connected;
  const _ChatAppBar({required this.peerName, required this.connected});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          // Avatar
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: connected ? AppColors.indigo100 : AppColors.gray100,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Icon(
              Icons.person_rounded,
              size: 18,
              color: connected ? AppColors.indigo600 : AppColors.gray400,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                peerName,
                style: AppTextStyle.semibold.copyWith(
                  color: AppColors.gray900,
                  fontSize: 15,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: connected ? AppColors.green500 : AppColors.gray400,
                    ),
                  ),
                  Text(
                    connected ? 'Connected via BLE' : 'Disconnected',
                    style: AppTextStyle.xs.copyWith(
                      color: connected
                          ? AppColors.green700
                          : AppColors.gray400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Message bubble ───────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final V10ChatMessage message;
  final bool showAvatar;
  final String peerName;
  const _MessageBubble({
    required this.message,
    required this.showAvatar,
    required this.peerName,
  });

  String _fmt(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final mine = message.mine;
    return Padding(
      padding: EdgeInsets.only(
        top: 3,
        bottom: 3,
        left: mine ? 48 : 0,
        right: mine ? 0 : 48,
      ),
      child: Row(
        mainAxisAlignment:
            mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Peer avatar (only on first in a group)
          if (!mine)
            SizedBox(
              width: 28,
              child: showAvatar
                  ? Container(
                      width: 28,
                      height: 28,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: AppColors.indigo100,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 16,
                        color: AppColors.indigo600,
                      ),
                    )
                  : const SizedBox(width: 34),
            ),
          if (!mine) const SizedBox(width: 6),

          // Bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm + 2,
              ),
              decoration: BoxDecoration(
                color: mine ? AppColors.indigo600 : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppRadius.lg),
                  topRight: const Radius.circular(AppRadius.lg),
                  bottomLeft: Radius.circular(mine ? AppRadius.lg : 4),
                  bottomRight: Radius.circular(mine ? 4 : AppRadius.lg),
                ),
                border: mine
                    ? null
                    : Border.all(color: AppColors.gray200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: mine
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: AppTextStyle.base.copyWith(
                      color: mine ? Colors.white : AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _fmt(message.time),
                    style: AppTextStyle.xs.copyWith(
                      color: mine
                          ? Colors.white.withAlpha(160)
                          : AppColors.gray400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty chat ───────────────────────────────────────────────────────────────

class _EmptyChat extends StatelessWidget {
  final String peerName;
  const _EmptyChat({required this.peerName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.indigo50,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: const Icon(
              Icons.waving_hand_rounded,
              size: 30,
              color: AppColors.indigo500,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Say hi to $peerName!',
            style: AppTextStyle.lg.copyWith(color: AppColors.gray700),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Tin nhắn gửi trực tiếp qua BLE,\nkhông qua internet.',
            style: AppTextStyle.bodyMuted,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Disconnected banner ───────────────────────────────────────────────────────

class _DisconnectedBanner extends StatelessWidget {
  const _DisconnectedBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      color: AppColors.amber100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.link_off_rounded, size: 15, color: AppColors.amber700),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Đã mất kết nối BLE',
            style: AppTextStyle.sm.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.amber700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Input bar ─────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;
  const _InputBar({
    required this.controller,
    required this.enabled,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                textInputAction: TextInputAction.send,
                onSubmitted: enabled ? (_) => onSend() : null,
                style: AppTextStyle.base.copyWith(color: AppColors.gray900),
                decoration: InputDecoration(
                  hintText: enabled ? 'Nhắn tin…' : 'Không có kết nối',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  filled: true,
                  fillColor: enabled ? AppColors.gray100 : AppColors.gray50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    borderSide: const BorderSide(
                      color: AppColors.indigo500,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            // Send button
            GestureDetector(
              onTap: enabled ? onSend : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: enabled ? AppColors.indigo600 : AppColors.gray200,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Icon(
                  Icons.send_rounded,
                  size: 18,
                  color: enabled ? Colors.white : AppColors.gray400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

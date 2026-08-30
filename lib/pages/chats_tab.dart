import 'package:flutter/material.dart';

import '../services/ble_chat_v10.dart';
import '../theme/app_theme.dart';
import '../widgets/edit_name_dialog.dart';
import '../widgets/status_badge.dart';
import 'chat_page.dart';

class ChatsTab extends StatelessWidget {
  final BleChatV10Controller ble;
  const ChatsTab({super.key, required this.ble});

  @override
  Widget build(BuildContext context) {
    final peer = ble.connectedName;
    final lastMsg = ble.messages.isNotEmpty ? ble.messages.last : null;

    return Column(
      children: [
        _ChatsHeader(ble: ble),
        const Divider(),
        Expanded(
          child: peer == null
              ? _EmptyChats(ble: ble)
              : _ConnectedChatsList(
                  ble: ble,
                  peer: peer,
                  lastMsg: lastMsg,
                ),
        ),
      ],
    );
  }
}

// ── Header ──────────────────────────────────────────────────────────────────

class _ChatsHeader extends StatelessWidget {
  final BleChatV10Controller ble;
  const _ChatsHeader({required this.ble});

  Future<void> _editName(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => EditNameDialog(initialName: ble.nodeName),
    );
    if (name != null && name.isNotEmpty) await ble.setNodeName(name);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BLE Mesh Chat',
                  style: AppTextStyle.xl.copyWith(color: AppColors.gray900),
                ),
                const SizedBox(height: 6),
                // Tên thiết bị — tap để đổi tên
                GestureDetector(
                  onTap: () => _editName(context),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ble.nodeName,
                        style: AppTextStyle.semibold.copyWith(
                          color: AppColors.indigo600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.edit_outlined,
                        size: 13,
                        color: AppColors.indigo500,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      StatusBadge(state: ble.bluetoothState),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Nút đổi tên
          _EditNameButton(onTap: () => _editName(context)),
        ],
      ),
    );
  }
}

class _EditNameButton extends StatelessWidget {
  final VoidCallback onTap;
  const _EditNameButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + 2,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.indigo50,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.indigo100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.badge_outlined, size: 15, color: AppColors.indigo600),
            const SizedBox(width: 4),
            Text(
              'Đổi tên',
              style: AppTextStyle.sm.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.indigo600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────

class _EmptyChats extends StatelessWidget {
  final BleChatV10Controller ble;
  const _EmptyChats({required this.ble});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.indigo50,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 36,
                color: AppColors.indigo500,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Chưa có cuộc trò chuyện',
              style: AppTextStyle.lg.copyWith(color: AppColors.gray800),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Vào tab Network để tìm và kết nối với điện thoại gần đây.',
              style: AppTextStyle.bodyMuted,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Connected chat entry ─────────────────────────────────────────────────────

class _ConnectedChatsList extends StatelessWidget {
  final BleChatV10Controller ble;
  final String peer;
  final dynamic lastMsg;
  const _ConnectedChatsList({
    required this.ble,
    required this.peer,
    required this.lastMsg,
  });

  String _fmt(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  void _openChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatPage(ble: ble, peerName: peer)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      children: [
        // ── Chat card ──────────────────────────────────────────────
        GestureDetector(
          onTap: () => _openChat(context),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.gray200),
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Avatar with online dot
                Stack(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.indigo100,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: AppColors.indigo600,
                        size: 26,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 13,
                        height: 13,
                        decoration: BoxDecoration(
                          color: AppColors.green500,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppSpacing.sm + 4),

                // Name + preview
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              peer,
                              style: AppTextStyle.semibold.copyWith(
                                color: AppColors.gray900,
                              ),
                            ),
                          ),
                          if (lastMsg != null)
                            Text(_fmt(lastMsg!.time), style: AppTextStyle.labelMuted),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        lastMsg != null
                            ? (lastMsg!.mine
                                  ? 'Bạn: ${lastMsg!.text}'
                                  : lastMsg!.text)
                            : 'Connected • direct BLE',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.bodyMuted,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),

                // Unread badge + disconnect
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (ble.unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.indigo600,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          '${ble.unreadCount}',
                          style: AppTextStyle.xs.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: ble.disconnect,
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.gray400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Open chat button ───────────────────────────────────────
        FilledButton.icon(
          onPressed: () => _openChat(context),
          icon: ble.unreadCount > 0
              ? Badge(
                  label: Text('${ble.unreadCount}'),
                  child: const Icon(Icons.chat_rounded, size: 18),
                )
              : const Icon(Icons.chat_rounded, size: 18),
          label: Text(
            ble.unreadCount > 0
                ? 'Mở chat  •  ${ble.unreadCount} tin mới'
                : 'Mở chat',
          ),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }
}

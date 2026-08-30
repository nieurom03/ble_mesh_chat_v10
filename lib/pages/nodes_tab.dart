import 'package:flutter/material.dart';

import '../services/ble_chat_v10.dart';
import '../theme/app_theme.dart';
import '../widgets/edit_name_dialog.dart';
import '../widgets/section_header.dart';

class NodesTab extends StatelessWidget {
  final BleChatV10Controller ble;
  const NodesTab({super.key, required this.ble});

  Future<void> _editName(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => EditNameDialog(initialName: ble.nodeName),
    );
    if (name != null && name.isNotEmpty) await ble.setNodeName(name);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeader(
          title: 'Nodes',
          subtitle: 'Thiết bị BLE đã kết nối / nhìn thấy',
        ),
        const Divider(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              // ── Local device card ─────────────────────────────────
              _NodeCard(
                icon: Icons.phone_android_rounded,
                iconBg: AppColors.indigo100,
                iconColor: AppColors.indigo600,
                title: ble.nodeName,
                subtitle: ble.nodeId,
                tag: ble.advertising ? 'Advertising' : 'Offline',
                tagColor: ble.advertising ? AppColors.green700 : AppColors.gray500,
                tagBg: ble.advertising ? AppColors.green100 : AppColors.gray100,
                trailing: GestureDetector(
                  onTap: () => _editName(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.indigo50,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.indigo100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.edit_outlined,
                          size: 14,
                          color: AppColors.indigo600,
                        ),
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
                ),
              ),

              // ── Connected peer card ───────────────────────────────
              if (ble.connected) ...[
                const SizedBox(height: AppSpacing.sm),
                _NodeCard(
                  icon: Icons.bluetooth_connected_rounded,
                  iconBg: AppColors.green100,
                  iconColor: AppColors.green700,
                  title: ble.connectedName ?? 'Peer',
                  subtitle: ble.connectedNodeId ?? '—',
                  tag: 'Connected',
                  tagColor: AppColors.green700,
                  tagBg: AppColors.green100,
                ),
              ],

              // ── Divider + legend ──────────────────────────────────
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: Text(
                  'Thiết bị của bạn sẽ xuất hiện với tên trên cho mọi người trong vùng BLE.',
                  style: AppTextStyle.bodyMuted,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NodeCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String tag;
  final Color tagColor;
  final Color tagBg;
  final Widget? trailing;

  const _NodeCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.tagColor,
    required this.tagBg,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: AppSpacing.sm + 4),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyle.semibold.copyWith(
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyle.xs.copyWith(
                    color: AppColors.gray400,
                    fontFamily: 'monospace',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                // Status tag
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: tagBg,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    tag,
                    style: AppTextStyle.xs.copyWith(
                      fontWeight: FontWeight.w600,
                      color: tagColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.sm),
            trailing!,
          ],
        ],
      ),
    );
  }
}

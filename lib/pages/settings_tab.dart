import 'package:flutter/material.dart';

import '../services/ble_chat_v10.dart';
import '../theme/app_theme.dart';
import '../widgets/edit_name_dialog.dart';
import '../widgets/section_header.dart';

class SettingsTab extends StatelessWidget {
  final BleChatV10Controller ble;
  const SettingsTab({super.key, required this.ble});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionHeader(
          title: 'Cài đặt',
          subtitle: 'Tùy chỉnh thiết bị và kết nối',
        ),
        const Divider(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              // ── Profile section ───────────────────────────────────
              _SectionLabel(label: 'Thiết bị của bạn'),
              _ProfileCard(ble: ble),
              const SizedBox(height: AppSpacing.lg),

              // ── BLE section ───────────────────────────────────────
              _SectionLabel(label: 'Bluetooth'),
              _BleCard(ble: ble),
              const SizedBox(height: AppSpacing.lg),

              // ── About section ─────────────────────────────────────
              _SectionLabel(label: 'Thông tin'),
              const _AboutCard(),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xs,
        bottom: AppSpacing.sm,
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyle.xs.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.gray400,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ── Settings card container ───────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              const Divider(height: 1, indent: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

// ── Settings tile ─────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        child: Row(
          children: [
            // Icon badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(AppRadius.sm + 2),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: AppSpacing.sm + 4),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyle.base.copyWith(
                      color: AppColors.gray900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(subtitle!, style: AppTextStyle.bodyMuted),
                  ],
                ],
              ),
            ),

            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.sm),
              trailing!,
            ] else if (onTap != null)
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.gray300,
              ),
          ],
        ),
      ),
    );
  }
}

// ── Profile card ──────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final BleChatV10Controller ble;
  const _ProfileCard({required this.ble});

  Future<void> _editName(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => EditNameDialog(initialName: ble.nodeName),
    );
    if (name != null && name.isNotEmpty) await ble.setNodeName(name);
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      children: [
        // Avatar + name row
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.indigo500, AppColors.indigo700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Center(
                  child: Text(
                    ble.nodeName.isNotEmpty
                        ? ble.nodeName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ble.nodeName,
                      style: AppTextStyle.semibold.copyWith(
                        fontSize: 16,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ble.nodeId,
                      style: AppTextStyle.xs.copyWith(
                        color: AppColors.gray400,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Edit name row
        _SettingsTile(
          icon: Icons.edit_rounded,
          iconColor: AppColors.indigo600,
          iconBg: AppColors.indigo50,
          title: 'Đổi tên hiển thị',
          subtitle: 'Tên sẽ được gửi đến người kết nối',
          onTap: () => _editName(context),
        ),
      ],
    );
  }
}

// ── BLE card ──────────────────────────────────────────────────────────────────

class _BleCard extends StatelessWidget {
  final BleChatV10Controller ble;
  const _BleCard({required this.ble});

  Color get _stateColor {
    switch (ble.bluetoothState.name) {
      case 'poweredOn':
        return AppColors.green500;
      case 'poweredOff':
        return AppColors.gray400;
      default:
        return AppColors.amber700;
    }
  }

  String get _stateLabel {
    switch (ble.bluetoothState.name) {
      case 'poweredOn':
        return 'Bật';
      case 'poweredOff':
        return 'Tắt';
      case 'unauthorized':
        return 'Chưa cấp quyền';
      case 'unsupported':
        return 'Không hỗ trợ';
      default:
        return ble.bluetoothState.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      children: [
        _SettingsTile(
          icon: Icons.bluetooth_rounded,
          iconColor: AppColors.indigo600,
          iconBg: AppColors.indigo50,
          title: 'Trạng thái Bluetooth',
          subtitle: null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _stateColor,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _stateLabel,
                style: AppTextStyle.sm.copyWith(
                  color: AppColors.gray600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        _SettingsTile(
          icon: Icons.settings_input_antenna_rounded,
          iconColor: AppColors.green700,
          iconBg: AppColors.green100,
          title: 'Quảng bá (Advertising)',
          subtitle: ble.advertising
              ? 'Đang phát tín hiệu BLE Mesh'
              : 'Không phát tín hiệu',
          trailing: Switch.adaptive(
            value: ble.advertising,
            activeColor: AppColors.indigo600,
            onChanged: (val) async {
              if (val) {
                await ble.startAdvertising();
              } else {
                await ble.stopAdvertising();
              }
            },
          ),
        ),
        _SettingsTile(
          icon: Icons.link_rounded,
          iconColor: ble.connected ? AppColors.green700 : AppColors.gray500,
          iconBg: ble.connected ? AppColors.green100 : AppColors.gray100,
          title: 'Trạng thái kết nối',
          subtitle: ble.connected
              ? 'Đang kết nối với ${ble.connectedName ?? "peer"}'
              : 'Chưa kết nối',
          trailing: ble.connected
              ? TextButton(
                  onPressed: ble.disconnect,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.red700,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                  ),
                  child: const Text('Ngắt', style: TextStyle(fontSize: 13)),
                )
              : null,
        ),
      ],
    );
  }
}

// ── About card ────────────────────────────────────────────────────────────────

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      children: [
        _SettingsTile(
          icon: Icons.info_outline_rounded,
          iconColor: AppColors.gray600,
          iconBg: AppColors.gray100,
          title: 'Phiên bản',
          subtitle: null,
          trailing: Text(
            'v10.0.0',
            style: AppTextStyle.sm.copyWith(color: AppColors.gray400),
          ),
        ),
        _SettingsTile(
          icon: Icons.bluetooth_searching_rounded,
          iconColor: AppColors.indigo600,
          iconBg: AppColors.indigo50,
          title: 'Giao thức',
          subtitle: 'BLE Mesh — direct P2P, không internet',
        ),
        _SettingsTile(
          icon: Icons.lock_outline_rounded,
          iconColor: AppColors.green700,
          iconBg: AppColors.green100,
          title: 'Bảo mật',
          subtitle: 'Tin nhắn chỉ truyền trong phạm vi BLE',
        ),
      ],
    );
  }
}

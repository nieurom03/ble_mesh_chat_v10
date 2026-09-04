import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/l10n.dart';
import '../main.dart';
import '../services/ble_chat_v10.dart';
import '../theme/app_theme.dart';
import '../widgets/edit_name_dialog.dart';
import '../widgets/section_header.dart';

class SettingsTab extends StatelessWidget {
  final BleChatV10Controller ble;
  const SettingsTab({super.key, required this.ble});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      children: [
        SectionHeader(title: l.settingsTitle, subtitle: l.settingsSubtitle),
        const Divider(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _SectionLabel(label: l.settingsSectionDevice),
              _ProfileCard(ble: ble),
              const SizedBox(height: AppSpacing.lg),
              _SectionLabel(label: l.settingsSectionBluetooth),
              _BleCard(ble: ble),
              const SizedBox(height: AppSpacing.lg),
              _SectionLabel(label: l.settingsSectionPrivacy),
              _PrivacyCard(ble: ble),
              const SizedBox(height: AppSpacing.lg),
              _SectionLabel(label: l.settingsSectionLanguage),
              const _LanguageCard(),
              const SizedBox(height: AppSpacing.lg),
              _SectionLabel(label: l.settingsSectionAbout),
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
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
    return SizedBox(
      width: double.infinity,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            children: [
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
    final l = context.l10n;
    return _SettingsCard(
      children: [
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
        _SettingsTile(
          icon: Icons.edit_rounded,
          iconColor: AppColors.indigo600,
          iconBg: AppColors.indigo50,
          title: l.settingsEditName,
          subtitle: l.settingsEditNameSub,
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

  Color _stateColor(String name) {
    switch (name) {
      case 'poweredOn':
        return AppColors.green500;
      case 'poweredOff':
        return AppColors.gray400;
      default:
        return AppColors.amber700;
    }
  }

  String _stateLabel(String name, AppL10n l) {
    switch (name) {
      case 'poweredOn':
        return l.btOn;
      case 'poweredOff':
        return l.btOff;
      case 'unauthorized':
        return l.btUnauthorized;
      case 'unsupported':
        return l.btUnsupported;
      default:
        return name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final stateName = ble.bluetoothState.name;
    return _SettingsCard(
      children: [
        _SettingsTile(
          icon: Icons.bluetooth_rounded,
          iconColor: AppColors.indigo600,
          iconBg: AppColors.indigo50,
          title: l.settingsBtStatus,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _stateColor(stateName),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _stateLabel(stateName, l),
                style: AppTextStyle.sm.copyWith(
                  color: AppColors.gray600,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        _SettingsTile(
          icon: Icons.settings_input_antenna_rounded,
          iconColor: AppColors.green700,
          iconBg: AppColors.green100,
          title: l.settingsAdvertising,
          subtitle: ble.advertising
              ? l.settingsAdvertisingOn
              : l.settingsAdvertisingOff,
          trailing: Switch.adaptive(
            value: ble.advertising,
            activeColor: AppColors.indigo600,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
          title: l.settingsConnection,
          subtitle: ble.connected
              ? l.settingsConnectedWith(ble.connectedName ?? 'peer')
              : null,
          trailing: ble.connected
              ? TextButton(
                  onPressed: ble.disconnect,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.red700,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    l.settingsDisconnect,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gray400,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l.settingsNotConnected,
                      style: AppTextStyle.sm.copyWith(
                        color: AppColors.gray600,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

// ── Language card ─────────────────────────────────────────────────────────────

class _LanguageCard extends StatefulWidget {
  const _LanguageCard();

  @override
  State<_LanguageCard> createState() => _LanguageCardState();
}

class _LanguageCardState extends State<_LanguageCard> {
  // null = system default
  String? _selected;

  static const _prefKey = 'app_locale';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey); // 'vi' | 'en' | null
    if (mounted) setState(() => _selected = saved);
  }

  Future<void> _pick(String? langCode) async {
    final prefs = await SharedPreferences.getInstance();
    if (langCode == null) {
      await prefs.remove(_prefKey);
    } else {
      await prefs.setString(_prefKey, langCode);
    }
    if (!mounted) return;
    setState(() => _selected = langCode);
    MeshChatApp.setLocale(context, langCode != null ? Locale(langCode) : null);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    final options = [
      (code: null, label: l.langSystemDefault, flag: '🌐'),
      (code: 'vi', label: l.langVietnamese, flag: '🇻🇳'),
      (code: 'en', label: l.langEnglish, flag: '🇬🇧'),
    ];

    return _SettingsCard(
      children: options.map((opt) {
        final selected = _selected == opt.code;
        return InkWell(
          onTap: () => _pick(opt.code),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 2,
            ),
            child: Row(
              children: [
                // Flag emoji
                Text(opt.flag, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: AppSpacing.sm + 4),
                // Label
                Expanded(
                  child: Text(
                    opt.label,
                    style: AppTextStyle.base.copyWith(
                      color: selected ? AppColors.indigo600 : AppColors.gray900,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                // Checkmark
                if (selected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.indigo600,
                    size: 20,
                  )
                else
                  const Icon(
                    Icons.circle_outlined,
                    color: AppColors.gray300,
                    size: 20,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── About card ────────────────────────────────────────────────────────────────

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return _SettingsCard(
      children: [
        _SettingsTile(
          icon: Icons.info_outline_rounded,
          iconColor: AppColors.gray600,
          iconBg: AppColors.gray100,
          title: l.settingsVersion,
          trailing: Text(
            'v10.0.0',
            style: AppTextStyle.sm.copyWith(color: AppColors.gray400),
          ),
        ),
        _SettingsTile(
          icon: Icons.bluetooth_searching_rounded,
          iconColor: AppColors.indigo600,
          iconBg: AppColors.indigo50,
          title: l.settingsProtocol,
          trailing: Text(
            'BLE Mesh',
            style: AppTextStyle.sm.copyWith(color: AppColors.gray400),
          ),
        ),
        _SettingsTile(
          icon: Icons.lock_outline_rounded,
          iconColor: AppColors.green700,
          iconBg: AppColors.green100,
          title: l.settingsSecurity,
          trailing: Text(
            'Local BLE',
            style: AppTextStyle.sm.copyWith(color: AppColors.gray400),
          ),
        ),
      ],
    );
  }
}

// ── Privacy & Blocked Devices card ───────────────────────────────────────────

class _PrivacyCard extends StatelessWidget {
  final BleChatV10Controller ble;
  const _PrivacyCard({required this.ble});

  void _showBlockedSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BlockedDevicesSheet(ble: ble),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final count = ble.blockedNodes.length;

    return _SettingsCard(
      children: [
        _SettingsTile(
          icon: Icons.block_rounded,
          iconColor: AppColors.red600,
          iconBg: AppColors.red100,
          title: l.settingsBlockedDevices,
          subtitle: l.settingsBlockedDevicesSub,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: count > 0 ? AppColors.red100 : AppColors.gray100,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '$count',
                  style: AppTextStyle.xs.copyWith(
                    fontWeight: FontWeight.w600,
                    color: count > 0 ? AppColors.red700 : AppColors.gray600,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.gray300,
              ),
            ],
          ),
          onTap: () => _showBlockedSheet(context),
        ),
      ],
    );
  }
}

class _BlockedDevicesSheet extends StatelessWidget {
  final BleChatV10Controller ble;
  const _BlockedDevicesSheet({required this.ble});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return ListenableBuilder(
      listenable: ble,
      builder: (context, _) {
        final blocked = ble.blockedNodes;
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(
                    top: AppSpacing.sm,
                    bottom: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gray300,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  children: [
                    Text(
                      l.blockedDevicesTitle,
                      style: AppTextStyle.lg.copyWith(
                        color: AppColors.gray900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: AppColors.gray500,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Body
              if (blocked.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.gray100,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          size: 28,
                          color: AppColors.gray400,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        l.blockedDevicesEmpty,
                        style: AppTextStyle.semibold.copyWith(
                          color: AppColors.gray800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l.blockedDevicesEmptyHint,
                        style: AppTextStyle.bodyMuted,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    itemCount: blocked.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final node = blocked[i];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.red100,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: const Icon(
                            Icons.block_rounded,
                            color: AppColors.red600,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          node.name,
                          style: AppTextStyle.base.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.gray900,
                          ),
                        ),
                        subtitle: Text(
                          node.id,
                          style: AppTextStyle.xs.copyWith(
                            color: AppColors.gray400,
                            fontFamily: 'monospace',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: TextButton(
                          onPressed: () async {
                            await ble.unblockNode(node.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text(l.deviceUnblockedSnack(node.name)),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.indigo600,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                            ),
                          ),
                          child: Text(
                            l.unblockAction,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

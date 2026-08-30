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
              Flexible(fit: FlexFit.loose, child: trailing!),
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
      case 'poweredOn':  return AppColors.green500;
      case 'poweredOff': return AppColors.gray400;
      default:           return AppColors.amber700;
    }
  }

  String _stateLabel(String name, AppL10n l) {
    switch (name) {
      case 'poweredOn':    return l.btOn;
      case 'poweredOff':   return l.btOff;
      case 'unauthorized': return l.btUnauthorized;
      case 'unsupported':  return l.btUnsupported;
      default:             return name;
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
              : l.settingsNotConnected,
          trailing: ble.connected
              ? TextButton(
                  onPressed: ble.disconnect,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.red700,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                  ),
                  child: Text(
                    l.settingsDisconnect,
                    style: const TextStyle(fontSize: 13),
                  ),
                )
              : null,
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
    MeshChatApp.setLocale(
      context,
      langCode != null ? Locale(langCode) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    final options = [
      (code: null,   label: l.langSystemDefault, flag: '🌐'),
      (code: 'vi',   label: l.langVietnamese,    flag: '🇻🇳'),
      (code: 'en',   label: l.langEnglish,       flag: '🇬🇧'),
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
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.w400,
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
          subtitle: l.settingsProtocolSub,
        ),
        _SettingsTile(
          icon: Icons.lock_outline_rounded,
          iconColor: AppColors.green700,
          iconBg: AppColors.green100,
          title: l.settingsSecurity,
          subtitle: l.settingsSecuritySub,
        ),
      ],
    );
  }
}

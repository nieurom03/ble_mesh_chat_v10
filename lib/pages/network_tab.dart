import 'package:flutter/material.dart';

import '../services/ble_chat_v10.dart';
import '../theme/app_theme.dart';
import '../widgets/section_header.dart';
import 'chat_page.dart';

class NetworkTab extends StatelessWidget {
  final BleChatV10Controller ble;
  const NetworkTab({super.key, required this.ble});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeader(
          title: 'Network',
          subtitle: ble.scanning
              ? 'Đang quét  •  ${ble.phones.length} thiết bị'
              : 'Tìm điện thoại quảng bá BLE Mesh',
          actions: [
            _ScanButton(
              scanning: ble.scanning,
              onStart: ble.startScan,
              onStop: ble.stopScan,
            ),
          ],
        ),
        const Divider(),

        // ── Error banner ───────────────────────────────────────────
        if (ble.error != null)
          _ErrorBanner(message: ble.error!, onDismiss: ble.clearError),

        // ── Device list ────────────────────────────────────────────
        Expanded(
          child: ble.phones.isEmpty
              ? _EmptyNetwork(scanning: ble.scanning, onScan: ble.startScan)
              : RefreshIndicator(
                  onRefresh: ble.startScan,
                  color: AppColors.indigo600,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      AppSpacing.xl,
                    ),
                    itemCount: ble.phones.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (_, i) =>
                        _PhoneCard(ble: ble, phone: ble.phones[i]),
                  ),
                ),
        ),
      ],
    );
  }
}

// ── Scan button ──────────────────────────────────────────────────────────────

class _ScanButton extends StatelessWidget {
  final bool scanning;
  final VoidCallback onStart;
  final VoidCallback onStop;
  const _ScanButton({
    required this.scanning,
    required this.onStart,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: scanning ? onStop : onStart,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + 2,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: scanning ? AppColors.red100 : AppColors.indigo50,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: scanning ? AppColors.red500.withAlpha(60) : AppColors.indigo100,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (scanning)
              SizedBox(
                width: 13,
                height: 13,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.red500,
                ),
              )
            else
              const Icon(
                Icons.radar_rounded,
                size: 15,
                color: AppColors.indigo600,
              ),
            const SizedBox(width: 5),
            Text(
              scanning ? 'Dừng' : 'Quét',
              style: AppTextStyle.sm.copyWith(
                fontWeight: FontWeight.w600,
                color: scanning ? AppColors.red700 : AppColors.indigo600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error banner ─────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;
  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        0,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.red100,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.red500.withAlpha(60)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.red700),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyle.sm.copyWith(color: AppColors.red700),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(Icons.close_rounded, size: 16, color: AppColors.red700),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────

class _EmptyNetwork extends StatelessWidget {
  final bool scanning;
  final VoidCallback onScan;
  const _EmptyNetwork({required this.scanning, required this.onScan});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.indigo50,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Icon(
                scanning
                    ? Icons.bluetooth_searching_rounded
                    : Icons.bluetooth_disabled_rounded,
                size: 40,
                color: AppColors.indigo500,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              scanning ? 'Đang tìm kiếm…' : 'Chưa thấy thiết bị nào',
              style: AppTextStyle.lg.copyWith(color: AppColors.gray800),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Điện thoại kia phải cài app này, bật Bluetooth và đang quảng bá BLE Mesh.',
              style: AppTextStyle.bodyMuted,
              textAlign: TextAlign.center,
            ),
            if (!scanning) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: onScan,
                icon: const Icon(Icons.radar_rounded, size: 18),
                label: const Text('Bắt đầu quét'),
              ),
            ] else ...[
              const SizedBox(height: AppSpacing.lg),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.indigo500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Phone card ───────────────────────────────────────────────────────────────

class _PhoneCard extends StatelessWidget {
  final BleChatV10Controller ble;
  final DiscoveredPhone phone;
  const _PhoneCard({required this.ble, required this.phone});

  // RSSI → signal strength label + color
  ({String label, Color color, Color bg}) _signal(int rssi) {
    if (rssi >= -60) {
      return (
        label: 'Mạnh',
        color: AppColors.green700,
        bg: AppColors.green100,
      );
    } else if (rssi >= -75) {
      return (
        label: 'Trung bình',
        color: AppColors.amber700,
        bg: AppColors.amber100,
      );
    }
    return (label: 'Yếu', color: AppColors.red700, bg: AppColors.red100);
  }

  @override
  Widget build(BuildContext context) {
    final sig = _signal(phone.rssi);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: phone.connected ? AppColors.indigo100 : AppColors.gray200,
          width: phone.connected ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: phone.connected
                    ? AppColors.indigo100
                    : AppColors.gray100,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Icon(
                Icons.smartphone_rounded,
                color: phone.connected
                    ? AppColors.indigo600
                    : AppColors.gray500,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.sm + 4),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    phone.name,
                    style: AppTextStyle.semibold.copyWith(
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      // Signal badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: sig.bg,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          '${sig.label}  ${phone.rssi} dBm',
                          style: AppTextStyle.xs.copyWith(
                            fontWeight: FontWeight.w600,
                            color: sig.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    phone.peripheral.uuid.toString(),
                    style: AppTextStyle.xs.copyWith(color: AppColors.gray400),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // Action button
            _ActionButton(ble: ble, phone: phone),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final BleChatV10Controller ble;
  final DiscoveredPhone phone;
  const _ActionButton({required this.ble, required this.phone});

  @override
  Widget build(BuildContext context) {
    if (phone.connecting) {
      return Container(
        width: 80,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.indigo500,
            ),
          ),
        ),
      );
    }

    if (phone.connected) {
      return FilledButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatPage(ble: ble, peerName: phone.name),
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.indigo600,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          minimumSize: const Size(80, 36),
        ),
        child: const Text('Chat', style: TextStyle(fontSize: 13)),
      );
    }

    return OutlinedButton(
      onPressed: () => ble.connectTo(phone),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.indigo600,
        side: const BorderSide(color: AppColors.indigo600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        minimumSize: const Size(80, 36),
      ),
      child: const Text('Kết nối', style: TextStyle(fontSize: 13)),
    );
  }
}

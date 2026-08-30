import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Small pill badge showing Bluetooth state.
class StatusBadge extends StatelessWidget {
  final BluetoothLowEnergyState state;
  const StatusBadge({super.key, required this.state});

  bool get _on => state == BluetoothLowEnergyState.poweredOn;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: _on ? AppColors.green100 : AppColors.gray100,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _on ? AppColors.green500 : AppColors.gray400,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            _on ? 'BT On' : state.name,
            style: AppTextStyle.xs.copyWith(
              fontWeight: FontWeight.w600,
              color: _on ? AppColors.green700 : AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Dialog cho phép người dùng đổi tên thiết bị trong Mesh.
class EditNameDialog extends StatefulWidget {
  final String initialName;
  const EditNameDialog({super.key, required this.initialName});

  @override
  State<EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<EditNameDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() => Navigator.pop(context, _ctrl.text.trim());

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icon + title ──────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.indigo100,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.badge_outlined,
                    color: AppColors.indigo600,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tên trong Mesh',
                      style: AppTextStyle.semibold.copyWith(
                        fontSize: 16,
                        color: AppColors.gray900,
                      ),
                    ),
                    Text(
                      'Hiển thị với người kết nối',
                      style: AppTextStyle.bodyMuted,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Input ─────────────────────────────────────────────
            TextField(
              controller: _ctrl,
              autofocus: true,
              maxLength: 20,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              style: AppTextStyle.base.copyWith(color: AppColors.gray900),
              decoration: InputDecoration(
                hintText: 'Ví dụ: iPhone của Nam',
                counterText: '',
                suffixText: '${_ctrl.text.length}/20',
                suffixStyle: AppTextStyle.labelMuted,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Actions ───────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.gray600,
                      side: const BorderSide(color: AppColors.gray200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm + 2,
                      ),
                    ),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton(
                    onPressed: _ctrl.text.trim().isEmpty ? null : _submit,
                    child: const Text('Lưu'),
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

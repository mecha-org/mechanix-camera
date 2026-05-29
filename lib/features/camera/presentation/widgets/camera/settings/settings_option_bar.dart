import 'package:flutter/material.dart';
import 'package:mechanix_camera/core/utils/app_colors.dart';
import 'package:mechanix_camera/features/camera/model/camera_types.dart';

class SettingsOptionBar extends StatelessWidget {
  final List<SettingsOptionItem> items;
  final MainAxisAlignment alignment;

  const SettingsOptionBar({
    super.key,
    required this.items,
    this.alignment = MainAxisAlignment.spaceEvenly,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      width: double.infinity,
      height: 48,
      color: AppColors.selectionMenuColor,
      child: Row(
        mainAxisAlignment: alignment,
        children: items
            .map((item) => _OptionButton(label: item.label, onTap: item.onTap))
            .toList(),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _OptionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        label,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }
}

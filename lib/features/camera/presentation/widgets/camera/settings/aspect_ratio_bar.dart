import 'package:flutter/material.dart';
import 'package:mechanix_camera/features/camera/model/camera_types.dart';
import 'package:mechanix_camera/l10n/app_localizations.dart';

import 'settings_option_bar.dart';

class AspectRatioBar extends StatelessWidget {
  const AspectRatioBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsOptionBar(
      items: [
        SettingsOptionItem(
          label: AppLocalizations.of(context)!.aspectRatio11,
          onTap: () {}, // TODO: Not implemented yet
        ),
        SettingsOptionItem(
          label: AppLocalizations.of(context)!.aspectRatio43,
          onTap: () {}, //TODO: Not implemented yet
        ),
        SettingsOptionItem(
          label: AppLocalizations.of(context)!.aspectRatio169,
          onTap: () {}, //TODO: Not implemented yet
        ),
        SettingsOptionItem(
          label: AppLocalizations.of(context)!.aspectRatioFull,
          onTap: () {}, //TODO: Not implemented yet
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mechanix_camera/features/camera/bloc/camera_settings/camera_settings_bloc.dart';
import 'package:mechanix_camera/features/camera/model/camera_types.dart';
import 'package:mechanix_camera/l10n/app_localizations.dart';

import 'settings_option_bar.dart';

class ZoomBar extends StatelessWidget {
  const ZoomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsOptionBar(
      items: [
        SettingsOptionItem(
          label: AppLocalizations.of(context)!.zoomLevel(1),
          onTap: () {
            context.read<CameraSettingsBloc>().add(
              const SetZoomLevel(zoomLevel: 1),
            );
          },
        ),
        SettingsOptionItem(
          label: AppLocalizations.of(context)!.zoomLevel(2),
          onTap: () {
            context.read<CameraSettingsBloc>().add(
              const SetZoomLevel(zoomLevel: 2),
            );
          },
        ),
        SettingsOptionItem(
          label: AppLocalizations.of(context)!.zoomLevel(4),
          onTap: () {
            context.read<CameraSettingsBloc>().add(
              const SetZoomLevel(zoomLevel: 4),
            );
          },
        ),
        SettingsOptionItem(
          label: AppLocalizations.of(context)!.zoomLevel(8),
          onTap: () {
            context.read<CameraSettingsBloc>().add(
              const SetZoomLevel(zoomLevel: 8),
            );
          },
        ),
      ],
    );
  }
}

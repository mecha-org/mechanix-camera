import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mechanix_camera/core/utils/app_routes.dart';
import 'package:mechanix_camera/core/utils/app_theme.dart';
import 'package:mechanix_camera/features/camera/bloc/camera_bloc.dart';
import 'package:mechanix_camera/features/camera/bloc/camera_settings/camera_settings_bloc.dart';
import 'package:mechanix_camera/features/camera/data/camera_repository.dart';
import 'package:mechanix_camera/features/camera/data/camera_repository_impl.dart';
import 'package:mechanix_camera/features/camera/presentation/screen/camera_screen.dart';
import 'package:mechanix_camera/l10n/app_localizations.dart';
import 'package:show_fps/show_fps.dart';

void main() {
  runApp(const CameraApp());
}

class CameraApp extends StatelessWidget {
  const CameraApp({super.key});

  @override
  Widget build(BuildContext context) {
    final showFps = Platform.environment['SHOW_FPS'] == 'true';

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<CameraRepository>(
          create: (context) => CameraRepositoryImpl(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                CameraBloc(context.read<CameraRepository>())
                  ..add(const CameraInitialized()),
          ),
          BlocProvider(
            create: (context) =>
                CameraSettingsBloc(context.read<CameraRepository>()),
          ),
        ],
        child: MaterialApp(
          title: 'Mechanix Camera',
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          themeMode: ThemeMode.dark,
          darkTheme: AppTheme.dark,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routes: AppRoutes.routes,
          home: const CameraScreen(),
          builder: showFps
              ? (context, child) {
                  return ShowFPS(
                    visible: showFps,
                    showChart: false,
                    child: child!,
                  );
                }
              : null,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mechanix_camera/core/utils/app_routes.dart';
import 'package:mechanix_camera/core/utils/app_theme.dart';
import 'package:mechanix_camera/features/camera/bloc/camera_bloc.dart';
import 'package:mechanix_camera/features/camera/bloc/camera_settings/camera_settings_bloc.dart';
import 'package:mechanix_camera/features/camera/data/camera_repository.dart';
import 'package:mechanix_camera/l10n/app_localizations.dart';

class TestAppWrapper extends StatelessWidget {
  final Widget child;
  final CameraRepository repository;

  const TestAppWrapper({
    super.key,
    required this.child,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<CameraRepository>(create: (_) => repository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (ctx) =>
                CameraBloc(ctx.read<CameraRepository>())
                  ..add(const CameraInitialized()),
          ),
          BlocProvider(
            create: (ctx) => CameraSettingsBloc(ctx.read<CameraRepository>()),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          themeMode: ThemeMode.dark,
          darkTheme: AppTheme.dark,
          theme: AppTheme.light,
          routes: AppRoutes.routes,
          home: child,
        ),
      ),
    );
  }
}

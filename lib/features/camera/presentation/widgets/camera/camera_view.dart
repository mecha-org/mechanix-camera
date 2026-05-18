import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mechanix_camera/core/utils/constants.dart';
import 'package:mechanix_camera/features/camera/bloc/camera_bloc.dart';
import 'package:mechanix_camera/features/camera/bloc/camera_settings/camera_settings_bloc.dart';
import 'package:mechanix_camera/features/camera/presentation/widgets/camera/focus/camera_focus.dart';

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  final ValueNotifier<bool> _focusVisible = ValueNotifier(false);
  Offset _focusPosition = Offset.zero;

  Offset _clampFocusPosition(Offset raw, BoxConstraints constraints) {
    final halfW = AppConstants.focusSize.width / 2;
    final halfH = AppConstants.focusSize.height / 2;
    return Offset(
      raw.dx.clamp(halfW, constraints.maxWidth - halfW),
      raw.dy.clamp(halfH, constraints.maxHeight - halfH),
    );
  }

  Future<void> _onTapDown(
    TapDownDetails details,
    BoxConstraints constraints,
  ) async {
    _focusPosition = _clampFocusPosition(details.localPosition, constraints);

    if (_focusVisible.value) {
      _focusVisible.value = false;
      await Future.microtask(() {});
    }
    _focusVisible.value = true;

    final normalized = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );

    if (!mounted) return;

    final settingsBloc = context.read<CameraSettingsBloc>();
    settingsBloc
      ..add(SetFocusPoint(point: normalized))
      ..add(SetExposurePoint(point: normalized))
      ..add(const SetFocusMode(focusMode: FocusMode.auto));

    await Future.delayed(const Duration(milliseconds: 800));

    settingsBloc.add(const SetFocusMode(focusMode: FocusMode.locked));
  }

  @override
  void dispose() {
    _focusVisible.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CameraBloc>();

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(
          bloc.controller,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) => _onTapDown(details, constraints),
              );
            },
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _focusVisible,
          builder: (context, isVisible, _) {
            // ✅ Positioned must be a direct child of Stack, not inside AnimatedOpacity
            return Positioned(
              left: _focusPosition.dx - (AppConstants.focusSize.width / 2),
              top: _focusPosition.dy - (AppConstants.focusSize.height / 2),
              child: AnimatedOpacity(
                opacity: isVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: isVisible
                    ? const CameraFocus()
                    : const SizedBox.shrink(),
              ),
            );
          },
        ),
      ],
    );
  }
}

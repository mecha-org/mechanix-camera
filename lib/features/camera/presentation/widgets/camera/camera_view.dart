// camera_view.dart

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mechanix_camera/core/utils/constants.dart';
import 'package:mechanix_camera/features/camera/bloc/camera_bloc.dart';
import 'package:mechanix_camera/features/camera/bloc/camera_settings/camera_settings_bloc.dart';
import 'package:mechanix_camera/features/camera/model/camera_types.dart';
import 'package:mechanix_camera/features/camera/presentation/widgets/camera/focus/camera_focus.dart';

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  final ValueNotifier<bool> _focusVisible = ValueNotifier(false);

  Offset _tapPosition = Offset.zero;

  ExposureControlPosition _brightnessPosition = ExposureControlPosition.end;

  ExposureControlPosition _decideSide(Offset tap, BoxConstraints constraints) {
    final spaceOnRight = constraints.maxWidth - tap.dx;

    final spaceNeeded =
        (CameraFocusConstants.focusBoxSize / 2) +
        CameraFocusConstants.brightnessTotalWidth;

    return spaceOnRight < spaceNeeded
        ? ExposureControlPosition.start
        : ExposureControlPosition.end;
  }

  Offset _clampTap(Offset raw, BoxConstraints constraints) {
    final half = CameraFocusConstants.focusBoxSize / 2;

    return Offset(
      raw.dx.clamp(half, constraints.maxWidth - half),
      raw.dy.clamp(half, constraints.maxHeight - half),
    );
  }

  Future<void> _onTapDown(
    TapDownDetails details,
    BoxConstraints constraints,
  ) async {
    _brightnessPosition = _decideSide(details.localPosition, constraints);

    _tapPosition = _clampTap(details.localPosition, constraints);

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
      ..add(const SetFocusMode(focusMode: FocusMode.auto))
      ..add(const SetExposureMode(exposureMode: ExposureMode.auto));
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
                onTapDown: (details) {
                  _onTapDown(details, constraints);
                },
              );
            },
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _focusVisible,
          builder: (context, isVisible, _) {
            final focusBoxLeft =
                _tapPosition.dx - (CameraFocusConstants.focusBoxSize / 2);

            final left = _brightnessPosition == ExposureControlPosition.start
                ? focusBoxLeft - CameraFocusConstants.brightnessTotalWidth
                : focusBoxLeft;

            return Positioned(
              left: left,
              top: _tapPosition.dy - (CameraFocusConstants.focusBoxSize / 2),
              child: AnimatedOpacity(
                opacity: isVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: isVisible
                    ? CameraFocus(
                        key: UniqueKey(),
                        position: _brightnessPosition,
                      )
                    : const SizedBox.shrink(),
              ),
            );
          },
        ),
      ],
    );
  }
}

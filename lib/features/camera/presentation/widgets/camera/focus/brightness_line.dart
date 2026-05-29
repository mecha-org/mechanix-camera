import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mechanix_camera/core/utils/app_colors.dart';
import 'package:mechanix_camera/core/utils/constants.dart';
import 'package:mechanix_camera/features/camera/bloc/camera_settings/camera_settings_bloc.dart';

class BrightnessLine extends StatefulWidget {
  const BrightnessLine({super.key});

  @override
  State<BrightnessLine> createState() => _BrightnessLineState();
}

class _BrightnessLineState extends State<BrightnessLine> {
  final ValueNotifier<double> _iconOffsetY = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _iconOffsetY.value = 0.0;
    });
  }

  @override
  void dispose() {
    _iconOffsetY.dispose();
    super.dispose();
  }

  // Handles vertical drag gestures for adjusting camera exposure.
  // Updates the brightness icon position within the allowed range,
  // normalizes the drag position, converts it into an exposure value
  void _onVerticalDrag(DragUpdateDetails details) {
    final newOffset = (_iconOffsetY.value - details.delta.dy).clamp(
      -CameraFocusConstants.brightnessHalfLineHeight,
      CameraFocusConstants.brightnessHalfLineHeight,
    );
    _iconOffsetY.value = newOffset;

    final state = context.read<CameraSettingsBloc>().state;
    final minEV = state.minExposureOffset;
    final maxEV = state.maxExposureOffset;

    final normalized =
        (_iconOffsetY.value + CameraFocusConstants.brightnessHalfLineHeight) /
        CameraFocusConstants.totalTravel;
    final exposureValue = minEV + (maxEV - minEV) * normalized;

    context.read<CameraSettingsBloc>().add(
      SetExposureOffset(offset: exposureValue),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: _onVerticalDrag,
      child: Container(
        margin: const EdgeInsets.only(
          left: CameraFocusConstants.brightnessIconLeftMargin,
        ),
        height: CameraFocusConstants.brightnessTotalHeight,
        width: CameraFocusConstants.brightnessContainerWidth,
        child: ValueListenableBuilder<double>(
          valueListenable: _iconOffsetY,
          builder: (context, offsetY, _) {
            final upperHeight =
                (CameraFocusConstants.brightnessHalfLineHeight - offsetY).clamp(
                  0.0,
                  CameraFocusConstants.brightnessHalfLineHeight * 2,
                );
            final lowerHeight =
                (CameraFocusConstants.brightnessHalfLineHeight + offsetY).clamp(
                  0.0,
                  CameraFocusConstants.brightnessHalfLineHeight * 2,
                );

            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Segment(
                  height: upperHeight,
                  width: CameraFocusConstants.brightnessLineWidth,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(
                  height: CameraFocusConstants.brightnessLineIconGap,
                ),
                const Icon(
                  Icons.sunny,
                  size: CameraFocusConstants.brightnessIconSize,
                  color: AppColors.exposureColor,
                ),
                const SizedBox(
                  height: CameraFocusConstants.brightnessLineIconGap,
                ),
                _Segment(
                  height: lowerHeight,
                  width: CameraFocusConstants.brightnessLineWidth,
                  color: AppColors.exposureColor,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final double height;
  final double width;
  final Color color;

  const _Segment({
    required this.height,
    required this.width,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ColoredBox(color: color),
    );
  }
}

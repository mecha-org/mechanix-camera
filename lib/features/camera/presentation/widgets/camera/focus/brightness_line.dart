import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mechanix_camera/features/camera/bloc/camera_settings/camera_settings_bloc.dart';

class BrightnessLine extends StatefulWidget {
  const BrightnessLine({super.key});

  @override
  State<BrightnessLine> createState() => _BrightnessLineState();
}

class _BrightnessLineState extends State<BrightnessLine> {
  static const double _halfLineHeight = 50.0;
  static const double _lineWidth = 1.5;
  static const double _iconSize = 20.0;
  static const double _gap = 4.0;
  static const double _totalTravel = _halfLineHeight * 2;

  final ValueNotifier<double> _iconOffsetY = ValueNotifier(0.0);

  @override
  void dispose() {
    _iconOffsetY.dispose();
    super.dispose();
  }

  void _onVerticalDrag(DragUpdateDetails details) {
    // Drag UP   → dy is negative → subtract → offsetY decreases → upperHeight shrinks → icon moves UP
    // Drag DOWN → dy is positive → subtract → offsetY increases → lowerHeight shrinks → icon moves DOWN
    final newOffset = (_iconOffsetY.value - details.delta.dy).clamp(
      -_halfLineHeight,
      _halfLineHeight,
    );

    _iconOffsetY.value = newOffset;

    final state = context.read<CameraSettingsBloc>().state;
    final minEV = state.minExposureOffset;
    final maxEV = state.maxExposureOffset;

    // offsetY == +_halfLineHeight → icon at top    → maxEV (brightest)
    // offsetY ==  0              → icon at centre  → midpoint
    // offsetY == -_halfLineHeight → icon at bottom → minEV (darkest)
    final normalized = (_iconOffsetY.value + _halfLineHeight) / _totalTravel;
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
        margin: const EdgeInsets.only(left: 8),
        height: _halfLineHeight * 2 + _iconSize + _gap * 2,
        width: _iconSize + 8,
        child: ValueListenableBuilder<double>(
          valueListenable: _iconOffsetY,
          builder: (context, offsetY, _) {
            // offsetY positive → icon is in upper half → upper segment shorter
            final upperHeight = (_halfLineHeight - offsetY).clamp(
              0.0,
              _halfLineHeight * 2,
            );
            final lowerHeight = (_halfLineHeight + offsetY).clamp(
              0.0,
              _halfLineHeight * 2,
            );

            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Segment(
                  height: upperHeight,
                  width: _lineWidth,
                  color: Colors.white,
                ),
                const SizedBox(height: _gap),
                const Icon(Icons.sunny, size: _iconSize, color: Colors.amber),
                const SizedBox(height: _gap),
                _Segment(
                  height: lowerHeight,
                  width: _lineWidth,
                  color: Colors.amber,
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

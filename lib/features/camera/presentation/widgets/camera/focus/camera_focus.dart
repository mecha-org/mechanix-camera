// camera_focus.dart

import 'package:flutter/material.dart';
import 'package:mechanix_camera/core/utils/constants.dart';
import 'package:mechanix_camera/features/camera/model/camera_types.dart';
import 'package:mechanix_camera/features/camera/presentation/widgets/camera/focus/brightness_line.dart';

class CameraFocus extends StatefulWidget {
  final ExposureControlPosition position;

  const CameraFocus({super.key, required this.position});

  @override
  State<CameraFocus> createState() => _CameraFocusState();
}

class _CameraFocusState extends State<CameraFocus>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _initializeAnimation();
  }

  void _initializeAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _scaleAnim = Tween<double>(
      begin: 1.35,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isStart = widget.position == ExposureControlPosition.start;

    return ScaleTransition(
      scale: _scaleAnim,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isStart) BrightnessLine(key: UniqueKey()),
          SizedBox(
            width: CameraFocusConstants.focusBoxSize,
            height: CameraFocusConstants.focusBoxSize,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.onSurface,
                  width: 1.5,
                ),
              ),
            ),
          ),
          if (!isStart) BrightnessLine(key: UniqueKey()),
        ],
      ),
    );
  }
}

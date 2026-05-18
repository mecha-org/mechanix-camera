import 'package:flutter/material.dart';
import 'package:mechanix_camera/core/utils/constants.dart';
import 'package:mechanix_camera/features/camera/presentation/widgets/camera/focus/brightness_line.dart';

class CameraFocus extends StatefulWidget {
  const CameraFocus({super.key});

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
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: AppConstants.focusSize.width,
            height: AppConstants.focusSize.height,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
          const BrightnessLine(),
        ],
      ),
    );
  }
}

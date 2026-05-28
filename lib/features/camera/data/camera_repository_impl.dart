import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:mechanix_camera/core/utils/app_logger.dart';
import 'package:mechanix_camera/core/utils/constants.dart';

import 'camera_repository.dart';

class CameraRepositoryImpl implements CameraRepository {
  CameraController? _controller;

  @override
  CameraController? get controller => _controller;

  @override
  Future<CameraController> initialize() async {
    final cameras = await availableCameras();

    if (cameras.isEmpty) {
      throw Exception('No cameras found on this device.');
    }

    _controller = CameraController(
      cameras[0],
      ResolutionPreset.max,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await _controller!.initialize();
    AppLogger.i('Camera controller initialized');
    return _controller!;
  }

  @override
  Future<String> capture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      AppLogger.i('Camera controller not initialized');
      throw Exception('Camera is not initialized.');
    }

    await checkStorage();

    final defaultImagePath = getDefaultStoragePath();

    final savePath =
        '$defaultImagePath/${DateTime.now().millisecondsSinceEpoch}.jpg';

    if (!await Directory(defaultImagePath).exists()) {
      await Directory(defaultImagePath).create(recursive: true);
    }

    final file = await _controller!.takePicture();

    await file.saveTo(savePath);

    final tempFile = File(file.path);

    if (await tempFile.exists()) {
      await tempFile.delete();
    }

    return savePath;
  }

  @override
  Future<void> setFocusMode(FocusMode focusMode) async {
    try {
      checkControllerInitialize();
      await _controller!.setFocusMode(focusMode);
    } catch (e) {
      AppLogger.e('Error setting focus mode: $e');
    }
  }

  @override
  Future<void> setFocusPoint(Offset point) async {
    try {
      checkControllerInitialize();
      await _controller!.setFocusPoint(point);
    } catch (e) {
      AppLogger.e('Error setting focus point: $e');
    }
  }

  @override
  Future<void> setExposureMode(ExposureMode exposureMode) async {
    try {
      checkControllerInitialize();
      await _controller!.setExposureMode(exposureMode);
    } catch (e) {
      AppLogger.e('Error setting exposure mode: $e');
    }
  }

  @override
  Future<void> setExposurePoint(Offset point) async {
    try {
      checkControllerInitialize();
      await _controller!.setExposurePoint(point);
    } catch (e) {
      AppLogger.e('Error setting exposure point: $e');
    }
  }

  @override
  Future<void> setExposureOffset(double offset) async {
    try {
      checkControllerInitialize();
      await _controller!.setExposureOffset(offset);
    } catch (e) {
      AppLogger.e('Error setting exposure offset: $e');
    }
  }

  @override
  Future<void> setZoomLevel(double zoomLevel) async {
    try {
      checkControllerInitialize();
      await _controller!.setZoomLevel(zoomLevel);
    } catch (e) {
      AppLogger.e('Error setting zoom level: $e');
    }
  }

  @override
  Future<List<File>> getAllStoredImages() async {
    final path = getDefaultStoragePath();
    final directory = Directory(path);

    final files = await directory
        .list()
        .where((entity) => entity is File)
        .cast<File>()
        .toList();

    return files;
  }

  @override
  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }

  void checkControllerInitialize() {
    if (_controller == null || !_controller!.value.isInitialized) {
      AppLogger.i('Camera controller not initialized');
      throw Exception('Camera is not initialized.');
    }
  }

  Future<void> checkStorage() async {
    final result = await Process.run('df', ['-k', '/']);

    if (result.exitCode == 0) {
      final lines = result.stdout.toString().trim().split('\n');

      final columns = lines[1].split(RegExp(r'\s+'));

      final availableKb = int.parse(columns[3]);

      AppLogger.i('Available storage:  ${availableKb.toStringAsFixed(2)} KB');

      if (availableKb < AppConstants.minimumStorageRequired) {
        throw Exception('Low storage space');
      }
    } else {
      AppLogger.e('Error: ${result.stderr}');
      throw Exception('Error: ${result.stderr}');
    }
  }

  String getDefaultStoragePath() {
    final homeDir = Platform.environment['HOME'];

    if (homeDir == null || homeDir.isEmpty) {
      return '/tmp/Camera';
    }

    return '$homeDir/Pictures/Camera';
  }

  void orientationChange() {
    _controller!.lockCaptureOrientation();
    _controller!.value.deviceOrientation;
  }
}

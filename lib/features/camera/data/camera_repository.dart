import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';

abstract class CameraRepository {
  Future<CameraController> initialize();

  Future<String> capture();

  Future<void> dispose();

  CameraController? get controller;

  Future<List<File>> getAllStoredImages();

  Future<void> setFocusMode(FocusMode focusMode);

  Future<void> setFocusPoint(Offset point);

  Future<void> setExposureMode(ExposureMode exposureMode);

  Future<void> setExposurePoint(Offset point);

  Future<void> setExposureOffset(double offset);
}

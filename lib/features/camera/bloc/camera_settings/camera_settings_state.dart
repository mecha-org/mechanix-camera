part of 'camera_settings_bloc.dart';

final class CameraSettingsState extends Equatable {
  final DeviceOrientation orientation;
  final double maxExposureOffset;
  final double minExposureOffset;
  final double maxZoomLevel;
  final double minZoomLevel;
  final FocusMode focusMode;
  final ExposureMode exposureMode;
  final double exposureOffset;
  final double zoomLevel;

  const CameraSettingsState({
    this.orientation = DeviceOrientation.landscapeRight,
    this.maxExposureOffset = 0,
    this.minExposureOffset = 0,
    this.maxZoomLevel = 1,
    this.minZoomLevel = 1,
    this.focusMode = FocusMode.auto,
    this.exposureMode = ExposureMode.auto,
    this.exposureOffset = 0,
    this.zoomLevel = 1,
  });

  CameraSettingsState copyWith({
    DeviceOrientation? orientation,
    double? maxExposureOffset,
    double? minExposureOffset,
    double? maxZoomLevel,
    double? minZoomLevel,
    FocusMode? focusMode,
    ExposureMode? exposureMode,
    double? exposureOffset,
    double? zoomLevel,
  }) {
    return CameraSettingsState(
      orientation: orientation ?? this.orientation,
      maxExposureOffset: maxExposureOffset ?? this.maxExposureOffset,
      minExposureOffset: minExposureOffset ?? this.minExposureOffset,
      maxZoomLevel: maxZoomLevel ?? this.maxZoomLevel,
      minZoomLevel: minZoomLevel ?? this.minZoomLevel,
      focusMode: focusMode ?? this.focusMode,
      exposureMode: exposureMode ?? this.exposureMode,
      exposureOffset: exposureOffset ?? this.exposureOffset,
      zoomLevel: zoomLevel ?? this.zoomLevel,
    );
  }

  @override
  List<Object> get props => [
    orientation,
    maxExposureOffset,
    minExposureOffset,
    maxZoomLevel,
    minZoomLevel,
    focusMode,
    exposureMode,
    exposureOffset,
    zoomLevel,
  ];
}

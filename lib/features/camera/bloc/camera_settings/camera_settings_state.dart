part of 'camera_settings_bloc.dart';

final class CameraSettingsState extends Equatable {
  final DeviceOrientation orientation;
  final double maxExposureOffset;
  final double minExposureOffset;
  final FocusMode focusMode;
  final ExposureMode exposureMode;
  final double exposureOffset;

  const CameraSettingsState({
    this.orientation = DeviceOrientation.landscapeRight,
    this.maxExposureOffset = 0,
    this.minExposureOffset = 0,
    this.focusMode = FocusMode.auto,
    this.exposureMode = ExposureMode.auto,
    this.exposureOffset = 0,
  });

  CameraSettingsState copyWith({
    DeviceOrientation? orientation,
    double? maxExposureOffset,
    double? minExposureOffset,
    FocusMode? focusMode,
    ExposureMode? exposureMode,
    double? exposureOffset,
  }) {
    return CameraSettingsState(
      orientation: orientation ?? this.orientation,
      maxExposureOffset: maxExposureOffset ?? this.maxExposureOffset,
      minExposureOffset: minExposureOffset ?? this.minExposureOffset,
      focusMode: focusMode ?? this.focusMode,
      exposureMode: exposureMode ?? this.exposureMode,
      exposureOffset: exposureOffset ?? this.exposureOffset,
    );
  }

  @override
  List<Object> get props => [
    orientation,
    maxExposureOffset,
    minExposureOffset,
    focusMode,
    exposureMode,
    exposureOffset,
  ];
}

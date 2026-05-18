part of 'camera_settings_bloc.dart';

sealed class CameraSettingsEvent extends Equatable {
  const CameraSettingsEvent();

  @override
  List<Object> get props => [];
}

final class CameraOrientationChanged extends CameraSettingsEvent {
  final DeviceOrientation orientation;
  const CameraOrientationChanged({required this.orientation});

  @override
  List<Object> get props => [orientation];
}

final class StartOrientationListener extends CameraSettingsEvent {
  const StartOrientationListener();

  @override
  List<Object> get props => [];
}

final class SetFocusMode extends CameraSettingsEvent {
  final FocusMode focusMode;
  const SetFocusMode({required this.focusMode});

  @override
  List<Object> get props => [focusMode];
}

final class SetFocusPoint extends CameraSettingsEvent {
  final Offset point;
  const SetFocusPoint({required this.point});

  @override
  List<Object> get props => [point];
}

final class SetExposureMode extends CameraSettingsEvent {
  final ExposureMode exposureMode;
  const SetExposureMode({required this.exposureMode});

  @override
  List<Object> get props => [exposureMode];
}

final class SetExposurePoint extends CameraSettingsEvent {
  final Offset point;
  const SetExposurePoint({required this.point});

  @override
  List<Object> get props => [point];
}

final class SetExposureOffset extends CameraSettingsEvent {
  final double offset;
  const SetExposureOffset({required this.offset});

  @override
  List<Object> get props => [offset];
}

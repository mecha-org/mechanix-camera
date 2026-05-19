import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:mechanix_camera/core/utils/app_logger.dart';
import 'package:mechanix_camera/features/camera/data/camera_repository.dart';

part 'camera_settings_event.dart';
part 'camera_settings_state.dart';

class CameraSettingsBloc
    extends Bloc<CameraSettingsEvent, CameraSettingsState> {
  final CameraRepository _repository;

  bool _isOrientationListening = false;

  Timer? _exposureDebounce;

  CameraController get controller {
    final ctrl = _repository.controller;
    if (ctrl == null) {
      throw StateError('CameraController accessed before initialization.');
    }
    return ctrl;
  }

  CameraSettingsBloc(this._repository) : super(const CameraSettingsState()) {
    on<CameraOrientationChanged>(_onOrientationChanged);
    on<InitializeCameraSettings>(_onInitializeCameraSettings);
    on<SetFocusMode>(_onSetFocusMode);
    on<SetFocusPoint>(_onSetFocusPoint);
    on<SetExposureMode>(_onSetExposureMode);
    on<SetExposurePoint>(_onSetExposurePoint);
    on<SetExposureOffset>(_onSetExposureOffset);
    on<SetZoomLevel>(_onSetZoomLevel);
  }

  Future<void> _onInitializeCameraSettings(
    InitializeCameraSettings event,
    Emitter<CameraSettingsState> emit,
  ) async {
    if (_isOrientationListening) return;
    _isOrientationListening = true;

    final controller = _repository.controller;

    if (controller == null) {
      _isOrientationListening = false;
      return;
    }

    final maxExposureOffset = await controller.getMaxExposureOffset();
    final minExposureOffset = await controller.getMinExposureOffset();

    final maxZoomLevel = await controller.getMaxZoomLevel();
    final minZoomLevel = await controller.getMinZoomLevel();

    AppLogger.i(
      'Max Exposure Offset: $maxExposureOffset, Min Exposure Offset: $minExposureOffset',
    );

    emit(
      state.copyWith(
        maxExposureOffset: maxExposureOffset,
        minExposureOffset: minExposureOffset,
        maxZoomLevel: maxZoomLevel,
        minZoomLevel: minZoomLevel,
      ),
    );

    var lastOrientation = controller.value.deviceOrientation;

    controller.addListener(() {
      final orientation = controller.value.deviceOrientation;

      if (lastOrientation != orientation) {
        lastOrientation = orientation;

        add(CameraOrientationChanged(orientation: orientation));
      }
    });
  }

  void _onOrientationChanged(
    CameraOrientationChanged event,
    Emitter<CameraSettingsState> emit,
  ) {
    final current = state;
    if (current.orientation != event.orientation) {
      emit(current.copyWith(orientation: event.orientation));
    }
  }

  Future<void> _onSetFocusMode(
    SetFocusMode event,
    Emitter<CameraSettingsState> emit,
  ) async {
    await _repository.setFocusMode(event.focusMode);
    emit(state.copyWith(focusMode: event.focusMode));
  }

  Future<void> _onSetFocusPoint(
    SetFocusPoint event,
    Emitter<CameraSettingsState> emit,
  ) async {
    await _repository.setFocusPoint(event.point);
  }

  Future<void> _onSetExposureMode(
    SetExposureMode event,
    Emitter<CameraSettingsState> emit,
  ) async {
    await _repository.setExposureMode(event.exposureMode);
    emit(state.copyWith(exposureMode: event.exposureMode));
  }

  Future<void> _onSetExposurePoint(
    SetExposurePoint event,
    Emitter<CameraSettingsState> emit,
  ) async {
    await _repository.setExposurePoint(event.point);
  }

  Future<void> _onSetExposureOffset(
    SetExposureOffset event,
    Emitter<CameraSettingsState> emit,
  ) async {
    if (event.offset >= state.minExposureOffset &&
        event.offset <= state.maxExposureOffset) {
      _exposureDebounce?.cancel();
      _exposureDebounce = Timer(const Duration(milliseconds: 16), () async {
        await _repository.setExposureOffset(event.offset);
      });

      emit(state.copyWith(exposureOffset: event.offset));
    }
  }

  Future<void> _onSetZoomLevel(
    SetZoomLevel event,
    Emitter<CameraSettingsState> emit,
  ) async {
    if (event.zoomLevel >= state.minZoomLevel &&
        event.zoomLevel <= state.maxZoomLevel) {
      await _repository.setZoomLevel(event.zoomLevel);

      emit(state.copyWith(zoomLevel: event.zoomLevel));
    }
  }
}

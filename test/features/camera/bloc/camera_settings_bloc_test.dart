import 'package:bloc_test/bloc_test.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mechanix_camera/features/camera/bloc/camera_settings/camera_settings_bloc.dart';
import 'package:mechanix_camera/features/camera/data/camera_repository.dart';
import 'package:mocktail/mocktail.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockCameraRepository extends Mock implements CameraRepository {}

class MockCameraController extends Mock implements CameraController {}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockCameraRepository mockRepo;
  late MockCameraController mockController;

  setUpAll(() {
    registerFallbackValue(FocusMode.auto);
    registerFallbackValue(ExposureMode.auto);
    registerFallbackValue(const Offset(0.5, 0.5));
  });

  setUp(() {
    mockRepo = MockCameraRepository();
    mockController = MockCameraController();

    // Stub default controller values to avoid Null/MissingStubError
    when(
      () => mockController.getMaxExposureOffset(),
    ).thenAnswer((_) async => 2.0);
    when(
      () => mockController.getMinExposureOffset(),
    ).thenAnswer((_) async => -2.0);
    when(() => mockController.getMaxZoomLevel()).thenAnswer((_) async => 8.0);
    when(() => mockController.getMinZoomLevel()).thenAnswer((_) async => 1.0);
  });

  // =========================================================================
  group('controller getter', () {
    test('throws StateError when controller is null', () {
      final bloc = CameraSettingsBloc(mockRepo);
      when(() => mockRepo.controller).thenReturn(null);
      expect(() => bloc.controller, throwsStateError);
    });

    test('returns controller when controller is not null', () {
      final bloc = CameraSettingsBloc(mockRepo);
      when(() => mockRepo.controller).thenReturn(mockController);
      expect(bloc.controller, mockController);
    });
  });

  // =========================================================================
  group('Initial state', () {
    test('initial state is landscapeRight', () {
      expect(
        CameraSettingsBloc(mockRepo).state,
        const CameraSettingsState(
          orientation: DeviceOrientation.landscapeRight,
        ),
      );
    });
  });

  // =========================================================================
  group('CameraOrientationChanged', () {
    blocTest<CameraSettingsBloc, CameraSettingsState>(
      'emits updated orientation when orientation changes',
      build: () => CameraSettingsBloc(mockRepo),
      act: (bloc) {
        bloc.add(
          const CameraOrientationChanged(
            orientation: DeviceOrientation.landscapeLeft,
          ),
        );
      },
      expect: () => [
        const CameraSettingsState(orientation: DeviceOrientation.landscapeLeft),
      ],
    );

    blocTest<CameraSettingsBloc, CameraSettingsState>(
      'does not emit when orientation is same as current state',
      build: () => CameraSettingsBloc(mockRepo),
      act: (bloc) {
        bloc.add(
          const CameraOrientationChanged(
            orientation: DeviceOrientation.landscapeRight,
          ),
        );
      },
      expect: () => [],
    );

    blocTest<CameraSettingsBloc, CameraSettingsState>(
      'emits multiple orientation updates correctly',
      build: () => CameraSettingsBloc(mockRepo),
      act: (bloc) {
        bloc
          ..add(
            const CameraOrientationChanged(
              orientation: DeviceOrientation.landscapeLeft,
            ),
          )
          ..add(
            const CameraOrientationChanged(
              orientation: DeviceOrientation.landscapeRight,
            ),
          )
          ..add(
            const CameraOrientationChanged(
              orientation: DeviceOrientation.portraitDown,
            ),
          );
      },
      expect: () => [
        const CameraSettingsState(orientation: DeviceOrientation.landscapeLeft),
        const CameraSettingsState(
          orientation: DeviceOrientation.landscapeRight,
        ),
        const CameraSettingsState(orientation: DeviceOrientation.portraitDown),
      ],
    );
  });

  // =========================================================================
  group('InitializeCameraSettings', () {
    test('adds listener to controller when listener starts', () async {
      when(() => mockRepo.controller).thenReturn(mockController);

      when(() => mockController.value).thenReturn(
        const CameraValue(
          isInitialized: true,
          isRecordingVideo: false,
          isTakingPicture: false,
          isStreamingImages: false,
          isRecordingPaused: false,
          flashMode: FlashMode.off,
          exposureMode: ExposureMode.auto,
          focusMode: FocusMode.auto,
          exposurePointSupported: true,
          focusPointSupported: true,
          deviceOrientation: DeviceOrientation.portraitUp,
          description: CameraDescription(
            name: '0',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 90,
          ),
        ),
      );

      when(() => mockController.addListener(any())).thenAnswer((_) {});

      final bloc = CameraSettingsBloc(mockRepo);

      bloc.add(const InitializeCameraSettings());

      await Future<void>.delayed(Duration.zero);

      verify(() => mockController.addListener(any())).called(1);

      await bloc.close();
    });

    test('does nothing when controller is null', () async {
      when(() => mockRepo.controller).thenReturn(null);

      final bloc = CameraSettingsBloc(mockRepo);

      bloc.add(const InitializeCameraSettings());

      await Future<void>.delayed(Duration.zero);

      verifyNever(() => mockController.addListener(any()));

      await bloc.close();
    });

    blocTest<CameraSettingsBloc, CameraSettingsState>(
      'emits exposure and zoom limits during initialization',
      build: () {
        when(() => mockRepo.controller).thenReturn(mockController);

        when(() => mockController.value).thenReturn(
          const CameraValue(
            isInitialized: true,
            isRecordingVideo: false,
            isTakingPicture: false,
            isStreamingImages: false,
            isRecordingPaused: false,
            flashMode: FlashMode.off,
            exposureMode: ExposureMode.auto,
            focusMode: FocusMode.auto,
            exposurePointSupported: true,
            focusPointSupported: true,
            deviceOrientation: DeviceOrientation.portraitUp,
            description: CameraDescription(
              name: '0',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 90,
            ),
          ),
        );

        when(() => mockController.addListener(any())).thenAnswer((_) {});

        return CameraSettingsBloc(mockRepo);
      },
      act: (bloc) => bloc.add(const InitializeCameraSettings()),
      expect: () => [
        const CameraSettingsState(
          minExposureOffset: -2.0,
          maxExposureOffset: 2.0,
          minZoomLevel: 1.0,
          maxZoomLevel: 8.0,
        ),
      ],
    );

    test('does not register listener multiple times', () async {
      when(() => mockRepo.controller).thenReturn(mockController);

      when(() => mockController.value).thenReturn(
        const CameraValue(
          isInitialized: true,
          isRecordingVideo: false,
          isTakingPicture: false,
          isStreamingImages: false,
          isRecordingPaused: false,
          flashMode: FlashMode.off,
          exposureMode: ExposureMode.auto,
          focusMode: FocusMode.auto,
          exposurePointSupported: true,
          focusPointSupported: true,
          deviceOrientation: DeviceOrientation.portraitUp,
          description: CameraDescription(
            name: '0',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 90,
          ),
        ),
      );

      when(() => mockController.addListener(any())).thenAnswer((_) {});

      final bloc = CameraSettingsBloc(mockRepo);

      bloc.add(const InitializeCameraSettings());
      bloc.add(const InitializeCameraSettings());
      bloc.add(const InitializeCameraSettings());

      await Future<void>.delayed(Duration.zero);

      verify(() => mockController.addListener(any())).called(1);

      await bloc.close();
    });

    test(
      'triggers CameraOrientationChanged when device orientation changes',
      () async {
        when(() => mockRepo.controller).thenReturn(mockController);

        late void Function() listenerCallback;
        when(() => mockController.addListener(any())).thenAnswer((invocation) {
          listenerCallback =
              invocation.positionalArguments[0] as void Function();
        });

        var currentOrientation = DeviceOrientation.portraitUp;
        when(() => mockController.value).thenAnswer(
          (_) => CameraValue(
            isInitialized: true,
            isRecordingVideo: false,
            isTakingPicture: false,
            isStreamingImages: false,
            isRecordingPaused: false,
            flashMode: FlashMode.off,
            exposureMode: ExposureMode.auto,
            focusMode: FocusMode.auto,
            exposurePointSupported: true,
            focusPointSupported: true,
            deviceOrientation: currentOrientation,
            description: const CameraDescription(
              name: '0',
              lensDirection: CameraLensDirection.back,
              sensorOrientation: 90,
            ),
          ),
        );

        final bloc = CameraSettingsBloc(mockRepo);
        bloc.add(const InitializeCameraSettings());
        await Future<void>.delayed(Duration.zero);

        // Now, change orientation and trigger listener
        currentOrientation = DeviceOrientation.landscapeLeft;
        listenerCallback();

        await Future<void>.delayed(Duration.zero);

        expect(bloc.state.orientation, DeviceOrientation.landscapeLeft);

        await bloc.close();
      },
    );
  });

  // =========================================================================
  group('SetFocusMode', () {
    blocTest<CameraSettingsBloc, CameraSettingsState>(
      'emits updated FocusMode state and calls repository when SetFocusMode is added',
      build: () {
        when(() => mockRepo.setFocusMode(any())).thenAnswer((_) async {});
        return CameraSettingsBloc(mockRepo);
      },
      act: (bloc) => bloc.add(const SetFocusMode(focusMode: FocusMode.locked)),
      expect: () => [const CameraSettingsState(focusMode: FocusMode.locked)],
      verify: (_) {
        verify(() => mockRepo.setFocusMode(FocusMode.locked)).called(1);
      },
    );

    blocTest<CameraSettingsBloc, CameraSettingsState>(
      'emits error when repository throws in SetFocusMode',
      build: () {
        when(
          () => mockRepo.setFocusMode(any()),
        ).thenThrow(Exception('focus failed'));

        return CameraSettingsBloc(mockRepo);
      },
      act: (bloc) => bloc.add(const SetFocusMode(focusMode: FocusMode.locked)),
      errors: () => [isA<Exception>()],
    );
  });

  // =========================================================================
  group('SetFocusPoint', () {
    blocTest<CameraSettingsBloc, CameraSettingsState>(
      'calls repository setFocusPoint when SetFocusPoint is added',
      build: () {
        when(() => mockRepo.setFocusPoint(any())).thenAnswer((_) async {});
        return CameraSettingsBloc(mockRepo);
      },
      act: (bloc) => bloc.add(const SetFocusPoint(point: Offset(0.5, 0.5))),
      expect: () => [],
      verify: (_) {
        verify(() => mockRepo.setFocusPoint(const Offset(0.5, 0.5))).called(1);
      },
    );
  });

  // =========================================================================
  group('SetExposureMode', () {
    blocTest<CameraSettingsBloc, CameraSettingsState>(
      'emits updated ExposureMode state and calls repository when SetExposureMode is added',
      build: () {
        when(() => mockRepo.setExposureMode(any())).thenAnswer((_) async {});
        return CameraSettingsBloc(mockRepo);
      },
      act: (bloc) =>
          bloc.add(const SetExposureMode(exposureMode: ExposureMode.locked)),
      expect: () => [
        const CameraSettingsState(exposureMode: ExposureMode.locked),
      ],
      verify: (_) {
        verify(() => mockRepo.setExposureMode(ExposureMode.locked)).called(1);
      },
    );
  });

  // =========================================================================
  group('SetExposurePoint', () {
    blocTest<CameraSettingsBloc, CameraSettingsState>(
      'calls repository setExposurePoint when SetExposurePoint is added',
      build: () {
        when(() => mockRepo.setExposurePoint(any())).thenAnswer((_) async {});
        return CameraSettingsBloc(mockRepo);
      },
      act: (bloc) => bloc.add(const SetExposurePoint(point: Offset(0.5, 0.5))),
      expect: () => [],
      verify: (_) {
        verify(
          () => mockRepo.setExposurePoint(const Offset(0.5, 0.5)),
        ).called(1);
      },
    );
  });

  // =========================================================================
  group('SetExposureOffset', () {
    blocTest<CameraSettingsBloc, CameraSettingsState>(
      'emits updated exposureOffset and locked mode when in-bounds SetExposureOffset is added',
      build: () {
        when(() => mockRepo.setExposureOffset(any())).thenAnswer((_) async {});
        when(() => mockRepo.setExposureMode(any())).thenAnswer((_) async {});
        return CameraSettingsBloc(mockRepo);
      },
      seed: () => const CameraSettingsState(
        minExposureOffset: -2.0,
        maxExposureOffset: 2.0,
      ),
      act: (bloc) => bloc.add(const SetExposureOffset(offset: 1.0)),
      expect: () => [
        const CameraSettingsState(
          minExposureOffset: -2.0,
          maxExposureOffset: 2.0,
          exposureOffset: 1.0,
          exposureMode: ExposureMode.locked,
        ),
      ],
      verify: (_) {
        verify(() => mockRepo.setExposureOffset(1.0)).called(1);
        verify(() => mockRepo.setExposureMode(ExposureMode.locked)).called(1);
      },
    );

    blocTest<CameraSettingsBloc, CameraSettingsState>(
      'accepts exposure offset at min boundary',
      build: () {
        when(() => mockRepo.setExposureOffset(any())).thenAnswer((_) async {});
        when(() => mockRepo.setExposureMode(any())).thenAnswer((_) async {});
        return CameraSettingsBloc(mockRepo);
      },
      seed: () => const CameraSettingsState(
        minExposureOffset: -2,
        maxExposureOffset: 2,
      ),
      act: (bloc) => bloc.add(const SetExposureOffset(offset: -2)),
      verify: (_) {
        verify(() => mockRepo.setExposureOffset(-2)).called(1);
      },
    );

    blocTest<CameraSettingsBloc, CameraSettingsState>(
      'accepts exposure offset at max boundary',
      build: () {
        when(() => mockRepo.setExposureOffset(any())).thenAnswer((_) async {});
        when(() => mockRepo.setExposureMode(any())).thenAnswer((_) async {});
        return CameraSettingsBloc(mockRepo);
      },
      seed: () => const CameraSettingsState(
        minExposureOffset: -2,
        maxExposureOffset: 2,
      ),
      act: (bloc) => bloc.add(const SetExposureOffset(offset: 2)),
      verify: (_) {
        verify(() => mockRepo.setExposureOffset(2)).called(1);
      },
    );

    blocTest<CameraSettingsBloc, CameraSettingsState>(
      'ignores SetExposureOffset if offset is out of bounds',
      build: () {
        return CameraSettingsBloc(mockRepo);
      },
      seed: () => const CameraSettingsState(
        minExposureOffset: -2.0,
        maxExposureOffset: 2.0,
      ),
      act: (bloc) => bloc.add(const SetExposureOffset(offset: 3.0)),
      expect: () => [],
      verify: (_) {
        verifyNever(() => mockRepo.setExposureOffset(any()));
        verifyNever(() => mockRepo.setExposureMode(any()));
      },
    );
  });

  // =========================================================================
  group('SetZoomLevel', () {
    blocTest<CameraSettingsBloc, CameraSettingsState>(
      'emits updated zoomLevel and calls repository when in-bounds SetZoomLevel is added',
      build: () {
        when(() => mockRepo.setZoomLevel(any())).thenAnswer((_) async {});
        return CameraSettingsBloc(mockRepo);
      },
      seed: () =>
          const CameraSettingsState(minZoomLevel: 1.0, maxZoomLevel: 8.0),
      act: (bloc) => bloc.add(const SetZoomLevel(zoomLevel: 2.0)),
      expect: () => [
        const CameraSettingsState(
          minZoomLevel: 1.0,
          maxZoomLevel: 8.0,
          zoomLevel: 2.0,
        ),
      ],
      verify: (_) {
        verify(() => mockRepo.setZoomLevel(2.0)).called(1);
      },
    );

    blocTest<CameraSettingsBloc, CameraSettingsState>(
      'accepts zoom level at min boundary',
      build: () {
        when(() => mockRepo.setZoomLevel(any())).thenAnswer((_) async {});
        return CameraSettingsBloc(mockRepo);
      },
      seed: () => const CameraSettingsState(minZoomLevel: 1, maxZoomLevel: 8),
      act: (bloc) => bloc.add(const SetZoomLevel(zoomLevel: 1)),
      verify: (_) {
        verify(() => mockRepo.setZoomLevel(1)).called(1);
      },
    );

    blocTest<CameraSettingsBloc, CameraSettingsState>(
      'accepts zoom level at max boundary',
      build: () {
        when(() => mockRepo.setZoomLevel(any())).thenAnswer((_) async {});
        return CameraSettingsBloc(mockRepo);
      },
      seed: () => const CameraSettingsState(minZoomLevel: 1, maxZoomLevel: 8),
      act: (bloc) => bloc.add(const SetZoomLevel(zoomLevel: 8)),
      verify: (_) {
        verify(() => mockRepo.setZoomLevel(8)).called(1);
      },
    );

    blocTest<CameraSettingsBloc, CameraSettingsState>(
      'ignores SetZoomLevel if zoomLevel is out of bounds',
      build: () {
        return CameraSettingsBloc(mockRepo);
      },
      seed: () =>
          const CameraSettingsState(minZoomLevel: 1.0, maxZoomLevel: 8.0),
      act: (bloc) => bloc.add(const SetZoomLevel(zoomLevel: 9.0)),
      expect: () => [],
      verify: (_) {
        verifyNever(() => mockRepo.setZoomLevel(any()));
      },
    );

    group('CameraSettingsState', () {
      test('copyWith updates only provided fields', () {
        const state = CameraSettingsState();

        final updated = state.copyWith(zoomLevel: 3);

        expect(updated.zoomLevel, 3);
        expect(updated.focusMode, state.focusMode);
        expect(updated.exposureMode, state.exposureMode);
      });

      test('states with same values are equal', () {
        const state1 = CameraSettingsState(zoomLevel: 2);

        const state2 = CameraSettingsState(zoomLevel: 2);

        expect(state1, equals(state2));
      });
    });
  });
}

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mechanix_camera/core/utils/constants.dart';
import 'package:mechanix_camera/core/widgets/images.dart';
import 'package:mechanix_camera/features/camera/data/camera_repository.dart';
import 'package:mechanix_camera/features/camera/presentation/screen/camera_screen.dart';
import 'package:mechanix_camera/features/camera/presentation/widgets/camera/settings/zoom_bar.dart';
import 'package:mechanix_camera/features/camera/presentation/widgets/camera/settings_bar.dart';
import 'package:mechanix_camera/features/camera/presentation/widgets/camera/settings_button.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers/test_app_wrapper.dart';

class MockCameraRepository extends Mock implements CameraRepository {}

class MockCameraController extends Mock implements CameraController {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(FocusMode.auto);
    registerFallbackValue(ExposureMode.auto);
  });

  group('Camera Settings Flow Integration Test', () {
    late MockCameraRepository mockRepo;
    late MockCameraController mockController;

    setUp(() {
      mockRepo = MockCameraRepository();
      mockController = MockCameraController();

      // Stub default camera initialization values
      when(() => mockRepo.initialize()).thenAnswer((_) async => mockController);
      when(() => mockRepo.controller).thenReturn(mockController);
      when(() => mockRepo.dispose()).thenAnswer((_) async {});
      when(() => mockRepo.setFocusMode(any())).thenAnswer((_) async {});
      when(() => mockRepo.setExposureMode(any())).thenAnswer((_) async {});
      when(() => mockRepo.setZoomLevel(any())).thenAnswer((_) async {});

      const controllerValue = CameraValue(
        isInitialized: true,
        errorDescription: null,
        previewSize: Size(1920, 1080),
        isRecordingVideo: false,
        isTakingPicture: false,
        isStreamingImages: false,
        isRecordingPaused: false,
        flashMode: FlashMode.off,
        exposureMode: ExposureMode.auto,
        focusMode: FocusMode.auto,
        deviceOrientation: DeviceOrientation.portraitUp,
        lockedCaptureOrientation: null,
        exposurePointSupported: true,
        focusPointSupported: true,
        description: CameraDescription(
          name: '0',
          lensDirection: CameraLensDirection.back,
          sensorOrientation: 0,
        ),
      );

      when(() => mockController.value).thenReturn(controllerValue);
      when(() => mockController.buildPreview()).thenReturn(Container());
      when(
        () => mockController.getMaxExposureOffset(),
      ).thenAnswer((_) async => 2.0);
      when(
        () => mockController.getMinExposureOffset(),
      ).thenAnswer((_) async => -2.0);
      when(() => mockController.getMaxZoomLevel()).thenAnswer((_) async => 8.0);
      when(() => mockController.getMinZoomLevel()).thenAnswer((_) async => 1.0);
    });

    testWidgets(
      'Open settings bar, open zoom panel, select zoom level, and close settings',
      (tester) async {
        // 1. Build & Settle the CameraScreen
        await tester.pumpWidget(
          TestAppWrapper(repository: mockRepo, child: const CameraScreen()),
        );
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // 2. Locate SettingsButton and click to open the settings panel
        final settingsButton = find.byType(SettingsButton);
        expect(settingsButton, findsOneWidget);
        await tester.tap(settingsButton);
        await tester.pumpAndSettle();

        // 3. Verify that the SettingsBar overlay is visible
        expect(find.byType(SettingsBar), findsOneWidget);

        // 4. Click the ZoomButton inside the SettingsBar
        final zoomButton = find.byIcon(Icons.zoom_in);
        expect(zoomButton, findsOneWidget);
        await tester.tap(zoomButton);
        await tester.pumpAndSettle();

        // 5. Verify that the ZoomBar options (like 1x, 2x, 4x, 8x) are displayed
        expect(find.byType(ZoomBar), findsOneWidget);
        expect(find.text('1x'), findsOneWidget);
        expect(find.text('2x'), findsOneWidget);
        expect(find.text('4x'), findsOneWidget);
        expect(find.text('8x'), findsOneWidget);

        // 6. Select a zoom level (2x) and verify repository/bloc interaction
        await tester.tap(find.text('2x'));
        await tester.pumpAndSettle();

        // Verify repository zoom interaction
        verify(() => mockRepo.setZoomLevel(2.0)).called(1);

        // 7. Locate and tap the close button to close the settings panel
        final closeButton = find.descendant(
          of: find.byType(SettingsBar),
          matching: find.byWidgetPredicate(
            (widget) => widget is Images && widget.image == AppConstants.close,
          ),
        );
        expect(closeButton, findsOneWidget);
        await tester.tap(closeButton);
        await tester.pumpAndSettle();

        // 8. Verify that the SettingsBar overlay is no longer visible
        expect(find.byType(SettingsBar), findsNothing);
      },
    );
  });
}

# Mechanix Camera

A camera application built for the Mechanix ecosystem using `flutter-elinux` and the `camera_elinux` plugin.

## Features

- Capture images
- Zoom control support
- Focus control support
- Exposure control support
- Captured image preview
- Save captured images locally
- Unit tests
- BLoC tests
- Integration tests

## Getting Started

### Prerequisites

Make sure the following are installed:

- flutter
- flutter-elinux
- eLinux compatible environment/device
- Camera device access

## Installation

Clone the repository:

```bash
git clone https://github.com/mecha-org/mechanix-camera.git
cd mechanix-camera
```

Install dependencies:

```bash
flutter-elinux pub get
```

## camera_elinux Dependency

This project uses the eLinux camera plugin from Git:

```yaml
camera_elinux:
  git:
    url: https://github.com/ojas-mecha/flutter-elinux-plugins.git
    path: packages/camera
    ref: main
```

## Run the Application

### Run on eLinux

```bash
flutter-elinux run
```

## Testing

### Run Unit & BLoC Tests

```bash
flutter-elinux test
```

### Run Integration Tests

```bash
flutter-elinux test integration_test/<test-file-name>
```

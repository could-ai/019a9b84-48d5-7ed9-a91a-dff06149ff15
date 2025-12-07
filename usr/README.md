# couldai_user_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Building for Linux

To build this application for Linux, follow these steps:

### 1. Install Linux Build Requirements
You need to install the necessary development tools. On Ubuntu/Debian:

```bash
sudo apt-get update
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev
```

### 2. Enable Linux Desktop Support
Ensure Flutter has Linux desktop support enabled:

```bash
flutter config --enable-linux-desktop
```

### 3. Create Linux Configuration
If the `linux/` directory is missing from your project, generate it:

```bash
flutter create --platforms=linux .
```

### 4. Build the Application
Run the build command to create the executable:

```bash
flutter build linux
```

The executable will be located in `build/linux/x64/release/bundle/`.

### 5. Run Locally
To run the app in debug mode on your Linux machine:

```bash
flutter run -d linux
```

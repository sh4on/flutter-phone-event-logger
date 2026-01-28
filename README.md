# Flutter Phone Event Logger

A private security application built with Flutter and Android Native (Kotlin) that monitors and logs system-wide keystrokes and events using Android's Accessibility Service.

## 🚀 How It Works
This app uses a "bridge" architecture to capture events that happen outside of the Flutter application.

### 1. The Android Native Layer (Kotlin)
Since Flutter is sandboxed (it can't see what happens in other apps), we use a native `AccessibilityService`.

- **Event Listener**: The service is registered with the Android OS to listen for `TYPE_VIEW_TEXT_CHANGED` events.
- **Global Monitoring**: Once the user grants permission, Android sends a callback to our Kotlin code every time text is modified in any app (browser, messages, etc.).
- **Companion Object**: We use a Kotlin companion object to hold a static reference to the service, allowing the `MainActivity` to "hook" into the live data stream.

### 2. The Communication Bridge (MethodChannel)
To get the data from the background Kotlin service to the Flutter UI:

- **Invoke Method**: When a keystroke is detected, the Kotlin side calls `channel.invokeMethod("onKeyStroke", text)`.
- **Main Thread**: The data is pushed to the UI thread using `runOnUiThread` to ensure Flutter can safely update the screen.

### 3. The Flutter Layer (Dart)
- **MethodCallHandler**: The Flutter app listens on the `MethodChannel` for the "onKeyStroke" signal.
- **Local Storage**: Logs are saved locally using the `path_provider` package to a private directory (`security_logs.txt`), ensuring your data stays on your device and isn't lost when the app closes.

## 🛠 Setup & Installation
### 1. Permissions (Crucial)
Because this app monitors sensitive input, Android's security will block it by default.

On your Device (or any Android 13+) device:
1. Install the app.
2. Go to **Settings > Apps > App Management > flutter_phone_events**.
3. Tap the three dots (⋮) in the top right corner.
4. Select **"Allow restricted settings"**.
5. Now go to **Settings > Additional Settings > Accessibility**.
6. Find **flutter_phone_events** and toggle it **ON**.

### 2. File Structure
- `android/app/src/main/kotlin/.../MyAccessibilityService.kt`: The native event listener.
- `android/app/src/main/res/xml/accessibility_service_config.xml`: Defines what events to track.
- `lib/main.dart`: The Flutter UI and log management.

## 🔒 Security Warning
This app is for personal use only. By design, this app creates a record of everything you type.

- **Do not share** the generated `security_logs.txt` file.
- **Do not grant** this app network permissions if you want to ensure the data never leaves your device.
- The logs are stored in `getApplicationDocumentsDirectory()`, which is private to the app and generally inaccessible to other apps.

## 📜 License
This project is for educational and personal security use only. Use responsibly.

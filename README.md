# Flutter Phone Event Logger

A private security application built with Flutter and Android Native (Kotlin) that monitors and logs system-wide keystrokes and events using Android's Accessibility Service. This version utilizes **GetX** for reactive state management and clean architecture.

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

### 3. The Flutter Layer (Dart & GetX)
- **LoggerController**: A `GetxController` that manages the `MethodChannel` lifecycle, reactive log data, and background tasks.
- **MethodCallHandler**: The controller listens on the `MethodChannel` for the "onKeyStroke" signal and updates an `obs` list.
- **Local Storage**: Logs are saved locally using the `path_provider` package to a private directory (`security_logs.txt`).
- **Telegram Integration**: Every 2 minutes, the controller automatically sends the log file to a Telegram bot (if configured via `.env`) and clears the local file.

## 🛠 Setup & Installation

### 1. Telegram Bot Setup
To receive logs on your phone, you need to create a Telegram bot and configure the `.env` file.

#### Step A: Create your Bot & Get the Token
1. Search for **@BotFather** on Telegram and click **Start**.
2. Send the command `/newbot`.
3. Follow the prompts:
   - **Name**: Give it a display name (e.g., "My Security Bot").
   - **Username**: Give it a unique username ending in "bot" (e.g., `my_private_logger_bot`).
4. BotFather will send you an **HTTP API Access Token** (e.g., `74839201:AAHk...`). Copy this into your `.env` as `BOOT_TOKEN`.

#### Step B: Get your Chat ID
You cannot just make up a Chat ID. To find yours:
1. Search for **@userinfobot** on Telegram and click **Start**.
2. It will reply with your **Id** (a long number). Copy this into your `.env` as `CHAT_ID`.

#### Step C: Initiate the Bot
This is a common "gotcha": Your bot cannot message you until you message it first.
1. Click the link BotFather gave you (e.g., `t.me/your_bot_name`).
2. Click **Start** in that chat. This "opens the door" for the bot to send you logs.

### 2. Environment Configuration
Create a `.env` file in the root directory with the following:
```env
BOOT_TOKEN=your_telegram_bot_token_here
CHAT_ID=your_telegram_chat_id_here
```

### 3. Android Permissions (Crucial)
Because this app monitors sensitive input, Android's security will block it by default.

On your Realme (or any Android 13+) device:
1. Install the app.
2. Go to **Settings > Apps > App Management > flutter_phone_events**.
3. Tap the three dots (⋮) in the top right corner.
4. Select **"Allow restricted settings"**.
5. Now go to **Settings > Additional Settings > Accessibility**.
6. Find **flutter_phone_events** and toggle it **ON**.

### 4. File Structure
- `android/app/src/main/kotlin/.../MyAccessibilityService.kt`: The native event listener.
- `android/app/src/main/res/xml/accessibility_service_config.xml`: Defines what events to track.
- `lib/logger_controller.dart`: The GetX business logic layer.
- `lib/main.dart`: The UI layer and app entry point.

## 🔒 Security Warning
This app is for personal use only. By design, this app creates a record of everything you type.

- **Do not share** the generated `security_logs.txt` file.
- **Do not grant** this app network permissions if you do not want data sent to Telegram.
- The logs are stored in `getApplicationDocumentsDirectory()`, which is private to the app and generally inaccessible to other apps.

## 📜 License
This project is for educational and personal security use only. Use responsibly.

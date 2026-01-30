package com.example.flutter_phone_events

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.app/events"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.app/events")

        MyAccessibilityService.onEventCaptured = { text ->
            // Use a metered check to ensure the engine is still attached
            runOnUiThread {
                try {
                    channel.invokeMethod("onKeyStroke", text)
                } catch (e: Exception) {
                    // Flutter is likely in the background or killed
                }
            }
        }
    }
}
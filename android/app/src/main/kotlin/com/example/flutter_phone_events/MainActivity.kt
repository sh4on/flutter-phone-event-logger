package com.example.flutter_phone_events

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.app/events"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        // Listen for events coming from the Accessibility Service
        MyAccessibilityService.onEventCaptured = { text ->
            // Use runOnUiThread to ensure Flutter gets the data on the main thread
            runOnUiThread {
                channel.invokeMethod("onKeyStroke", text)
            }
        }
    }
}
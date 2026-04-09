package com.example.flutter_phone_events

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.app/events"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        // Hook Flutter UI in — service will call this only when UI is alive
        MyAccessibilityService.flutterCallback = { text ->
            runOnUiThread {
                try {
                    channel.invokeMethod("onKeyStroke", text)
                } catch (e: Exception) {
                    // Flutter engine gone, safe to ignore
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        requestBatteryOptimizationExemption()
    }

    private fun requestBatteryOptimizationExemption() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val pm = getSystemService(POWER_SERVICE) as PowerManager
            if (!pm.isIgnoringBatteryOptimizations(packageName)) {
                try {
                    val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
                    intent.data = Uri.parse("package:$packageName")
                    startActivity(intent)
                } catch (e: Exception) {
                    // Some OEMs block this intent — fail silently
                    e.printStackTrace()
                }
            }
        }
    }

    override fun onDestroy() {
        // Unhook Flutter when UI is killed — service keeps running on its own
        MyAccessibilityService.flutterCallback = null
        super.onDestroy()
    }
}
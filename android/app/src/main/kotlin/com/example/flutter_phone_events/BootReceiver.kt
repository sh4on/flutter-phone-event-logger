package com.example.flutter_phone_events

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Settings
import android.text.TextUtils

class BootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
            intent.action == "android.intent.action.QUICKBOOT_POWERON" // HTC/some OEMs
        ) {
            // Only re-enable if user had previously granted accessibility permission.
            // We can't programmatically START an AccessibilityService — Android doesn't allow it.
            // BUT if it was enabled before reboot, Android restores it automatically.
            // This receiver's job is to wake the app process so the service can reconnect.
            if (isAccessibilityServiceEnabled(context)) {
                // Launch the app's main activity invisibly just to wake the process
                val launchIntent = Intent(context, MainActivity::class.java).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
                }
                context.startActivity(launchIntent)
            }
        }
    }

    private fun isAccessibilityServiceEnabled(context: Context): Boolean {
        val expectedService = "${context.packageName}/${MyAccessibilityService::class.java.canonicalName}"
        val enabledServices = Settings.Secure.getString(
            context.contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false

        val splitter = TextUtils.SimpleStringSplitter(':')
        splitter.setString(enabledServices)
        while (splitter.hasNext()) {
            if (splitter.next().equals(expectedService, ignoreCase = true)) return true
        }
        return false
    }
}
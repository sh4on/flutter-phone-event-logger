package com.example.flutter_phone_events
import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import io.flutter.plugin.common.MethodChannel

class MyAccessibilityService : AccessibilityService() {

    // This allows the MainActivity to "hook" into the service
    companion object {
        var instance: MyAccessibilityService? = null
        var onEventCaptured: ((String) -> Unit)? = null
    }

    override fun onServiceConnected() {
        instance = this
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        if (event.eventType == AccessibilityEvent.TYPE_VIEW_TEXT_CHANGED) {
            val typedText = event.text.toString()
            // Send the data to the listener (MainActivity)
            onEventCaptured?.invoke(typedText)
        }
    }

    override fun onUnbind(intent: android.content.Intent?): Boolean {
        instance = null
        return super.onUnbind(intent)
    }

    override fun onInterrupt() {}
}
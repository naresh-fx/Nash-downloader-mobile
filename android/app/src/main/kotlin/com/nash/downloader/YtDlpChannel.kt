package com.nash.downloader

import android.content.Context
import android.os.Handler
import android.os.Looper
import com.yausername.youtubedl_android.YoutubeDL
import com.yausername.youtubedl_android.YoutubeDLRequest
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.Executors

/**
 * Bridges Dart calls to the youtubedl-android library, which bundles yt-dlp
 * (via Chaquopy) for Android — the same extraction engine the desktop app
 * uses through Python's yt-dlp package, so format selectors and behavior
 * line up between both apps.
 */
class YtDlpChannel(private val context: Context) : MethodChannel.MethodCallHandler {

    var progressSink: EventChannel.EventSink? = null
    private val executor = Executors.newCachedThreadPool()
    private val mainHandler = Handler(Looper.getMainLooper())
    private val activeProcessIds = mutableMapOf<String, String>()

    private fun outputDir(): File {
        val dir = File(context.getExternalFilesDir(null), "NashDownloader")
        if (!dir.exists()) dir.mkdirs()
        return dir
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getVideoInfo" -> getVideoInfo(call, result)
            "startDownload" -> startDownload(call, result)
            "cancelDownload" -> cancelDownload(call, result)
            else -> result.notImplemented()
        }
    }

    private fun getVideoInfo(call: MethodCall, result: MethodChannel.Result) {
        val url = call.argument<String>("url") ?: return result.error("bad_args", "url required", null)
        executor.execute {
            try {
                val info: com.yausername.youtubedl_android.VideoInfo = YoutubeDL.getInstance().getInfo(url as String)
                val map = mapOf(
                    "title" to (info.title ?: "Unknown title"),
                    "uploader" to (info.uploader ?: info.channel ?: "Unknown channel"),
                    "thumbnail" to (info.thumbnail ?: ""),
                    "duration" to (info.duration ?: 0)
                )
                mainHandler.post { result.success(map) }
            } catch (e: Exception) {
                mainHandler.post { result.error("fetch_failed", e.message, null) }
            }
        }
    }

    private fun startDownload(call: MethodCall, result: MethodChannel.Result) {
        val id = call.argument<String>("id") ?: return result.error("bad_args", "id required", null)
        val url = call.argument<String>("url") ?: return result.error("bad_args", "url required", null)
        val audioOnly = call.argument<Boolean>("audioOnly") ?: false
        val format = call.argument<String>("format") ?: "bestvideo+bestaudio/best"
        val clipStart = call.argument<Double>("clipStart")
        val clipEnd = call.argument<Double>("clipEnd")

        result.success(null) // ack immediately; progress/completion arrive on the EventChannel

        executor.execute {
            try {
                val outTemplate = File(outputDir(), "%(uploader)s - %(title)s.%(ext)s").absolutePath
                val request = YoutubeDLRequest(url)
                request.addOption("-o", outTemplate)

                if (audioOnly) {
                    request.addOption("-f", "bestaudio/best")
                    request.addOption("-x")
                    request.addOption("--audio-format", "mp3")
                } else {
                    request.addOption("-f", format)
                    request.addOption("--merge-output-format", "mp4")
                }

                if (clipStart != null && clipEnd != null && clipEnd > clipStart) {
                    val startS = clipStart.toInt()
                    val endS = clipEnd.toInt()
                    request.addOption("--download-sections", "*$startS-$endS")
                    request.addOption("--force-keyframes-at-cuts")
                }

                activeProcessIds[id] = id
                emit(id, 0.0, "downloading", "Starting…")

                YoutubeDL.getInstance().execute(request, id) { progress, _, line ->
                    val status = if (progress >= 100f) "processing" else "downloading"
                    emit(id, progress.toDouble(), status, line ?: "Downloading…")
                }

                activeProcessIds.remove(id)
                emit(id, 100.0, "done", "Complete!")
            } catch (e: Exception) {
                activeProcessIds.remove(id)
                emit(id, 0.0, "failed", e.message ?: "Download failed")
            }
        }
    }

    private fun cancelDownload(call: MethodCall, result: MethodChannel.Result) {
        val id = call.argument<String>("id")
        if (id != null && activeProcessIds.containsKey(id)) {
            YoutubeDL.getInstance().destroyProcessById(id)
            activeProcessIds.remove(id)
        }
        result.success(null)
    }

    private fun emit(id: String, percent: Double, status: String, title: String) {
        mainHandler.post {
            progressSink?.success(
                mapOf("id" to id, "percent" to percent, "status" to status, "title" to title)
            )
        }
    }
}

package com.nash.downloader

import android.app.Application
import com.yausername.ffmpeg.FFmpeg
import com.yausername.youtubedl_android.YoutubeDL
import com.yausername.youtubedl_android.YoutubeDLException

class NashDownloaderApp : Application() {
    override fun onCreate() {
        super.onCreate()
        try {
            YoutubeDL.getInstance().init(this)
            FFmpeg.getInstance().init(this)
        } catch (e: YoutubeDLException) {
            // Surfaced to the user as a failed getVideoInfo/startDownload call
            // rather than crashing app startup.
            e.printStackTrace()
        }
    }
}

import 'dart:async';
import 'package:flutter/services.dart';
import '../models/video_models.dart';

/// Talks to android/app/.../YtDlpChannel.kt, which wraps the
/// youtubedl-android library (yt-dlp compiled for Android via Chaquopy) —
/// the same download engine the desktop app uses, so format strings and
/// behavior are consistent across both apps.
class YtDlpService {
  YtDlpService._();
  static final YtDlpService instance = YtDlpService._();

  static const _method = MethodChannel('nash_downloader/ytdlp');
  static const _progress = EventChannel('nash_downloader/ytdlp_progress');

  Stream<Map<dynamic, dynamic>>? _progressStream;

  /// Fires for every progress tick across all active downloads.
  /// Payload: {id, percent, speed, status, title}
  Stream<Map<dynamic, dynamic>> get progressStream {
    _progressStream ??= _progress
        .receiveBroadcastStream()
        .map((event) => event as Map<dynamic, dynamic>);
    return _progressStream!;
  }

  Future<VideoInfo?> getVideoInfo(String url) async {
    try {
      final result = await _method.invokeMethod('getVideoInfo', {'url': url});
      if (result == null) return null;
      return VideoInfo.fromMap(Map<dynamic, dynamic>.from(result));
    } on PlatformException {
      return null;
    }
  }

  /// Starts a download natively; progress arrives on [progressStream]
  /// tagged with [id] so multiple queued downloads can be told apart.
  Future<void> startDownload({
    required String id,
    required String url,
    required bool audioOnly,
    required DownloadQuality quality,
    double? clipStart,
    double? clipEnd,
  }) async {
    await _method.invokeMethod('startDownload', {
      'id': id,
      'url': url,
      'audioOnly': audioOnly,
      'format': quality.formatSelector,
      'clipStart': clipStart,
      'clipEnd': clipEnd,
    });
  }

  Future<void> cancelDownload(String id) async {
    await _method.invokeMethod('cancelDownload', {'id': id});
  }
}

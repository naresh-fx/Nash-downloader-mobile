/// Quality presets. "best" is uncapped, so it pulls whatever the source
/// actually serves — 4K/8K on YouTube if the uploader provided it, not
/// hard-locked to 2160p, since some Instagram/YouTube sources exceed it.
enum DownloadQuality { best, q1080, q720 }

extension DownloadQualityX on DownloadQuality {
  String get label {
    switch (this) {
      case DownloadQuality.best:
        return 'Best quality (up to 4K)';
      case DownloadQuality.q1080:
        return '1080p';
      case DownloadQuality.q720:
        return '720p';
    }
  }

  /// yt-dlp format selector, same mapping used by the desktop app's q_map.
  String get formatSelector {
    switch (this) {
      case DownloadQuality.best:
        return 'bestvideo+bestaudio/best';
      case DownloadQuality.q1080:
        return 'bestvideo[height<=1080]+bestaudio/best[height<=1080]';
      case DownloadQuality.q720:
        return 'bestvideo[height<=720]+bestaudio/best[height<=720]';
    }
  }
}

enum SourcePlatform { youtube, instagram, unknown }

SourcePlatform detectPlatform(String url) {
  final u = url.toLowerCase();
  if (u.contains('instagram.com')) return SourcePlatform.instagram;
  if (u.contains('youtube.com') || u.contains('youtu.be')) {
    return SourcePlatform.youtube;
  }
  return SourcePlatform.unknown;
}

class VideoInfo {
  final String title;
  final String uploader;
  final String thumbnail;
  final int durationSeconds;

  VideoInfo({
    required this.title,
    required this.uploader,
    required this.thumbnail,
    required this.durationSeconds,
  });

  factory VideoInfo.fromMap(Map<dynamic, dynamic> map) {
    return VideoInfo(
      title: map['title'] ?? 'Unknown title',
      uploader: map['uploader'] ?? 'Unknown channel',
      thumbnail: map['thumbnail'] ?? '',
      durationSeconds: (map['duration'] ?? 0).toInt(),
    );
  }
}

enum DownloadStatus { queued, fetchingInfo, downloading, processing, done, failed }

class DownloadItem {
  final String id;
  final String url;
  final bool audioOnly;
  final DownloadQuality quality;
  final double? clipStart;
  final double? clipEnd;

  VideoInfo? info;
  DownloadStatus status;
  double progress; // 0-100
  String statusText;
  String? filePath;

  DownloadItem({
    required this.id,
    required this.url,
    required this.audioOnly,
    required this.quality,
    this.clipStart,
    this.clipEnd,
    this.status = DownloadStatus.queued,
    this.progress = 0,
    this.statusText = 'Queued',
  });
}

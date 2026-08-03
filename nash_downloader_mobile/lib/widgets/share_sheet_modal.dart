import 'package:flutter/material.dart';
import '../models/video_models.dart';
import '../services/ytdlp_service.dart';
import '../theme/app_theme.dart';

/// The bottom sheet that pops up over whatever app the user shared from.
/// Mirrors the mockup: thumbnail + title, format choice, cancel/save.
class ShareSheetModal extends StatefulWidget {
  final String url;
  final void Function(DownloadItem item) onConfirm;

  const ShareSheetModal({super.key, required this.url, required this.onConfirm});

  static Future<void> show(BuildContext context, String url, void Function(DownloadItem) onConfirm) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ShareSheetModal(url: url, onConfirm: onConfirm),
    );
  }

  @override
  State<ShareSheetModal> createState() => _ShareSheetModalState();
}

class _ShareSheetModalState extends State<ShareSheetModal> {
  VideoInfo? _info;
  bool _loading = true;
  bool _audioOnly = false;
  DownloadQuality _quality = DownloadQuality.best;

  @override
  void initState() {
    super.initState();
    _fetchInfo();
  }

  Future<void> _fetchInfo() async {
    final info = await YtDlpService.instance.getVideoInfo(widget.url);
    if (!mounted) return;
    setState(() {
      _info = info;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final platform = detectPlatform(widget.url);
    final platformLabel = switch (platform) {
      SourcePlatform.instagram => 'Instagram',
      SourcePlatform.youtube => 'YouTube',
      SourcePlatform.unknown => 'Link',
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: NashColors.sidebar,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(color: NashColors.inputFill, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Container(
                  width: 54,
                  height: 64,
                  color: NashColors.inputFill,
                  child: _info?.thumbnail.isNotEmpty == true
                      ? Image.network(_info!.thumbnail, fit: BoxFit.cover)
                      : const Icon(Icons.movie_outlined, color: NashColors.textMuted),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$platformLabel detected',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      _loading ? 'Fetching details…' : (_info?.title ?? 'Unknown title'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: NashColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Choose format', style: TextStyle(color: NashColors.textSecondary, fontSize: 11)),
          ),
          const SizedBox(height: 8),
          _FormatOption(
            label: DownloadQuality.best.label,
            selected: !_audioOnly && _quality == DownloadQuality.best,
            onTap: () => setState(() {
              _audioOnly = false;
              _quality = DownloadQuality.best;
            }),
          ),
          const SizedBox(height: 8),
          _FormatOption(
            label: '1080p',
            selected: !_audioOnly && _quality == DownloadQuality.q1080,
            onTap: () => setState(() {
              _audioOnly = false;
              _quality = DownloadQuality.q1080;
            }),
          ),
          const SizedBox(height: 8),
          _FormatOption(
            label: 'Audio only (mp3)',
            selected: _audioOnly,
            onTap: () => setState(() => _audioOnly = true),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: NashColors.textSecondary,
                    side: const BorderSide(color: NashColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    final item = DownloadItem(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      url: widget.url,
                      audioOnly: _audioOnly,
                      quality: _quality,
                    )..info = _info;
                    widget.onConfirm(item);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save to device'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormatOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FormatOption({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? NashColors.accent : NashColors.cardAlt,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: selected ? Colors.white : NashColors.textSecondary, fontSize: 12)),
            if (selected) const Icon(Icons.check, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}

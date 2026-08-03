import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/video_models.dart';
import '../services/ytdlp_service.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final _urlController = TextEditingController();
  VideoInfo? _preview;
  bool _fetchingPreview = false;
  bool _audioOnly = false;
  DownloadQuality _quality = DownloadQuality.best;

  DownloadItem? _active;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  /// Called by HomeScreenState.currentState?.startFromShare(url) when a
  /// link arrives via share sheet while this screen is visible, so the
  /// URL box reflects it too.
  void prefillUrl(String url) {
    _urlController.text = url;
    _fetchPreview(url);
  }

  Future<void> _fetchPreview(String url) async {
    if (url.trim().isEmpty) return;
    setState(() => _fetchingPreview = true);
    final info = await YtDlpService.instance.getVideoInfo(url.trim());
    if (!mounted) return;
    setState(() {
      _preview = info;
      _fetchingPreview = false;
    });
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null) {
      _urlController.text = data!.text!;
      _fetchPreview(data.text!);
    }
  }

  void _startDownload() {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    final item = DownloadItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      url: url,
      audioOnly: _audioOnly,
      quality: _quality,
    )..info = _preview;
    setState(() => _active = item);
    YtDlpService.instance.startDownload(
      id: item.id,
      url: url,
      audioOnly: _audioOnly,
      quality: _quality,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Image.asset('assets/logo.png', width: 30, height: 30),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nash Downloader',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                    Text('Download videos effortlessly',
                        style: TextStyle(color: NashColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Video URL', style: TextStyle(color: NashColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: NashColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: NashColors.border),
              ),
              child: Stack(
                children: [
                  TextField(
                    controller: _urlController,
                    onSubmitted: _fetchPreview,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
                    decoration: const InputDecoration(
                      hintText: 'https://youtube.com/watch?v=... or Instagram reel link',
                      hintStyle: TextStyle(color: NashColors.textMuted, fontSize: 12),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.fromLTRB(14, 14, 60, 40),
                    ),
                    maxLines: 3,
                    minLines: 2,
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: ElevatedButton(
                      onPressed: _paste,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        textStyle: const TextStyle(fontSize: 11),
                      ),
                      child: const Text('Paste'),
                    ),
                  ),
                ],
              ),
            ),
            if (_fetchingPreview) ...[
              const SizedBox(height: 8),
              const Row(children: [
                SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2, color: NashColors.accent)),
                SizedBox(width: 8),
                Text('Fetching video details…', style: TextStyle(color: NashColors.textSecondary, fontSize: 11)),
              ]),
            ],
            if (_preview != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: NashColors.card.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: NashColors.border),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 54,
                        height: 36,
                        color: NashColors.inputFill,
                        child: _preview!.thumbnail.isNotEmpty
                            ? Image.network(_preview!.thumbnail, fit: BoxFit.cover)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_preview!.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
                          Text(_preview!.uploader,
                              style: const TextStyle(color: NashColors.textSecondary, fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            const Text('Quality', style: TextStyle(color: NashColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: DownloadQuality.values.map((q) {
                final selected = !_audioOnly && _quality == q;
                return GestureDetector(
                  onTap: () => setState(() {
                    _audioOnly = false;
                    _quality = q;
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? NashColors.accent : NashColors.card,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: selected ? Colors.transparent : NashColors.border),
                    ),
                    child: Text(q.label,
                        style: TextStyle(color: selected ? Colors.white : NashColors.textSecondary, fontSize: 12)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Switch(
                  value: _audioOnly,
                  activeColor: NashColors.accent,
                  onChanged: (v) => setState(() => _audioOnly = v),
                ),
                const Text('Audio only (mp3)', style: TextStyle(color: NashColors.textSecondary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 24),
            if (_active != null) _ActiveDownloadCard(item: _active!),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startDownload,
                child: Text(_audioOnly ? 'Download audio' : 'Download video'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveDownloadCard extends StatelessWidget {
  final DownloadItem item;
  const _ActiveDownloadCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<dynamic, dynamic>>(
      stream: YtDlpService.instance.progressStream,
      builder: (context, snapshot) {
        double percent = item.progress;
        String status = item.statusText;
        if (snapshot.hasData && snapshot.data!['id'] == item.id) {
          percent = (snapshot.data!['percent'] as num?)?.toDouble() ?? percent;
          status = snapshot.data!['status'] ?? status;
        }
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: NashColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: NashColors.borderStrong),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(status, style: const TextStyle(color: Colors.white, fontSize: 12)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (percent / 100).clamp(0, 1),
                  minHeight: 5,
                  backgroundColor: NashColors.inputFill,
                  color: NashColors.accent,
                ),
              ),
              const SizedBox(height: 4),
              Text('${percent.toStringAsFixed(0)}%',
                  style: const TextStyle(color: NashColors.textSecondary, fontSize: 10)),
            ],
          ),
        );
      },
    );
  }
}

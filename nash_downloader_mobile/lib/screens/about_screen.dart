import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset('assets/logo.png', width: 64, height: 64),
            ),
            const SizedBox(height: 16),
            const Text('Nash Downloader', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text('Version 1.0.0', style: TextStyle(color: NashColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 20),
            const Text(
              'Batch YouTube and Instagram video downloader, built on yt-dlp. '
              'Share a link straight from Instagram or YouTube to save it.',
              textAlign: TextAlign.center,
              style: TextStyle(color: NashColors.textSecondary, fontSize: 12, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

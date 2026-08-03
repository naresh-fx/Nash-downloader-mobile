import 'package:flutter/material.dart';
import '../models/video_models.dart';
import '../services/share_intent_service.dart';
import '../services/ytdlp_service.dart';
import '../theme/app_theme.dart';
import '../widgets/share_sheet_modal.dart';
import 'about_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;
  final _homeKey = GlobalKey<HomeScreenState>();

  @override
  void initState() {
    super.initState();
    ShareIntentService.instance.init();
    ShareIntentService.instance.sharedLinks.listen(_onSharedLink);
  }

  void _onSharedLink(String url) {
    // Show the quick-action bottom sheet regardless of which tab is open,
    // mirroring how the share target should feel instant.
    ShareSheetModal.show(context, url, (item) {
      YtDlpService.instance.startDownload(
        id: item.id,
        url: item.url,
        audioOnly: item.audioOnly,
        quality: item.quality,
      );
      setState(() => _index = 0);
      _homeKey.currentState?.prefillUrl(url);
    });
  }

  @override
  void dispose() {
    ShareIntentService.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(key: _homeKey),
      const HistoryScreen(),
      const SettingsScreen(),
      const AboutScreen(),
    ];

    return Scaffold(
      backgroundColor: NashColors.background,
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.download_rounded), label: 'Download'),
          BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
          BottomNavigationBarItem(icon: Icon(Icons.info_outline_rounded), label: 'About'),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'screens/root_shell.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const NashDownloaderApp());
}

class NashDownloaderApp extends StatelessWidget {
  const NashDownloaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nash Downloader',
      debugShowCheckedModeBanner: false,
      theme: NashTheme.dark,
      darkTheme: NashTheme.dark,
      themeMode: ThemeMode.dark,
      home: const RootShell(),
    );
  }
}

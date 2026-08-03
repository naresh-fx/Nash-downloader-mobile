import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _alwaysAskFormat = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Settings', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          _SettingsTile(
            title: 'Ask format when sharing in',
            subtitle: 'Show the share sheet picker instead of always using best quality',
            trailing: Switch(
              value: _alwaysAskFormat,
              activeColor: NashColors.accent,
              onChanged: (v) => setState(() => _alwaysAskFormat = v),
            ),
          ),
          const SizedBox(height: 8),
          const _SettingsTile(
            title: 'Default save location',
            subtitle: 'Android/data/com.nash.downloader/files/NashDownloader',
          ),
          const SizedBox(height: 8),
          const _SettingsTile(
            title: 'Update yt-dlp engine',
            subtitle: 'Fetches the latest extractor rules if downloads start failing',
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SettingsTile({required this.title, required this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: NashColors.card, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 13)),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(color: NashColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

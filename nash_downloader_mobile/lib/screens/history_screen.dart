import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: back this with a local sqlite/hive store that YtDlpService
    // writes a row to on every successful download.
    return const SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, color: NashColors.textMuted, size: 32),
            SizedBox(height: 12),
            Text('No downloads yet', style: TextStyle(color: Colors.white, fontSize: 14)),
            SizedBox(height: 4),
            Text('Finished downloads will show up here',
                style: TextStyle(color: NashColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

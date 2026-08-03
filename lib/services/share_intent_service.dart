import 'dart:async';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

/// Wraps receive_sharing_intent so the rest of the app only deals in
/// plain "here's a URL that was shared in" events, whether the app was
/// already open, backgrounded, or cold-started by the share action.
class ShareIntentService {
  ShareIntentService._();
  static final ShareIntentService instance = ShareIntentService._();

  StreamSubscription? _mediaSub;
  final _controller = StreamController<String>.broadcast();

  Stream<String> get sharedLinks => _controller.stream;

  void init() {
    // Fires while the app is already running in the background.
    _mediaSub = ReceiveSharingIntent.instance.getMediaStream().listen(
      (files) => _handleFiles(files),
      onError: (_) {},
    );

    // Fires once for the link that cold-started the app, if any.
    ReceiveSharingIntent.instance.getInitialMedia().then((files) {
      _handleFiles(files);
      ReceiveSharingIntent.instance.reset();
    });
  }

  void _handleFiles(List<SharedMediaFile> files) {
    for (final f in files) {
      final path = f.path;
      if (path.startsWith('http://') || path.startsWith('https://')) {
        _controller.add(path);
      }
    }
  }

  void dispose() {
    _mediaSub?.cancel();
    _controller.close();
  }
}

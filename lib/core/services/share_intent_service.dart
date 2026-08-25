import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/file_utils.dart';

class SharedMedia {
  const SharedMedia({required this.path, required this.mimeType});

  final String path;
  final String mimeType;
}

class ShareIntentService {
  ShareIntentService._();

  static final ShareIntentService instance = ShareIntentService._();

  static const MethodChannel _channel =
      MethodChannel(AppConstants.shareIntentChannelName);

  void initialize({
    required ValueChanged<List<SharedMedia>> onMediaReceived,
  }) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onSharedMediaReceived') {
        final media = decodeSharedMedia(call.arguments);
        if (media.isNotEmpty) {
          onMediaReceived(media);
        }
      }
    });
  }

  Future<List<SharedMedia>> getInitialSharedMedia() async {
    final arguments = await _channel.invokeMethod<dynamic>(
      'getInitialSharedMedia',
    );
    return decodeSharedMedia(arguments);
  }

  static List<SharedMedia> decodeSharedMedia(Object? arguments) {
    if (arguments is! List) return const [];
    final media = <SharedMedia>[];
    for (final item in arguments) {
      if (item is! Map) continue;
      final path = item['path'];
      if (path is! String || path.isEmpty) continue;
      final mimeType = item['mimeType'];
      media.add(
        SharedMedia(
          path: path,
          mimeType: mimeType is String && mimeType.isNotEmpty
              ? mimeType
              : FileUtils.mimeTypeForPath(path),
        ),
      );
    }
    return media;
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/routing/app_router.dart';
import 'core/services/share_intent_service.dart';
import 'features/file_import/logic/shared_media_importer.dart';

class NgeprintApp extends ConsumerStatefulWidget {
  const NgeprintApp({super.key});

  @override
  ConsumerState<NgeprintApp> createState() => _NgeprintAppState();
}

class _NgeprintAppState extends ConsumerState<NgeprintApp> {
  @override
  void initState() {
    super.initState();
    unawaited(_bootstrapShareIntent());
  }

  Future<void> _bootstrapShareIntent() async {
    try {
      ShareIntentService.instance
          .initialize(onMediaReceived: _onMediaReceived);
      final initialMedia =
          await ShareIntentService.instance.getInitialSharedMedia();
      if (initialMedia.isNotEmpty) {
        _onMediaReceived(initialMedia);
      }
    } on Exception {
      _showSnackBar(
        'Menerima berkas dari aplikasi lain tidak tersedia di perangkat ini.',
      );
    }
  }

  void _onMediaReceived(List<SharedMedia> media) {
    unawaited(
      handleIncomingSharedMedia(ref, media, notify: _showSnackBar),
    );
  }

  void _showSnackBar(String message) {
    final context = rootNavigatorKey.currentContext;
    if (context == null || message.isEmpty) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appDisplayName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppConstants.seedColor),
      ),
      routerConfig: appRouter,
    );
  }
}

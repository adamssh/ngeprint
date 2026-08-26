import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/paper_sizes.dart';
import '../../../core/constants/photo_size_presets.dart';
import '../models/passport_photo_config.dart';
import 'editor_session.dart';
import 'passport_photo_document_builder.dart';

class PassportPhotoConfigNotifier extends Notifier<PassportPhotoConfig?> {
  @override
  PassportPhotoConfig? build() => null;

  void start(PassportPhotoConfig config) {
    state = config;
    final document = PassportPhotoDocumentBuilder.build(config);
    ref.read(editorSessionProvider.notifier).start(document);
  }

  void setPaperSize(PaperSize paperSize) {
    final current = state;
    if (current == null) return;
    final updated = current.copyWith(paperSize: paperSize);
    state = updated;
    final document = PassportPhotoDocumentBuilder.build(updated);
    ref.read(editorSessionProvider.notifier).start(document);
  }

  void setPreset(PhotoSizePreset preset) {
    final current = state;
    if (current == null) return;
    final updated = current.copyWith(preset: preset);
    state = updated;
    final document = PassportPhotoDocumentBuilder.build(updated);
    ref.read(editorSessionProvider.notifier).start(document);
  }

  void setQuantity(int quantity) {
    final current = state;
    if (current == null || quantity <= 0) return;
    final updated = current.copyWith(quantity: quantity);
    state = updated;
    final document = PassportPhotoDocumentBuilder.build(updated);
    ref.read(editorSessionProvider.notifier).start(document);
  }
}

final passportPhotoConfigProvider =
    NotifierProvider<PassportPhotoConfigNotifier, PassportPhotoConfig?>(
  PassportPhotoConfigNotifier.new,
);


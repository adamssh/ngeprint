import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../file_import/logic/import_flow.dart';
import '../../file_import/models/import_mode.dart';
import 'widgets/home_menu_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ngeprint'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: HomeMenuCard(
                      icon: Icons.photo_library_outlined,
                      title: 'Cetak Gambar',
                      subtitle: 'Banyak foto sekaligus',
                      aspectRatio: 0.92,
                      onTap: () =>
                          startImportFlow(context, ref, ImportMode.imagePrint),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: HomeMenuCard(
                      icon: Icons.picture_as_pdf_outlined,
                      title: 'Cetak PDF',
                      subtitle: 'Dokumen siap cetak',
                      aspectRatio: 0.92,
                      onTap: () =>
                          startImportFlow(context, ref, ImportMode.pdfPrint),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 132,
                child: HomeMenuCard(
                  icon: Icons.recent_actors_outlined,
                  title: 'Cetak Pas Foto',
                  subtitle: 'Preset 2×3 · 3×4 · 4×6 cm, atur jumlah otomatis',
                  onTap: () => startImportFlow(
                      context, ref, ImportMode.passportPhoto),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

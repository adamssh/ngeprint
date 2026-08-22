import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ngeprint/core/constants/app_constants.dart';
import 'package:ngeprint/features/file_import/presentation/providers/file_import_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final importState = ref.watch(fileImportProvider);
    final notifier = ref.read(fileImportProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        centerTitle: true,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Share Intent status
            if (importState.files.isNotEmpty)
              Card(
                color: Colors.blue.shade50,
                child: ListTile(
                  leading: const Icon(Icons.download_done, color: Colors.blue),
                  title: Text('${importState.files.length} file telah di-import'),
                  subtitle: const Text('Ketuk untuk melihat atau melanjutkan ke layout editor.'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push('/import'),
                ),
              ),

            const SizedBox(height: 16),
            const Text(
              'Aksi Cepat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.add_photo_alternate_outlined,
                    color: Colors.indigo,
                    title: 'Import File / Foto',
                    subtitle: 'Pilih foto atau PDF dari penyimpanan',
                    onTap: () async {
                      await notifier.pickFilesFromStorage();
                      if (context.mounted) {
                        context.push('/import');
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.grid_on_outlined,
                    color: Colors.teal,
                    title: 'Foto Pas (3x4 / 4x6)',
                    subtitle: 'Cetak foto ukuran pas otomatis',
                    onTap: () async {
                      await notifier.pickFilesFromStorage();
                      if (context.mounted) {
                        context.push('/import');
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.print_outlined,
                    color: Colors.orange.shade800,
                    title: 'Dokumen / PDF',
                    subtitle: 'Cetak PDF atau N-up (2-up, 4-up)',
                    onTap: () async {
                      await notifier.pickFilesFromStorage();
                      if (context.mounted) {
                        context.push('/import');
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.folder_special_outlined,
                    color: Colors.purple,
                    title: 'Project Tersimpan',
                    subtitle: 'Buka kembali preset layout',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fitur Penyimpanan Project di Tahap 6')),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),
            const Text(
              'Petunjuk Penggunaan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              color: Colors.grey.shade100,
              child: const Padding(
                padding: EdgeInsets.all(14.0),
                child: Column(
                  children: [
                    _InstructionRow(
                      number: '1',
                      text: 'Pilih satu atau banyak foto / PDF dari tombol di atas, atau melalui Share Intent Galeri Android.',
                    ),
                    Divider(),
                    _InstructionRow(
                      number: '2',
                      text: 'Atur ukuran kertas (A4, F4, A5, dll.), koordinat, serta posisi fisik (mm/cm).',
                    ),
                    Divider(),
                    _InstructionRow(
                      number: '3',
                      text: 'Preview dokumen siap cetak dan kirim ke Android Print Framework / Epson Print Service.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}

class _InstructionRow extends StatelessWidget {
  final String number;
  final String text;

  const _InstructionRow({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: Colors.blue.shade700,
          child: Text(
            number,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 13)),
        ),
      ],
    );
  }
}

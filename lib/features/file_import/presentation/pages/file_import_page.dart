import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/file_import_provider.dart';
import '../../domain/models/imported_file.dart';

class FileImportPage extends ConsumerWidget {
  const FileImportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final importState = ref.watch(fileImportProvider);
    final notifier = ref.read(fileImportProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('File Terimport'),
        actions: [
          if (importState.files.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Hapus Semua',
              onPressed: () {
                notifier.clearFiles();
              },
            ),
        ],
      ),
      body: importState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : importState.files.isEmpty
              ? _buildEmptyState(context, notifier)
              : _buildFileList(context, importState.files, notifier),
      bottomNavigationBar: importState.files.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                ),
                icon: const Icon(Icons.edit_document),
                label: Text('Lanjut ke Editor (${importState.files.length} file)'),
                onPressed: () {
                  context.push('/editor');
                },
              ),
            )
          : null,
    );
  }

  Widget _buildEmptyState(BuildContext context, FileImportNotifier notifier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_upload_outlined,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada file yang di-import',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pilih file foto atau PDF dari penyimpanan device, atau share file dari Galeri ke Print Assistant.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Pilih File / Foto / PDF'),
              onPressed: () => notifier.pickFilesFromStorage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileList(
    BuildContext context,
    List<ImportedFile> files,
    FileImportNotifier notifier,
  ) {
    return ListView.builder(
      itemCount: files.length,
      padding: const EdgeInsets.all(12.0),
      itemBuilder: (context, index) {
        final file = files[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(6.0),
              child: file.isImage
                  ? Image.file(
                      File(file.path),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                    )
                  : Container(
                      width: 50,
                      height: 50,
                      color: Colors.red.shade100,
                      child: const Icon(Icons.picture_as_pdf, color: Colors.red),
                    ),
            ),
            title: Text(
              file.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${(file.sizeBytes / 1024).toStringAsFixed(1)} KB • ${file.isPdf ? "PDF" : "Gambar"}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close, color: Colors.redAccent),
              onPressed: () => notifier.removeFile(file.id),
            ),
          ),
        );
      },
    );
  }
}

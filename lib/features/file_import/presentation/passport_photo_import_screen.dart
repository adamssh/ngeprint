import 'package:flutter/material.dart';

import '../models/import_mode.dart';
import 'import_list_screen.dart';

class PassportPhotoImportScreen extends StatelessWidget {
  const PassportPhotoImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImportListScreen(mode: ImportMode.passportPhoto);
  }
}

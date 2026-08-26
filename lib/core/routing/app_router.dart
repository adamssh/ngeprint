import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/editor/presentation/editor_screen.dart';
import '../../features/file_import/models/import_mode.dart';
import '../../features/file_import/presentation/image_import_screen.dart';
import '../../features/file_import/presentation/passport_photo_import_screen.dart';
import '../../features/file_import/presentation/pdf_import_screen.dart';
import '../../features/home/presentation/home_screen.dart';

abstract final class AppRoutes {
  static const String home = '/';
  static const String imageImport = '/import/images';
  static const String pdfImport = '/import/pdf';
  static const String passportPhotoImport = '/import/passport-photo';
  static const String imageEditor = '/editor/image-print';
  static const String pdfEditor = '/editor/pdf-print';
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.imageImport,
      builder: (context, state) => const ImageImportScreen(),
    ),
    GoRoute(
      path: AppRoutes.pdfImport,
      builder: (context, state) => const PdfImportScreen(),
    ),
    GoRoute(
      path: AppRoutes.passportPhotoImport,
      builder: (context, state) => const PassportPhotoImportScreen(),
    ),
    GoRoute(
      path: AppRoutes.imageEditor,
      builder: (context, state) =>
          const EditorScreen(mode: ImportMode.imagePrint),
    ),
    GoRoute(
      path: AppRoutes.pdfEditor,
      builder: (context, state) =>
          const EditorScreen(mode: ImportMode.pdfPrint),
    ),
  ],
);

String importRouteOf(ImportMode mode) => switch (mode) {
      ImportMode.imagePrint => AppRoutes.imageImport,
      ImportMode.pdfPrint => AppRoutes.pdfImport,
      ImportMode.passportPhoto => AppRoutes.passportPhotoImport,
    };

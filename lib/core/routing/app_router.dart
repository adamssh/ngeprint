import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ngeprint/features/home/presentation/pages/home_page.dart';
import 'package:ngeprint/features/file_import/presentation/pages/file_import_page.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/import',
        name: 'import',
        builder: (context, state) => const FileImportPage(),
      ),
      GoRoute(
        path: '/editor',
        name: 'editor',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Layout Editor')),
          body: const Center(
            child: Text('Layout Editor akan diimplementasikan pada Tahap 2'),
          ),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Halaman tidak ditemukan: ${state.error}'),
      ),
    ),
  );
}


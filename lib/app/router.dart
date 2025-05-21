// lib/app/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/pages/home/home_page.dart';
import '../presentation/pages/model_detail/model_detail_page.dart';
import '../presentation/pages/device_info/device_info_page.dart';
import '../presentation/pages/chat/chat_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/model_detail',
        name: 'model_detail',
        builder: (context, state) {
          final modelId = state.extra as String? ?? '';

          // Bisa kirim modelId ke halaman detail via argumen
          return ModelDetailPage(modelId: modelId);
        },
      ),
      GoRoute(
        path: '/device_info',
        name: 'device_info',
        builder: (context, state) => const DeviceInfoPage(),
      ),
      // GoRoute(
      //   path: '/chat',
      //   name: 'chat',
      //   builder: (context, state) {
      //     final modelId = state.extra as String? ?? '';

      //     return ChatPage(modelId: modelId);
      //   },
      // ),
    ],
  );
}

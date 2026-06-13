import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../view/login.dart';
import '../../view/main_screen.dart';

// Placeholder screens cho các role chưa có UI
import 'package:flutter/material.dart';

class AppPages {
  static final routes = [
    GetPage(name: '/login', page: () => const LoginPage()),
    GetPage(name: '/student', page: () => const MainScreen()),
    GetPage(
      name: '/teacher',
      page: () => const _PlaceholderScreen(title: 'Giáo viên'),
    ),
    GetPage(
      name: '/admin',
      page: () => const _PlaceholderScreen(title: 'Quản trị viên'),
    ),
    GetPage(
      name: '/head',
      page: () => const _PlaceholderScreen(title: 'Trưởng bộ môn'),
    ),
    GetPage(
      name: '/parent',
      page: () => const _PlaceholderScreen(title: 'Phụ huynh'),
    ),
  ];
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFFE65100),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Get.find<AuthController>().logout(),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Màn hình $title\n(Đang phát triển)',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'vn/edu/fpt/core/network/api_client.dart';
import 'vn/edu/fpt/core/router/app_router.dart';
import 'vn/edu/fpt/controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiClient.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'FSchools',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE65100)),
      ),
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController());
      }),
      getPages: AppPages.routes,
      home: const _SplashRouter(),
    );
  }
}

// Kiểm tra token lưu local để quyết định vào login hay thẳng app
class _SplashRouter extends StatefulWidget {
  const _SplashRouter();

  @override
  State<_SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<_SplashRouter> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    final route = await Get.find<AuthController>().getInitialRoute();
    if (mounted) {
      Get.offAllNamed(route!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFE65100),
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
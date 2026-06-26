import 'package:flutter/material.dart';
import 'package:prm393_mobile/vn/edu/fpt/widgets/custom_bottom_nav_bar.dart';
import 'admin_home_view.dart';
import '../shared/account_view.dart';

class AdminMainView extends StatefulWidget {
  const AdminMainView({super.key});

  @override
  State<AdminMainView> createState() => _AdminMainViewState();
}

class _AdminMainViewState extends State<AdminMainView> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const AdminHomeView(),
    const PlaceholderScreen(
      title: 'Dashboard',
      subtitle: 'Thống kê tổng quan',
      icon: Icons.dashboard,
    ),
    const AccountView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          CustomBottomNavBarItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'Trang chủ',
          ),
          CustomBottomNavBarItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: 'Thống kê',
          ),
          CustomBottomNavBarItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(subtitle)),
    );
  }
}

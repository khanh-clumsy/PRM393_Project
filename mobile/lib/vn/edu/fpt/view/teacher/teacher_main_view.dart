import 'package:flutter/material.dart';
import 'package:prm393_mobile/vn/edu/fpt/widgets/custom_bottom_nav_bar.dart';
import 'teacher_home_view.dart';
import '../shared/account_view.dart';
// TODO: import other teacher views here

class TeacherMainView extends StatefulWidget {
  const TeacherMainView({super.key});

  @override
  State<TeacherMainView> createState() => _TeacherMainViewState();
}

class _TeacherMainViewState extends State<TeacherMainView> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const TeacherHomeView(),
    const PlaceholderScreen(
      title: 'Classes',
      subtitle: 'Lớp học của tôi',
      icon: Icons.class_,
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
            icon: Icons.class_outlined,
            activeIcon: Icons.class_,
            label: 'Lớp học',
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

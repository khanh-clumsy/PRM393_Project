import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/timetable_controller.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../shared/account_view.dart';
import '../shared/timetable_view.dart';
import 'parent_home_view.dart';

class ParentMainView extends StatefulWidget {
  const ParentMainView({super.key});

  @override
  State<ParentMainView> createState() => _ParentMainViewState();
}

class _ParentMainViewState extends State<ParentMainView> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Khởi tạo TimetableController sớm để dùng chung trong cả ParentHomeView và TimetablePage
    Get.put(TimetableController());
  }

  late final List<Widget> _pages = const [
    ParentHomeView(),
    TimetablePage(),
    AccountView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
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
            icon: Icons.calendar_today_outlined,
            activeIcon: Icons.calendar_today_rounded,
            label: 'Lịch học',
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

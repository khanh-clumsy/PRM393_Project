import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prm393_mobile/vn/edu/fpt/widgets/custom_bottom_nav_bar.dart';
import '../../controllers/user_controller.dart';
import 'student_home_view.dart';
import 'student_grade_view.dart';
import '../shared/timetable_view.dart';
import 'leave_request_view.dart';
import '../shared/account_view.dart';

class StudentMainView extends StatefulWidget {
  const StudentMainView({super.key});

  @override
  State<StudentMainView> createState() => _StudentMainViewState();
}

class _StudentMainViewState extends State<StudentMainView> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Get.put(UserController(profileOnly: true), permanent: true);
  }

  final List<Widget> _pages = [
    const StudentHomeView(),
    const StudentGradeView(),
    const TimetablePage(),
    const LeaveRequestListPage(),
    const AccountView(),
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
            icon: Icons.school_outlined,
            activeIcon: Icons.school_rounded,
            label: 'Học tập',
          ),
          CustomBottomNavBarItem(
            icon: Icons.calendar_today_outlined,
            activeIcon: Icons.calendar_today_rounded,
            label: 'Lịch học',
          ),
          CustomBottomNavBarItem(
            icon: Icons.event_busy_outlined,
            activeIcon: Icons.event_busy,
            label: 'Đơn từ',
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

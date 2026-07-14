import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prm393_mobile/vn/edu/fpt/widgets/custom_bottom_nav_bar.dart';
import '../../controllers/notification_controller.dart';
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
    Get.put(NotificationController(), permanent: true);
  }

  final List<Widget> _pages = [
    const StudentHomeView(),
    const StudentGradeView(),
    const TimetablePage(),
    const PlaceholderScreen(
      title: 'Tin nhắn',
      subtitle: 'Kết nối với giáo viên, câu lạc bộ và bạn cùng lớp. Tính năng đang phát triển.',
      icon: Icons.chat_bubble_rounded,
    ),
    const LeaveRequestListPage(),
    const AccountView(), // Add this
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
            icon: Icons.chat_bubble_outline_rounded,
            activeIcon: Icons.chat_bubble_rounded,
            label: 'Tin nhắn',
            badgeCount: 3,
          ),
          CustomBottomNavBarItem(
            icon: Icons.assignment_outlined,
            activeIcon: Icons.assignment,
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
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFCC80), width: 1),
                ),
                child: Icon(icon, size: 64, color: const Color(0xFFE65100)),
              ),
              const SizedBox(height: 24),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey.shade600), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:prm393_mobile/vn/edu/fpt/view/home.dart';
import 'package:prm393_mobile/vn/edu/fpt/view/academic.dart';
import 'package:prm393_mobile/vn/edu/fpt/view/timetable.dart';
import 'package:prm393_mobile/vn/edu/fpt/view/leave_request.dart';
import 'package:prm393_mobile/vn/edu/fpt/widgets/custom_bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Danh sách các trang để chuyển đổi qua lại
  final List<Widget> _pages = [
    const StudentHomePage(),
    const AcademicPage(),
    const TimetablePage(),
    const PlaceholderScreen(
      title: 'Messages',
      subtitle: 'Connect with teachers, clubs, and classmates. You have 3 unread messages.',
      icon: Icons.chat_bubble_rounded,
    ),
    const LeaveRequestListPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      // Footer Bottom Navigation Bar tái sử dụng cao cấp
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
            label: 'Home',
          ),
          CustomBottomNavBarItem(
            icon: Icons.school_outlined,
            activeIcon: Icons.school_rounded,
            label: 'Academic',
          ),
          CustomBottomNavBarItem(
            icon: Icons.calendar_today_outlined,
            activeIcon: Icons.calendar_today_rounded,
            label: 'Timetable',
          ),
          CustomBottomNavBarItem(
            icon: Icons.chat_bubble_outline_rounded,
            activeIcon: Icons.chat_bubble_rounded,
            label: 'Messages',
            badgeCount: 3, // Thử nghiệm hiển thị Badge cho tab Tin nhắn
          ),
          CustomBottomNavBarItem(
            icon: Icons.more_horiz_outlined,
            activeIcon: Icons.more_horiz_rounded,
            label: 'More',
          ),
        ],
      ),
    );
  }
}

/// Màn hình mẫu để điền các phần chưa thiết kế
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
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
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
                child: Icon(
                  icon,
                  size: 64,
                  color: const Color(0xFFE65100),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Accessing $title details...')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE65100),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Explore Details'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

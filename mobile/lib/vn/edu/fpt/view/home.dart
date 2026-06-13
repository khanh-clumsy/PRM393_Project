import 'package:flutter/material.dart';
import 'package:prm393_mobile/vn/edu/fpt/view/notifications.dart';
import 'package:prm393_mobile/vn/edu/fpt/widgets/student_card.dart';
import 'package:prm393_mobile/vn/edu/fpt/widgets/quick_actions.dart';
import 'package:prm393_mobile/vn/edu/fpt/widgets/news_card.dart';

class StudentHomePage extends StatelessWidget {
  const StudentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu tin tức giả định để hiển thị
    final newsList = [
      const NewsItemData(
        id: '1',
        title: 'New School Year Assembly Details & Guidelines',
        excerpt: 'Join us this Monday for the opening assembly. We will be discussing the new curriculum, school rules, and introduced the teachers for this academic year.',
        timeAgo: '2h ago',
        tag: 'Event',
        imageUrl: 'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=600&auto=format&fit=crop',
        likes: 24,
        comments: 5,
      ),
      const NewsItemData(
        id: '2',
        title: 'Science Fair Registrations Open',
        excerpt: 'Students interested in participating in the Annual Science Fair must submit their project proposals to the chemistry lab before Friday. Great prizes await!',
        timeAgo: '5h ago',
        tag: 'Notice',
        likes: 42,
        comments: 12,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC), // Nền trắng xám hiện đại cực kỳ cao cấp
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            // Ảnh đại diện học sinh
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFCC80), width: 1.5),
              ),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFFFE0B2),
                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&auto=format&fit=crop'),
              ),
            ),
            const SizedBox(width: 10),
            // Tên trường & Tên học sinh
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'FSchool',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE65100), // Cam FSchools thương hiệu
                  ),
                ),
                Text(
                  'Welcome, Alex Johnson',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Nút chuông thông báo có Badge đỏ báo hiệu tin mới
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsPage(),
                ),
              );
            },
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xFF424242),
                  size: 26,
                ),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card thông tin học sinh
              const StudentCard(
                studentName: 'Alex Johnson',
                gradeInfo: 'Grade 10 - Science Stream',
                isPresent: true,
                currentClass: 'Physics',
                currentClassTime: '10:30 AM - 11:15 AM',
                upcomingAssignment: 'Math Quiz',
                upcomingAssignmentDue: 'Due Tomorrow',
              ),
              const SizedBox(height: 24),
              // Nút hành động nhanh
              const QuickActions(),
              const SizedBox(height: 24),
              // Tiêu đề phần Tin tức
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'School News',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Viewing all news')),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFE65100),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Danh sách tin tức
              ...newsList.map((news) => NewsCard(news: news)),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

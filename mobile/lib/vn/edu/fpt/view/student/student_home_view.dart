import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_controller.dart';
import '../../widgets/student_card.dart';
import '../../widgets/quick_actions.dart';
import '../../widgets/news_card.dart';
import '../../widgets/student_welcome_app_bar.dart';

class StudentHomeView extends StatelessWidget {
  const StudentHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();

    final newsList = [
      const NewsItemData(
        id: '1',
        title: 'Thông báo khai giảng năm học mới',
        excerpt:
            'Hội trường lớn vào thứ Hai tuần tới. Ban giám hiệu sẽ giới thiệu chương trình học, nội quy và đội ngũ giáo viên năm học này.',
        timeAgo: '2 giờ trước',
        tag: 'Sự kiện',
        imageUrl: 'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=600&auto=format&fit=crop',
        likes: 24,
        comments: 5,
      ),
      const NewsItemData(
        id: '2',
        title: 'Mở đăng ký Hội thi Khoa học Kỹ thuật',
        excerpt:
            'Học sinh quan tâm vui lòng nộp đề cương dự án tại phòng Hóa trước thứ Sáu. Giải thưởng hấp dẫn dành cho các nhóm xuất sắc.',
        timeAgo: '5 giờ trước',
        tag: 'Thông báo',
        likes: 42,
        comments: 12,
      ),
    ];

    return Obx(() {
      return Scaffold(
        backgroundColor: const Color(0xFFF9FAFC),
        appBar: StudentWelcomeAppBar(welcomeLine: userController.welcomeText),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StudentCard(
                  studentName: userController.currentUserFullName.value,
                  gradeInfo: '—',
                  isPresent: true,
                  currentClass: 'Chưa có tiết hiện tại',
                  currentClassTime: '—',
                  upcomingAssignment: 'Chưa có bài tập sắp tới',
                  upcomingAssignmentDue: '—',
                ),
                const SizedBox(height: 24),
                const QuickActions(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tin tức trường',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đang mở toàn bộ tin tức')),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFE65100),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Xem tất cả'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...newsList.map((news) => NewsCard(news: news)),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      );
    });
  }
}

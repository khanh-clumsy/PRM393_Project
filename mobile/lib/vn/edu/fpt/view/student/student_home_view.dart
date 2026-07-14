import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/announcement_feed_controller.dart';
import '../../controllers/notification_controller.dart';
import '../../controllers/user_controller.dart';
import '../../core/utils/relative_time.dart';
import '../../widgets/student_card.dart';
import '../../widgets/quick_actions.dart';
import '../../widgets/news_card.dart';
import '../../widgets/student_welcome_app_bar.dart';

class StudentHomeView extends StatefulWidget {
  const StudentHomeView({super.key});

  @override
  State<StudentHomeView> createState() => _StudentHomeViewState();
}

class _StudentHomeViewState extends State<StudentHomeView> {
  late final AnnouncementFeedController _feedCtrl;
  late final NotificationController _notifCtrl;

  @override
  void initState() {
    super.initState();
    _feedCtrl = Get.put(AnnouncementFeedController(), tag: 'student_home_feed');
    _notifCtrl = Get.find<NotificationController>();
    _feedCtrl.loadFeed();
    _notifCtrl.refreshUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();

    return Obx(() {
      final newsList = _feedCtrl.feedItems.take(3).map((a) {
        final excerpt = a.content.length > 120 ? '${a.content.substring(0, 120)}...' : a.content;
        return NewsItemData(
          id: '${a.announcementId}',
          title: a.title,
          excerpt: excerpt,
          timeAgo: formatRelativeTimeVi(a.createdAt),
          tag: a.announcementType,
        );
      }).toList();

      return Scaffold(
        backgroundColor: const Color(0xFFF9FAFC),
        appBar: StudentWelcomeAppBar(
          welcomeLine: userController.welcomeText,
          unreadCount: _notifCtrl.unreadCount.value,
        ),
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
                if (_feedCtrl.isLoading.value)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (newsList.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      _feedCtrl.errorMessage.value.isNotEmpty ? _feedCtrl.errorMessage.value : 'Chua co tin tuc moi',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                else
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

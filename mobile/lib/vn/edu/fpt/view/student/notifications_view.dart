import 'package:flutter/material.dart';

class NotificationItemData {
  final String id;
  final String title;
  final String description;
  final String timeAgo;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  bool isUnread;

  NotificationItemData({
    required this.id,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    this.isUnread = false,
  });
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  int _activeTab = 0;

  final List<NotificationItemData> _schoolNotifications = [
    NotificationItemData(
      id: 's1',
      title: 'Thay đổi lịch học Toán',
      description: 'Thầy Anderson đã đổi giờ bắt đầu tiết Giải tích nâng cao ngày mai thành 8:30.',
      timeAgo: '2 phút trước',
      icon: Icons.school_rounded,
      iconBackground: const Color(0xFFFFF3E0),
      iconColor: const Color(0xFFD84315),
      isUnread: true,
    ),
    NotificationItemData(
      id: 's2',
      title: 'Thông báo toàn trường',
      description: 'Thư viện sẽ đóng cửa chiều nay để bảo trì hệ thống điều hòa.',
      timeAgo: '15 phút trước',
      icon: Icons.campaign_rounded,
      iconBackground: const Color(0xFFFFEBEE),
      iconColor: const Color(0xFFC62828),
      isUnread: true,
    ),
    NotificationItemData(
      id: 's3',
      title: 'Bài tập mới',
      description: 'Câu hỏi ôn tập chương 4 đã được đăng trên cổng thông tin môn Vật lý.',
      timeAgo: 'Hôm qua, 16:30',
      icon: Icons.assignment_rounded,
      iconBackground: const Color(0xFFE8EAF6),
      iconColor: const Color(0xFF3F51B5),
      isUnread: false,
    ),
    NotificationItemData(
      id: 's4',
      title: 'Tin nhắn từ cô Davis',
      description: 'Các em làm bài thuyết trình nhóm rất tốt. Điểm đã được cập nhật trên tab Học tập.',
      timeAgo: 'Hôm qua, 14:15',
      icon: Icons.person_rounded,
      iconBackground: Colors.grey.shade100,
      iconColor: Colors.grey.shade700,
      isUnread: false,
    ),
    NotificationItemData(
      id: 's5',
      title: 'Nhắc sự kiện',
      description: 'Hạn đăng ký Hội thi Khoa học Kỹ thuật là thứ Sáu tuần này. Hãy nộp đề cương sớm!',
      timeAgo: 'Hôm qua, 09:00',
      icon: Icons.calendar_today_rounded,
      iconBackground: const Color(0xFFE0F2F1),
      iconColor: const Color(0xFF00796B),
      isUnread: false,
    ),
  ];

  final List<NotificationItemData> _internalNotifications = [
    NotificationItemData(
      id: 'i1',
      title: 'Bảo trì hệ thống',
      description: 'Cổng thông tin FSchool sẽ tạm ngưng từ 0:00 đến 2:00 sáng nay để nâng cấp cơ sở dữ liệu.',
      timeAgo: '1 giờ trước',
      icon: Icons.settings_rounded,
      iconBackground: const Color(0xFFECEFF1),
      iconColor: const Color(0xFF546E7A),
      isUnread: true,
    ),
    NotificationItemData(
      id: 'i2',
      title: 'Sách quá hạn',
      description: 'Vui lòng trả cuốn "Nguyên lý Vật lý cổ điển" để tránh phí phạt trả muộn.',
      timeAgo: '3 ngày trước',
      icon: Icons.menu_book_rounded,
      iconBackground: const Color(0xFFEFEBE9),
      iconColor: const Color(0xFF5D4037),
      isUnread: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final activeList = _activeTab == 0 ? _schoolNotifications : _internalNotifications;
    final unreadItems = activeList.where((item) => item.isUnread).toList();
    final readItems = activeList.where((item) => !item.isUnread).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Thông báo',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF212121)),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF212121), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                for (final item in activeList) {
                  item.isUnread = false;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã đánh dấu tất cả là đã đọc')),
              );
            },
            child: const Text(
              'Đọc hết',
              style: TextStyle(
                color: Color(0xFFD84315),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
              ),
              child: Row(
                children: [
                  _buildTab(0, 'Trường & Lớp'),
                  _buildTab(1, 'Hệ thống'),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  ...unreadItems.map(_buildNotificationTile),
                  if (readItems.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 12, bottom: 12),
                      child: Text(
                        'TRƯỚC ĐÓ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    ...readItems.map(_buildNotificationTile),
                  ],
                  if (unreadItems.isEmpty && readItems.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 60),
                        child: Column(
                          children: [
                            Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              'Không có thông báo',
                              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    final selected = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? const Color(0xFFE65100) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                color: selected ? const Color(0xFFE65100) : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationTile(NotificationItemData item) {
    return GestureDetector(
      onTap: () => setState(() => item.isUnread = false),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: item.isUnread ? const Color(0xFFFFF8F5) : Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade50.withValues(alpha: 0.8)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: item.iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: item.isUnread ? FontWeight.bold : FontWeight.w600,
                      color: const Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.timeAgo,
                    style: TextStyle(
                      fontSize: 11,
                      color: item.isUnread ? const Color(0xFFD84315) : Colors.grey.shade400,
                      fontWeight: item.isUnread ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (item.isUnread)
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFFD84315),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

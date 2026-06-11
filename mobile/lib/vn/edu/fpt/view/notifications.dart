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
  final String? profileImageUrl;

  NotificationItemData({
    required this.id,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    this.isUnread = false,
    this.profileImageUrl,
  });
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  int _activeTab = 0; // 0: School & Class, 1: Internal

  // Danh sách thông báo mẫu "School & Class"
  final List<NotificationItemData> _schoolNotifications = [
    NotificationItemData(
      id: 's1',
      title: 'Change in Math schedule',
      description: 'Mr. Anderson has updated the start time for tomorrow\'s Advanced Calculus class to 8:30 AM.',
      timeAgo: '2 min ago',
      icon: Icons.school_rounded,
      iconBackground: const Color(0xFFFFF3E0),
      iconColor: const Color(0xFFD84315),
      isUnread: true,
    ),
    NotificationItemData(
      id: 's2',
      title: 'Campus Alert',
      description: 'The main library will be closed this afternoon for emergency air conditioning maintenance.',
      timeAgo: '15 min ago',
      icon: Icons.campaign_rounded,
      iconBackground: const Color(0xFFFFEBEE),
      iconColor: const Color(0xFFC62828),
      isUnread: true,
    ),
    NotificationItemData(
      id: 's3',
      title: 'New Assignment Posted',
      description: 'Chapter 4 review questions are now available in your portal for Physics 101.',
      timeAgo: 'Yesterday, 4:30 PM',
      icon: Icons.assignment_rounded,
      iconBackground: const Color(0xFFE8EAF6),
      iconColor: const Color(0xFF3F51B5),
      isUnread: false,
    ),
    NotificationItemData(
      id: 's4',
      title: 'Message from Mrs. Davis',
      description: 'Great job on the group project presentations today. Grades have been updated in your Academic tab.',
      timeAgo: 'Yesterday, 2:15 PM',
      icon: Icons.person_rounded,
      iconBackground: Colors.grey.shade100,
      iconColor: Colors.grey.shade700,
      isUnread: false,
      profileImageUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=100&auto=format&fit=crop',
    ),
    NotificationItemData(
      id: 's5',
      title: 'Upcoming Event Reminder',
      description: 'Don\'t forget the Science Fair registration deadline is this Friday. Submit projects soon!',
      timeAgo: 'Yesterday, 9:00 AM',
      icon: Icons.calendar_today_rounded,
      iconBackground: const Color(0xFFE0F2F1),
      iconColor: const Color(0xFF00796B),
      isUnread: false,
    ),
  ];

  // Danh sách thông báo mẫu "Internal"
  final List<NotificationItemData> _internalNotifications = [
    NotificationItemData(
      id: 'i1',
      title: 'System Maintenance',
      description: 'The FSchool student portal will be offline for routine database upgrades tonight from 12:00 AM to 2:00 AM.',
      timeAgo: '1h ago',
      icon: Icons.settings_rounded,
      iconBackground: const Color(0xFFECEFF1),
      iconColor: const Color(0xFF546E7A),
      isUnread: true,
    ),
    NotificationItemData(
      id: 'i2',
      title: 'Library Overdue Notice',
      description: 'Please return the borrowed book "Principles of Classical Physics" to avoid late fee penalties.',
      timeAgo: '3 days ago',
      icon: Icons.menu_book_rounded,
      iconBackground: const Color(0xFFEFEBE9),
      iconColor: const Color(0xFF5D4037),
      isUnread: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final activeList = _activeTab == 0 ? _schoolNotifications : _internalNotifications;

    // Phân chia danh sách thành "Hôm nay/Mới" (Chưa đọc) và "Hôm qua/Cũ" (Đã đọc)
    final unreadItems = activeList.where((item) => item.isUnread).toList();
    final readItems = activeList.where((item) => !item.isUnread).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Notifications',
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
          // Nút "Mark all read" (Đánh dấu đã đọc hết)
          TextButton(
            onPressed: () {
              setState(() {
                for (var item in activeList) {
                  item.isUnread = false;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications marked as read')),
              );
            },
            child: const Text(
              'Mark all read',
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
            // Thanh chọn Tab ngang: School & Class vs Internal
            Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade100, width: 1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTab = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _activeTab == 0 ? const Color(0xFFE65100) : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'School & Class',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: _activeTab == 0 ? FontWeight.bold : FontWeight.w500,
                              color: _activeTab == 0 ? const Color(0xFFE65100) : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTab = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _activeTab == 1 ? const Color(0xFFE65100) : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Internal',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: _activeTab == 1 ? FontWeight.bold : FontWeight.w500,
                              color: _activeTab == 1 ? const Color(0xFFE65100) : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Danh sách thông báo cuộn dọc
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  // 1. Nhóm thông báo chưa đọc
                  if (unreadItems.isNotEmpty) ...[
                    ...unreadItems.map((item) => _buildNotificationTile(item)),
                  ],

                  // 2. Tiêu đề "YESTERDAY" (hoặc "OLDER" cho các thông báo cũ đã đọc)
                  if (readItems.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 12, bottom: 12),
                      child: Text(
                        'YESTERDAY',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    ...readItems.map((item) => _buildNotificationTile(item)),
                  ],

                  if (unreadItems.isEmpty && readItems.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 60),
                        child: Column(
                          children: [
                            Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            const Text(
                              'No notifications found',
                              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
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

  // Widget vẽ từng thông báo riêng lẻ
  Widget _buildNotificationTile(NotificationItemData item) {
    return GestureDetector(
      onTap: () {
        setState(() {
          item.isUnread = false; // Đọc thông báo khi ấn vào
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          // Nền cam cực nhạt nếu chưa đọc, nền trắng nếu đã đọc
          color: item.isUnread ? const Color(0xFFFFF8F5) : Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade50.withOpacity(0.8), width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hình đại diện giáo viên hoặc Icon danh mục
            if (item.profileImageUrl != null)
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(item.profileImageUrl!),
                backgroundColor: Colors.grey.shade100,
              )
            else
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  color: item.iconColor,
                  size: 20,
                ),
              ),
            const SizedBox(width: 14),

            // Nội dung thông báo
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
                      fontWeight: FontWeight.w400,
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
            const SizedBox(width: 10),

            // Dấu chấm cam báo hiệu chưa đọc bên phải
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

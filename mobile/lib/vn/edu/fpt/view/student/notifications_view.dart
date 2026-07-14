import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/announcement_feed_controller.dart';
import '../../controllers/notification_controller.dart';
import '../../core/utils/relative_time.dart';
import '../../models/announcement_model.dart';
import '../../models/notification_log_model.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  int _activeTab = 0;
  late final AnnouncementFeedController _feedCtrl;
  late final NotificationController _notifCtrl;

  @override
  void initState() {
    super.initState();
    _feedCtrl = Get.put(AnnouncementFeedController(), tag: 'notifications_feed');
    _notifCtrl = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController(), tag: 'notifications_log');
    _feedCtrl.loadFeed();
    _notifCtrl.refreshAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Thong bao',
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
          if (_activeTab == 1)
            TextButton(
              onPressed: _notifCtrl.markAllRead,
              child: const Text(
                'Doc het',
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
                  _buildTab(0, 'Truong & Lop'),
                  _buildTab(1, 'He thong'),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (_activeTab == 0) {
                  return _buildAnnouncementList();
                }
                return _buildNotificationList();
              }),
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

  Widget _buildAnnouncementList() {
    if (_feedCtrl.isLoading.value) return const Center(child: CircularProgressIndicator());
    if (_feedCtrl.errorMessage.value.isNotEmpty) return _buildEmpty(_feedCtrl.errorMessage.value);
    if (_feedCtrl.feedItems.isEmpty) return _buildEmpty('Chua co bang tin');

    return RefreshIndicator(
      onRefresh: _feedCtrl.loadFeed,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: _feedCtrl.feedItems.map(_buildAnnouncementTile).toList(),
      ),
    );
  }

  Widget _buildNotificationList() {
    if (_notifCtrl.isLoading.value) return const Center(child: CircularProgressIndicator());
    if (_notifCtrl.errorMessage.value.isNotEmpty) return _buildEmpty(_notifCtrl.errorMessage.value);

    final unreadItems = _notifCtrl.notifications.where((item) => !item.isRead).toList();
    final readItems = _notifCtrl.notifications.where((item) => item.isRead).toList();
    if (unreadItems.isEmpty && readItems.isEmpty) return _buildEmpty('Khong co thong bao');

    return RefreshIndicator(
      onRefresh: _notifCtrl.refreshAll,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          ...unreadItems.map(_buildNotificationTile),
          if (readItems.isNotEmpty) ...[
            _buildSectionLabel(),
            ...readItems.map(_buildNotificationTile),
          ],
        ],
      ),
    );
  }

  Widget _buildAnnouncementTile(AnnouncementModel item) {
    final urgent = item.priority.toLowerCase() == 'urgent';
    return _buildBaseTile(
      title: item.title,
      description: item.content,
      timeAgo: formatRelativeTimeVi(item.createdAt),
      icon: _announcementIcon(item),
      iconBackground: urgent ? const Color(0xFFFFEBEE) : const Color(0xFFFFF3E0),
      iconColor: urgent ? const Color(0xFFC62828) : const Color(0xFFD84315),
      isUnread: urgent,
    );
  }

  Widget _buildNotificationTile(NotificationLogModel item) {
    return GestureDetector(
      onTap: item.isRead ? null : () => _notifCtrl.markRead(item.notificationId),
      child: _buildBaseTile(
        title: item.title,
        description: item.body,
        timeAgo: formatRelativeTimeVi(item.createdAt),
        icon: Icons.notifications_active_outlined,
        iconBackground: const Color(0xFFECEFF1),
        iconColor: const Color(0xFF546E7A),
        isUnread: !item.isRead,
      ),
    );
  }

  Widget _buildBaseTile({
    required String title,
    required String description,
    required String timeAgo,
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
    required bool isUnread,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFFFFF8F5) : Colors.white,
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
            decoration: BoxDecoration(color: iconBackground, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                    color: const Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  timeAgo,
                  style: TextStyle(
                    fontSize: 11,
                    color: isUnread ? const Color(0xFFD84315) : Colors.grey.shade400,
                    fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (isUnread)
            Container(
              margin: const EdgeInsets.only(top: 6),
              width: 7,
              height: 7,
              decoration: const BoxDecoration(color: Color(0xFFD84315), shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 12, bottom: 12),
      child: Text(
        'TRUOC DO',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildEmpty(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(message, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  IconData _announcementIcon(AnnouncementModel a) {
    if (a.priority.toLowerCase() == 'urgent') return Icons.campaign_rounded;
    if (a.announcementType.toLowerCase() == 'global' || a.announcementType.toLowerCase() == 'school') {
      return Icons.school_rounded;
    }
    return Icons.class_rounded;
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/announcement_feed_controller.dart';
import '../../core/utils/relative_time.dart';
import '../../models/announcement_model.dart';
import 'announcement_detail_view.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final AnnouncementFeedController _feedCtrl;

  @override
  void initState() {
    super.initState();
    _feedCtrl = Get.put(AnnouncementFeedController(), tag: 'notifications_feed');
    _feedCtrl.loadFeed();
  }

  void _openDetail(AnnouncementModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnnouncementDetailView(
          announcement: item,
          feedController: _feedCtrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          Obx(() {
            if (_feedCtrl.unreadCount == 0) return const SizedBox.shrink();
            return TextButton(
              onPressed: _feedCtrl.markAllRead,
              child: const Text('Đọc hết', style: TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.w600)),
            );
          }),
        ],
      ),
      body: SafeArea(
        child: Obx(() => _buildAnnouncementList()),
      ),
    );
  }

  Widget _buildAnnouncementList() {
    if (_feedCtrl.isLoading.value) return const Center(child: CircularProgressIndicator());
    if (_feedCtrl.errorMessage.value.isNotEmpty) return _buildEmpty(_feedCtrl.errorMessage.value);
    if (_feedCtrl.feedItems.isEmpty) return _buildEmpty('Chưa có bảng tin');

    return RefreshIndicator(
      onRefresh: _feedCtrl.loadFeed,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: _feedCtrl.feedItems.map(_buildAnnouncementTile).toList(),
      ),
    );
  }

  Widget _buildAnnouncementTile(AnnouncementModel item) {
    final urgent = item.priority.toLowerCase() == 'urgent';
    final unread = _feedCtrl.isUnread(item.announcementId);
    return InkWell(
      onTap: () => _openDetail(item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: unread
              ? (urgent ? const Color(0xFFFFF8F5) : const Color(0xFFFFFBF7))
              : Colors.white,
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
                color: urgent ? const Color(0xFFFFEBEE) : const Color(0xFFFFF3E0),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _announcementIcon(item),
                color: urgent ? const Color(0xFFC62828) : const Color(0xFFD84315),
                size: 20,
              ),
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
                      fontWeight: unread || urgent ? FontWeight.bold : FontWeight.w600,
                      color: const Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.content,
                    style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatRelativeTimeVi(item.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: urgent ? const Color(0xFFD84315) : Colors.grey.shade400,
                      fontWeight: urgent ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (unread)
              Container(
                margin: const EdgeInsets.only(top: 6, left: 8),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: Color(0xFFE65100), shape: BoxShape.circle),
              ),
          ],
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/announcement_feed_controller.dart';
import '../../core/utils/relative_time.dart';
import '../../models/announcement_model.dart';

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
    return _buildBaseTile(
      title: item.title,
      description: item.content,
      timeAgo: formatRelativeTimeVi(item.createdAt),
      icon: _announcementIcon(item),
      iconBackground: urgent ? const Color(0xFFFFEBEE) : const Color(0xFFFFF3E0),
      iconColor: urgent ? const Color(0xFFC62828) : const Color(0xFFD84315),
      highlight: urgent,
    );
  }

  Widget _buildBaseTile({
    required String title,
    required String description,
    required String timeAgo,
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
    required bool highlight,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFFFF8F5) : Colors.white,
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
                    fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
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
                    color: highlight ? const Color(0xFFD84315) : Colors.grey.shade400,
                    fontWeight: highlight ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (highlight)
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

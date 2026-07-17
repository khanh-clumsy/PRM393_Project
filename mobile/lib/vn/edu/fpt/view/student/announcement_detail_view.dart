import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../controllers/announcement_feed_controller.dart';
import '../../models/announcement_model.dart';

class AnnouncementDetailView extends StatefulWidget {
  const AnnouncementDetailView({
    super.key,
    required this.announcement,
    this.feedController,
  });

  final AnnouncementModel announcement;
  final AnnouncementFeedController? feedController;

  @override
  State<AnnouncementDetailView> createState() => _AnnouncementDetailViewState();
}

class _AnnouncementDetailViewState extends State<AnnouncementDetailView> {
  static const _primary = Color(0xFFE65100);
  bool _marked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _markReadOnce());
  }

  Future<void> _markReadOnce() async {
    if (_marked) return;
    _marked = true;
    final ctrl = widget.feedController;
    if (ctrl != null) {
      await ctrl.markRead(widget.announcement.announcementId);
    } else {
      await AnnouncementFeedController.markReadRemote(widget.announcement.announcementId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final announcement = widget.announcement;
    final urgent = announcement.priority.toLowerCase() == 'urgent';
    final typeLabel = _typeLabel(announcement.announcementType);
    final priorityLabel = _priorityLabel(announcement.priority);
    String timeLabel;
    try {
      timeLabel = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(announcement.createdAt).toLocal());
    } catch (_) {
      timeLabel = announcement.createdAt;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: const Text('Chi tiết thông báo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(typeLabel, const Color(0xFFFFF3E0), _primary),
              _chip(
                priorityLabel,
                urgent ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
                urgent ? const Color(0xFFC62828) : const Color(0xFF2E7D32),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            announcement.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            timeLabel,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              announcement.content,
              style: TextStyle(
                fontSize: 15,
                height: 1.55,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _typeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'global':
      case 'school':
        return 'Toàn trường';
      case 'class':
        return 'Theo lớp';
      default:
        return type;
    }
  }

  static String _priorityLabel(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return 'Khẩn cấp';
      case 'high':
        return 'Cao';
      default:
        return 'Bình thường';
    }
  }

  Widget _chip(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../shared/timetable_view.dart';
import 'teacher_my_classes_view.dart';

class TeacherHomeView extends StatelessWidget {
  const TeacherHomeView({super.key});

  static const _primary = Color(0xFFE65100);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Trang chủ GV',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Xin chào, Giáo viên!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
              ),
              const SizedBox(height: 4),
              Text(
                'Truy cập nhanh các tác vụ hàng ngày',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              const Text('Hành động nhanh', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildActionTile(
                context,
                icon: Icons.class_outlined,
                label: 'Lớp học của tôi',
                subtitle: 'Điểm danh, nhập điểm, danh sách lớp',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TeacherMyClassesView()),
                ),
              ),
              const SizedBox(height: 8),
              _buildActionTile(
                context,
                icon: Icons.calendar_month_outlined,
                label: 'Thời khóa biểu',
                subtitle: 'Xem lịch dạy',
                onTap: () => Get.to(() => const TimetablePage()),
              ),
              const SizedBox(height: 8),
              _buildActionTile(
                context,
                icon: Icons.assignment_outlined,
                label: 'Bài tập',
                subtitle: 'Sắp có',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tính năng bài tập đang phát triển.')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFFFF3E0),
          child: Icon(icon, color: _primary, size: 22),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
      ),
    );
  }
}

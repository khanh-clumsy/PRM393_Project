import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminHomeView extends StatelessWidget {
  const AdminHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> adminModules = [
      {'title': 'Tài khoản', 'icon': Icons.people, 'color': Colors.blue, 'route': '/admin/users'},
      {'title': 'Phòng ban / Khoa', 'icon': Icons.business, 'color': Colors.indigo, 'route': '/admin/departments'},
      {'title': 'Năm học', 'icon': Icons.event_note, 'color': Colors.purple, 'route': '/admin/academic-years'},
      {'title': 'Học kỳ', 'icon': Icons.date_range, 'color': Colors.deepPurple, 'route': '/admin/semesters'},
      {'title': 'Môn học', 'icon': Icons.book, 'color': Colors.green, 'route': '/admin/subjects'},
      {'title': 'Lớp học', 'icon': Icons.class_, 'color': Colors.teal, 'route': '/admin/classes'},
      {'title': 'Xếp loại', 'icon': Icons.grade, 'color': Colors.orange, 'route': '/admin/ranks'},
      {'title': 'Ca học (Slot)', 'icon': Icons.schedule, 'color': Colors.red, 'route': '/admin/slots'},
      {'title': 'Bảng tin', 'icon': Icons.announcement, 'color': Colors.pink, 'route': '/admin/announcements'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Quản trị hệ thống',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE65100),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Danh mục Master Data',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: adminModules.length,
                  itemBuilder: (context, index) {
                    final module = adminModules[index];
                    return _buildModuleCard(context, module);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleCard(BuildContext context, Map<String, dynamic> module) {
    return InkWell(
      onTap: () {
        if (module['route'] == '/admin/departments' || 
            module['route'] == '/admin/academic-years' || 
            module['route'] == '/admin/semesters' ||
            module['route'] == '/admin/subjects' ||
            module['route'] == '/admin/slots' ||
            module['route'] == '/admin/users' ||
            module['route'] == '/admin/classes' ||
            module['route'] == '/admin/ranks' ||
            module['route'] == '/admin/announcements') {
          Get.toNamed(module['route']);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Chức năng ${module['title']} đang được phát triển!')),
          );
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (module['color'] as Color).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                module['icon'] as IconData,
                color: module['color'] as Color,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                module['title'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

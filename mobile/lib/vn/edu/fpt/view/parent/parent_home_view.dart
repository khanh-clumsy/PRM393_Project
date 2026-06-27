import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/timetable_controller.dart';
import '../student/notifications_view.dart';
import '../shared/attendance_view.dart';
import '../shared/timetable_view.dart';

class ParentHomeView extends StatelessWidget {
  const ParentHomeView({super.key});

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TimetableController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Obx(() => Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: const Color(0xFFFFCC80), width: 1.5),
                  ),
                  child: const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFFFFE0B2),
                    child: Icon(Icons.person, color: Color(0xFFE65100), size: 20),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'FSchool',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE65100),
                      ),
                    ),
                    Text(
                      controller.studentName.value.isNotEmpty
                          ? 'Xin chào, ${controller.studentName.value}'
                          : 'Xin chào, Phụ huynh',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            )),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationsPage()),
              );
            },
            icon: const Icon(Icons.notifications_none_rounded,
                color: Color(0xFF424242), size: 26),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE65100)));
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header chào
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE65100), Color(0xFFFF8A50)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cổng thông tin Phụ huynh',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.studentName.value.isNotEmpty
                            ? controller.studentName.value
                            : 'Phụ huynh',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.child_care,
                              color: Colors.white70, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            controller.linkedStudents.isEmpty
                                ? 'Chưa liên kết học sinh'
                                : '${controller.linkedStudents.length} học sinh được liên kết',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Danh sách con
                if (controller.linkedStudents.isNotEmpty) ...[
                  const Text(
                    'Học sinh của bạn',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...controller.linkedStudents.map((s) {
                    final isSelected =
                        controller.targetStudentId.value == s['studentId'];
                    return GestureDetector(
                      onTap: () =>
                          controller.switchToStudent(s['studentId']),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFE65100)
                                : Colors.grey.shade100,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: isSelected
                                  ? const Color(0xFFFFE0B2)
                                  : Colors.grey.shade100,
                              child: Icon(
                                Icons.person_outline_rounded,
                                color: isSelected
                                    ? const Color(0xFFE65100)
                                    : Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s['studentName'] ?? 'Học sinh',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: isSelected
                                          ? const Color(0xFFE65100)
                                          : const Color(0xFF212121),
                                    ),
                                  ),
                                  if ((s['relationship'] as String).isNotEmpty)
                                    Text(
                                      s['relationship'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle,
                                  color: Color(0xFFE65100), size: 20),
                          ],
                        ),
                      ),
                    );
                  }),
                ] else ...[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Column(
                        children: [
                          Icon(Icons.person_add_alt_outlined,
                              size: 60, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'Chưa có học sinh được liên kết',
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Vui lòng liên hệ nhà trường để được hỗ trợ',
                            style: TextStyle(
                                color: Colors.grey.shade400, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                const Text(
                  'Hành động nhanh',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        context,
                        title: 'Xem điểm danh',
                        subtitle: 'Theo dõi chuyên cần',
                        icon: Icons.fact_check_outlined,
                        color: const Color(0xFF2E7D32),
                        bgColor: const Color(0xFFE8F5E9),
                        onTap: () {
                          Get.to(() => const AttendanceView());
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionCard(
                        context,
                        title: 'Xem lịch học',
                        subtitle: 'Thời khóa biểu con',
                        icon: Icons.calendar_month_outlined,
                        color: const Color(0xFFE65100),
                        bgColor: const Color(0xFFFFF3E0),
                        onTap: () {
                          Get.to(() => const TimetablePage());
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/teacher_class_students_controller.dart';
import '../../widgets/app_button.dart';

class TeacherClassStudentsView extends StatefulWidget {
  final int classId;
  final String className;
  final String subjectName;

  const TeacherClassStudentsView({
    super.key,
    required this.classId,
    required this.className,
    required this.subjectName,
  });

  @override
  State<TeacherClassStudentsView> createState() => _TeacherClassStudentsViewState();
}

class _TeacherClassStudentsViewState extends State<TeacherClassStudentsView> {
  static const _primary = Color(0xFFE65100);
  late final TeacherClassStudentsController controller;

  @override
  void initState() {
    super.initState();
    final tag = 'class_students_${widget.classId}';
    if (Get.isRegistered<TeacherClassStudentsController>(tag: tag)) {
      Get.delete<TeacherClassStudentsController>(tag: tag);
    }
    controller = Get.put(
      TeacherClassStudentsController(
        classId: widget.classId,
        className: widget.className,
        subjectName: widget.subjectName,
      ),
      tag: tag,
    );
  }

  @override
  void dispose() {
    Get.delete<TeacherClassStudentsController>(tag: 'class_students_${widget.classId}');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: const Text('Danh sách lớp', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: _primary));
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                const SizedBox(height: 16),
                Text(controller.errorMessage.value),
                const SizedBox(height: 16),
                AppButton.retry(onPressed: controller.load),
              ],
            ),
          );
        }

        return Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFE0F2F1),
                    child: Icon(Icons.groups, color: Colors.teal),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.className, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text(widget.subjectName, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                        Text(
                          '${controller.students.length} học sinh',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: controller.students.isEmpty
                  ? const Center(child: Text('Lớp chưa có học sinh.'))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: controller.students.length,
                      itemBuilder: (context, index) {
                        final s = controller.students[index];
                        return Card(
                          color: Colors.white,
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey.shade100,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF424242)),
                              ),
                            ),
                            title: Text(s.studentName ?? 'Học sinh', style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: (s.studentCode != null && s.studentCode!.isNotEmpty)
                                ? Text('Mã: ${s.studentCode}')
                                : null,
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/teacher_classes_controller.dart';
import '../../models/teaching_assignment_model.dart';
import '../../widgets/app_button.dart';
import 'teacher_attendance_view.dart';
import 'teacher_class_students_view.dart';
import 'teacher_grade_entry_view.dart';

class TeacherMyClassesView extends StatelessWidget {
  const TeacherMyClassesView({super.key});

  static const _primary = Color(0xFFE65100);
  static const bool _showMobileGradeEntry = false;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TeacherClassesController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: const Text(
          'Lớp học của tôi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: _primary),
          );
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                  size: 48,
                ),
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
            _buildFilterBar(controller),
            Expanded(
              child: controller.filteredAssignments.isEmpty
                  ? const Center(child: Text('Chưa có lớp trong học kỳ này.'))
                  : RefreshIndicator(
                      color: _primary,
                      onRefresh: controller.load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: controller.filteredAssignments.length,
                        itemBuilder: (context, index) {
                          final a = controller.filteredAssignments[index];
                          return _ClassAssignmentCard(
                            assignment: a,
                            semesterName: controller.semesters
                                .firstWhereOrNull(
                                  (s) => s.semesterId == a.semesterId,
                                )
                                ?.semesterName,
                            onAttendance: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const TeacherAttendanceView(),
                              ),
                            ),
                            onStudents: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TeacherClassStudentsView(
                                  classId: a.classId,
                                  className: a.className ?? 'Lớp ${a.classId}',
                                  subjectName: a.subjectName ?? 'Môn học',
                                ),
                              ),
                            ),
                            onGrades: _showMobileGradeEntry
                                ? () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const TeacherGradeEntryView(),
                                    ),
                                  )
                                : null,
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFilterBar(TeacherClassesController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.teal, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Năm học:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: controller.selectedYearId.value,
                    hint: const Text('Chọn năm học'),
                    items: controller.academicYears.map((y) {
                      return DropdownMenuItem(
                        value: y.academicYearId,
                        child: Text(
                          y.yearName,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: controller.onYearChanged,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 8, thickness: 1),
          Row(
            children: [
              const Icon(Icons.view_week, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Học kỳ:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: controller.selectedSemesterId.value,
                    hint: const Text('Chọn học kỳ'),
                    items: controller.filteredSemesters.map((s) {
                      return DropdownMenuItem(
                        value: s.semesterId,
                        child: Text(
                          s.semesterName,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: controller.onSemesterChanged,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClassAssignmentCard extends StatelessWidget {
  final TeachingAssignmentModel assignment;
  final String? semesterName;
  final VoidCallback onAttendance;
  final VoidCallback onStudents;
  final VoidCallback? onGrades;

  const _ClassAssignmentCard({
    required this.assignment,
    this.semesterName,
    required this.onAttendance,
    required this.onStudents,
    this.onGrades,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      assignment.subjectName ?? 'Môn học',
      ?semesterName,
    ].join(' · ');

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFFF3E0),
                child: Icon(Icons.class_, color: Color(0xFFE65100)),
              ),
              title: Text(
                assignment.className ?? 'Lớp ${assignment.classId}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(subtitle),
            ),
            const Divider(height: 1),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: onStudents,
                    icon: const Icon(Icons.people_outline, size: 18),
                    label: const Text(
                      'Danh sách',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: onAttendance,
                    icon: const Icon(Icons.fact_check_outlined, size: 18),
                    label: const Text(
                      'Điểm danh',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                if (onGrades != null)
                  Expanded(
                    child: TextButton.icon(
                      onPressed: onGrades,
                      icon: const Icon(Icons.edit_note_outlined, size: 18),
                      label: const Text(
                        'Nhập điểm',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

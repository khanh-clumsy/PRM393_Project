import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/teacher_grade_entry_controller.dart';
import '../../widgets/app_button.dart';

/// Chặn nhập điểm > 10 (và giữ định dạng số hợp lệ).
class ScoreInputFormatter extends TextInputFormatter {
  const ScoreInputFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    if (text == '.') return oldValue;
    if ('.'.allMatches(text).length > 1) return oldValue;
    final value = double.tryParse(text);
    if (value == null) return oldValue;
    if (value > 10) return oldValue;
    return newValue;
  }
}

class TeacherGradeEntryView extends StatefulWidget {
  final int? initialYearId;
  final int? initialSemesterId;
  final int? initialAssignmentId;

  const TeacherGradeEntryView({
    super.key,
    this.initialYearId,
    this.initialSemesterId,
    this.initialAssignmentId,
  });

  @override
  State<TeacherGradeEntryView> createState() => _TeacherGradeEntryViewState();
}

class _TeacherGradeEntryViewState extends State<TeacherGradeEntryView> {
  late final TeacherGradeEntryController controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<TeacherGradeEntryController>()) {
      Get.delete<TeacherGradeEntryController>();
    }
    controller = Get.put(TeacherGradeEntryController(
      initialYearId: widget.initialYearId,
      initialSemesterId: widget.initialSemesterId,
      initialAssignmentId: widget.initialAssignmentId,
    ));
  }

  @override
  void dispose() {
    if (Get.isRegistered<TeacherGradeEntryController>()) {
      Get.delete<TeacherGradeEntryController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: const Text('Nhập điểm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: const Color(0xFFF9FAFC),
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.academicYears.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFE65100)));
        }

        if (controller.errorMessage.value.isNotEmpty && controller.academicYears.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                const SizedBox(height: 16),
                Text(controller.errorMessage.value, style: const TextStyle(color: Colors.redAccent)),
                const SizedBox(height: 16),
                AppButton.retry(onPressed: controller.reload),
              ],
            ),
          );
        }

        int totalStudents = controller.students.length;
        int enteredStudents = controller.students.where((s) => s.score != null).length;

        return Column(
          children: [
            // Filters Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Year & Semester
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Năm học', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    isExpanded: true,
                                    value: controller.selectedAcademicYearId.value,
                                    items: controller.academicYears.map((y) {
                                      return DropdownMenuItem<int>(
                                        value: y.academicYearId,
                                        child: Text(y.yearName, style: const TextStyle(fontSize: 14)),
                                      );
                                    }).toList(),
                                    onChanged: controller.onYearChanged,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Học kỳ', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    isExpanded: true,
                                    value: controller.selectedSemesterId.value,
                                    items: controller.filteredSemesters.map((s) {
                                      return DropdownMenuItem<int>(
                                        value: s.semesterId,
                                        child: Text(s.semesterName, style: const TextStyle(fontSize: 14)),
                                      );
                                    }).toList(),
                                    onChanged: controller.onSemesterChanged,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Subject
                    const Text('Môn học', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: controller.selectedAssignmentId.value,
                          hint: const Text('Chọn môn học', style: TextStyle(fontSize: 14)),
                          items: controller.filteredAssignments.map((ta) {
                            return DropdownMenuItem<int>(
                              value: ta.teachingAssignmentId,
                              child: Text('${ta.subjectName} - ${ta.className}', style: const TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                          onChanged: controller.onAssignmentChanged,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Assessment Type
                    const Text('Loại đánh giá', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: controller.selectedAssessmentTypeId.value,
                          items: controller.assessmentTypes.map((a) {
                            return DropdownMenuItem<int>(
                              value: a.assessmentTypeId,
                              child: Text(a.typeName, style: const TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                          onChanged: controller.onAssessmentTypeChanged,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Max info
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text('Tối đa: 10.0', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Students Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Học sinh ($totalStudents)', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
                  Text('Đã nhập: $enteredStudents/$totalStudents', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Students List
            Expanded(
              child: Builder(
                builder: (context) {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFE65100)));
                  }

                  if (controller.students.isEmpty) {
                    return const Center(child: Text('Không có học sinh nào.'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.students.length,
                    itemBuilder: (context, index) {
                      final student = controller.students[index];
                      // Display 1 decimal point if needed, otherwise omit trailing zeros
                      final initialText = student.score != null ? (student.score! % 1 == 0 ? student.score!.toInt().toString() : student.score.toString()) : '';
                      final scoreController = TextEditingController(text: initialText);
                      
                      // Get initials
                      final nameParts = student.studentName.trim().split(' ');
                      final initials = nameParts.length > 1 
                        ? '${nameParts[0][0]}${nameParts.last[0]}'.toUpperCase()
                        : student.studentName[0].toUpperCase();

                      final hasScore = student.score != null;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: hasScore ? const Color(0xFFE65100).withOpacity(0.5) : Colors.grey.shade200,
                            width: hasScore ? 1.5 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: const Color(0xFFF5F5F5),
                                child: Text(initials, style: TextStyle(color: hasScore ? const Color(0xFFE65100) : const Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(student.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    const SizedBox(height: 2),
                                    Text('Mã HS: ${student.username}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 50,
                                    height: 40,
                                    child: TextField(
                                      controller: scoreController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                                        const ScoreInputFormatter(),
                                      ],
                                      decoration: InputDecoration(
                                        hintText: '—',
                                        contentPadding: EdgeInsets.zero,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(color: Colors.grey.shade300),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: const BorderSide(color: Color(0xFFE65100), width: 2),
                                        ),
                                      ),
                                      onChanged: (val) {
                                        student.score = double.tryParse(val);
                                        // Trigger a minor update just to refresh the "Entered: X/Y" count if needed.
                                        // For performance, we can skip triggering a full rebuild on every keystroke.
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text('/', style: TextStyle(fontSize: 14, color: Colors.grey)),
                                      Text('10', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            
            // Bottom Action Area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
                ],
              ),
              child: Column(
                children: [
                  AppButton.reactive(
                    isLoading: controller.isSaving,
                    icon: Icons.check_circle_outline,
                    label: 'Lưu điểm',
                    loadingLabel: 'Đang lưu...',
                    fullWidth: true,
                    height: 48,
                    borderRadius: 8,
                    onPressed: controller.saveGrades,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/student_grade_controller.dart';
import '../../models/grade_model.dart';
import '../../widgets/app_button.dart';
import 'notifications_view.dart';
import 'student_grade_detail_view.dart';

class StudentGradeView extends StatelessWidget {
  const StudentGradeView({super.key});

  IconData _getIconForSubject(String subjectName) {
    subjectName = subjectName.toLowerCase();
    if (subjectName.contains('toán')) return Icons.calculate_outlined;
    if (subjectName.contains('lý') || subjectName.contains('vật lí')) return Icons.science_outlined;
    if (subjectName.contains('anh')) return Icons.translate_rounded;
    if (subjectName.contains('văn')) return Icons.menu_book_rounded;
    if (subjectName.contains('hóa')) return Icons.biotech_outlined;
    if (subjectName.contains('sinh')) return Icons.grass_outlined;
    if (subjectName.contains('sử')) return Icons.history_edu_outlined;
    if (subjectName.contains('địa')) return Icons.public_outlined;
    if (subjectName.contains('tin')) return Icons.computer_outlined;
    if (subjectName.contains('công dân') || subjectName.contains('gdcd')) return Icons.gavel_outlined;
    if (subjectName.contains('thể dục') || subjectName.contains('gdqp')) return Icons.sports_basketball_outlined;
    if (subjectName.contains('công nghệ')) return Icons.build_circle_outlined;
    return Icons.menu_book_rounded;
  }

  Color _getIconBackgroundForSubject(String subjectName) {
    subjectName = subjectName.toLowerCase();
    if (subjectName.contains('toán')) return const Color(0xFFFFF3E0);
    if (subjectName.contains('lý') || subjectName.contains('vật lí')) return const Color(0xFFE0F2F1);
    if (subjectName.contains('anh')) return const Color(0xFFFFEBEE);
    if (subjectName.contains('văn')) return const Color(0xFFE8EAF6);
    if (subjectName.contains('hóa')) return const Color(0xFFF3E5F5);
    if (subjectName.contains('sinh')) return const Color(0xFFE8F5E9);
    if (subjectName.contains('sử')) return const Color(0xFFEFEBE9);
    if (subjectName.contains('địa')) return const Color(0xFFE1F5FE);
    return const Color(0xFFE8EAF6);
  }

  Color _getIconColorForSubject(String subjectName) {
    subjectName = subjectName.toLowerCase();
    if (subjectName.contains('toán')) return const Color(0xFFE65100);
    if (subjectName.contains('lý') || subjectName.contains('vật lí')) return const Color(0xFF00796B);
    if (subjectName.contains('anh')) return const Color(0xFFC62828);
    if (subjectName.contains('văn')) return const Color(0xFF3F51B5);
    if (subjectName.contains('hóa')) return const Color(0xFF8E24AA);
    if (subjectName.contains('sinh')) return const Color(0xFF2E7D32);
    if (subjectName.contains('sử')) return const Color(0xFF5D4037);
    if (subjectName.contains('địa')) return const Color(0xFF0277BD);
    return const Color(0xFF3F51B5);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StudentGradeController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          'Bảng Điểm',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
              );
            },
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF424242),
              size: 26,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
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
                  AppButton.retry(onPressed: controller.onInit),
                ],
              ),
            );
          }

          return Column(
            children: [
              if (controller.linkedStudents.isNotEmpty)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Con:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: controller.linkedStudents.map((s) {
                          final selected = controller.targetStudentId.value == s['studentId'];
                          return ChoiceChip(
                            label: Text(s['studentName'] ?? 'HS'),
                            selected: selected,
                            onSelected: (_) => controller.switchToStudent(s['studentId'], s['studentName'] ?? ''),
                            selectedColor: const Color(0xFFFFE0B2),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              // Academic Year Dropdown at the top
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Text('Năm học: ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            value: controller.selectedYearId.value,
                            items: controller.academicYears.map((year) {
                              return DropdownMenuItem<int>(
                                value: year.academicYearId,
                                child: Text(year.yearName, style: const TextStyle(fontSize: 14)),
                              );
                            }).toList(),
                            onChanged: controller.onYearChanged,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: () {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFE65100)));
                  }

                  final transcript = controller.transcript.value;
                  if (transcript == null || transcript.semesters.isEmpty) {
                    return const Center(child: Text('Không có học kỳ nào cho năm học này.'));
                  }

                  final selectedIndex = controller.selectedSemesterIndex.value;
                  if (selectedIndex >= transcript.semesters.length) {
                    return const Center(child: Text('Dữ liệu học kỳ không hợp lệ.'));
                  }

                  final currentSemester = transcript.semesters[selectedIndex];
                  final activeSubjects = currentSemester.subjects;
                  final double cumulativeGpa = currentSemester.gpa ?? 0.0;
                  final String conduct = currentSemester.conduct ?? 'Chưa có';

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bảng điểm học tập',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212121),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Capsule Semester Selector
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F0F3),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: transcript.semesters.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final sem = entry.value;
                              final isSelected = controller.selectedSemesterIndex.value == idx;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => controller.selectedSemesterIndex.value = idx,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.white : Colors.transparent,
                                      borderRadius: BorderRadius.circular(25),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.05),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              )
                                            ]
                                          : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        sem.semesterName,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          color: isSelected ? const Color(0xFFE65100) : Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // GPA & Conduct Summary Card
                        Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(color: Colors.grey.shade100),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'GPA học kỳ',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        '$cumulativeGpa',
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFD84315),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        '/ 10.0',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    'Hạnh kiểm',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F5E9),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.star_rounded,
                                          color: Color(0xFF2E7D32),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          conduct,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2E7D32),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (currentSemester.rankName != null) ...[
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Học lực',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF3E0),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.military_tech,
                                            color: Color(0xFFE65100),
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            currentSemester.rankName!,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFE65100),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  // Hien thi diem trung binh ca nam (Yearly GPA)
                                  if (transcript.yearlyCumulativeGpa != null) ...[
                                    const SizedBox(height: 20),
                                    const Divider(),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'GPA cả năm:',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          '${transcript.yearlyCumulativeGpa} / 10.0',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFE65100),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ]
                                ],
                              ),
                            ),
                            Positioned(
                              right: -20,
                              top: -20,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF3E0).withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Title Subject Grades
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Điểm các môn',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF212121),
                              ),
                            ),
                            Text(
                              '${activeSubjects.length} môn',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        if (activeSubjects.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Text(
                              'Chưa có điểm môn học trong ${currentSemester.semesterName}.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          )
                        else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: activeSubjects.length,
                          itemBuilder: (context, index) {
                            final subject = activeSubjects[index];
                            final isBelowAverage = subject.isPassed == false;

                            // Tách các điểm
                            final scores15m = subject.grades.where((g) => g.typeName.toLowerCase().contains('15')).map((g) => g.score).toList();
                            final midterm = subject.grades.where((g) {
                              final n = g.typeName.toLowerCase();
                              return n.contains('giữa') || n.contains('mid') || n.contains('gk');
                            }).map((g) => g.score).firstOrNull;
                            final finalScore = subject.grades.where((g) {
                              final n = g.typeName.toLowerCase();
                              return n.contains('cuối') || n.contains('final') || n.contains('ck');
                            }).map((g) => g.score).firstOrNull;

                            return GestureDetector(
                              onTap: () {
                                Get.to(() => StudentGradeDetailView(subject: subject));
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: isBelowAverage ? const Color(0xFFFFCDD2) : Colors.grey.shade100,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: isBelowAverage
                                          ? const Border(
                                              left: BorderSide(
                                                color: Color(0xFFD32F2F),
                                                width: 4,
                                              ),
                                            )
                                          : null,
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: _getIconBackgroundForSubject(subject.subjectName),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Icon(
                                                _getIconForSubject(subject.subjectName),
                                                color: _getIconColorForSubject(subject.subjectName),
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                subject.subjectName,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF212121),
                                                ),
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                const Text(
                                                  'Tổng kết',
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  subject.overallScore != null ? '${subject.overallScore}' : '-',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: isBelowAverage
                                                        ? const Color(0xFFD32F2F)
                                                        : ((subject.overallScore ?? 0) >= 8.0
                                                            ? const Color(0xFF2E7D32)
                                                            : const Color(0xFF212121)),
                                                  ),
                                                ),
                                                if (subject.yearlyAverageScore != null)
                                                  Text(
                                                    'Cả năm: ${subject.yearlyAverageScore}',
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w600,
                                                      color: Color(0xFFE65100),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 14),
                                        const Divider(height: 1),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    '15 phút',
                                                    style: TextStyle(fontSize: 10, color: Colors.grey),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    scores15m.isNotEmpty ? scores15m.where((s) => s != null).join(', ') : '-',
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w600,
                                                      color: Color(0xFF424242),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Giữa kỳ',
                                                    style: TextStyle(fontSize: 10, color: Colors.grey),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    midterm != null ? '$midterm' : '-',
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w600,
                                                      color: Color(0xFF424242),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Cuối kỳ',
                                                    style: TextStyle(fontSize: 10, color: Colors.grey),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    finalScore != null ? '$finalScore' : '-',
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w600,
                                                      color: Color(0xFF424242),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }(),
              ),
            ],
          );
        }),
      ),
    );
  }
}

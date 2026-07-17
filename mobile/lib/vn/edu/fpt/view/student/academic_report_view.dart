import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/academic_report_controller.dart';
import '../../models/grade_model.dart';

class AcademicReportView extends StatelessWidget {
  const AcademicReportView({
    super.key,
    this.studentId,
    this.studentName,
  });

  /// Nếu null: tự resolve theo role (HS = chính mình, PH = danh sách con + filter).
  final int? studentId;
  final String? studentName;

  static const _primary = Color(0xFFE65100);

  @override
  Widget build(BuildContext context) {
    const tag = 'academic_report';
    if (Get.isRegistered<AcademicReportController>(tag: tag)) {
      Get.delete<AcademicReportController>(tag: tag);
    }
    final ctrl = Get.put(
      AcademicReportController(
        initialStudentId: studentId,
        initialStudentName: studentName,
      ),
      tag: tag,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: Obx(() {
          final name = ctrl.targetStudentName.value.trim();
          return Text(
            name.isNotEmpty ? 'Học bạ · $name' : 'Học bạ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          );
        }),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        if (ctrl.isLoading.value && ctrl.report.value == null && ctrl.academicYears.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: _primary));
        }
        if (ctrl.errorMessage.value.isNotEmpty && ctrl.report.value == null && ctrl.academicYears.isEmpty) {
          return _ErrorPane(message: ctrl.errorMessage.value, onRetry: ctrl.bootstrap);
        }

        return RefreshIndicator(
          color: _primary,
          onRefresh: ctrl.loadReport,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (ctrl.linkedStudents.length > 1) ...[
                const Text('Con:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ctrl.linkedStudents.map((s) {
                    final id = s['studentId'] as int;
                    final name = s['studentName'] as String? ?? 'HS';
                    final selected = ctrl.targetStudentId.value == id;
                    return ChoiceChip(
                      label: Text(name),
                      selected: selected,
                      onSelected: (_) => ctrl.switchToStudent(id, name),
                      selectedColor: const Color(0xFFFFE0B2),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
              _YearDropdown(ctrl: ctrl),
              const SizedBox(height: 16),
              if (ctrl.isLoading.value)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator(color: _primary)),
                )
              else if (ctrl.errorMessage.value.isNotEmpty)
                _ErrorPane(message: ctrl.errorMessage.value, onRetry: ctrl.loadReport)
              else
                ..._buildBody(ctrl.report.value),
            ],
          ),
        );
      }),
    );
  }

  List<Widget> _buildBody(YearlyTranscriptModel? report) {
    if (report == null) {
      return [
        const SizedBox(height: 48),
        Icon(Icons.menu_book_outlined, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text(
          'Chưa có dữ liệu học bạ cho năm này',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
        ),
      ];
    }

    return [
      _YearSummaryCard(report: report),
      const SizedBox(height: 20),
      const Text(
        'Theo học kỳ',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
      ),
      const SizedBox(height: 10),
      if (report.semesters.isEmpty)
        Text('Chưa có học kỳ trong năm học này.', style: TextStyle(color: Colors.grey.shade600))
      else
        ...report.semesters.map(_SemesterCard.new),
      const SizedBox(height: 24),
    ];
  }
}

class _YearDropdown extends StatelessWidget {
  const _YearDropdown({required this.ctrl});
  final AcademicReportController ctrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: Color(0xFFE65100), size: 20),
          const SizedBox(width: 10),
          const Text('Năm học', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                value: ctrl.selectedYearId.value,
                hint: const Text('Chọn năm học'),
                items: ctrl.academicYears
                    .map((y) => DropdownMenuItem(value: y.academicYearId, child: Text(y.yearName)))
                    .toList(),
                onChanged: ctrl.onYearChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _YearSummaryCard extends StatelessWidget {
  const _YearSummaryCard({required this.report});
  final YearlyTranscriptModel report;

  @override
  Widget build(BuildContext context) {
    final gpa = report.yearlyCumulativeGpa;
    final conduct = report.yearlyConduct;
    final empty = gpa == null && (conduct == null || conduct.isEmpty);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tổng kết năm học', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          if (empty)
            Text('Chưa có dữ liệu tổng kết năm', style: TextStyle(color: Colors.grey.shade600, fontSize: 13))
          else
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _metric('GPA', gpa?.toStringAsFixed(1) ?? '—'),
                _metric('Hạnh kiểm', (conduct == null || conduct.isEmpty) ? '—' : conduct),
              ],
            ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _SemesterCard extends StatelessWidget {
  const _SemesterCard(this.semester);
  final SemesterTranscriptModel semester;

  @override
  Widget build(BuildContext context) {
    final summaryEmpty = semester.gpa == null &&
        (semester.conduct == null || semester.conduct!.isEmpty) &&
        (semester.rankName == null || semester.rankName!.isEmpty);
    final subjects = semester.subjects;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(semester.semesterName, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (summaryEmpty)
            Text('Chưa có tổng kết kỳ (GPA / hạnh kiểm)', style: TextStyle(color: Colors.grey.shade600, fontSize: 13))
          else
            Text(
              [
                if (semester.gpa != null) 'GPA ${semester.gpa!.toStringAsFixed(1)}',
                if (semester.conduct != null && semester.conduct!.isNotEmpty) semester.conduct!,
                if (semester.rankName != null && semester.rankName!.isNotEmpty) semester.rankName!,
              ].join(' · '),
              style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
            ),
          const SizedBox(height: 12),
          Text('Điểm từng môn', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade700)),
          const SizedBox(height: 8),
          if (subjects.isEmpty)
            Text(
              'Chưa có điểm môn trong kỳ này (cần Assessments + Grades).',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            )
          else
            ...subjects.map((s) {
              final score = s.overallScore;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        s.subjectName,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Text(
                      score != null ? score.toStringAsFixed(1) : '—',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: score != null ? const Color(0xFFE65100) : Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _ErrorPane extends StatelessWidget {
  const _ErrorPane({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}

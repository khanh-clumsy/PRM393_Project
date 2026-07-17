import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/teacher_class_summary_controller.dart';

/// GVCN — xem bảng tổng kết lớp (chỉ đọc, dùng GET API).
class TeacherClassSummaryView extends StatelessWidget {
  const TeacherClassSummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(TeacherClassSummaryController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Tổng kết lớp'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => c.loadBootstrap(),
          ),
        ],
      ),
      body: Obx(() {
        if (c.isLoading.value && c.classes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (c.errorMessage.value.isNotEmpty && c.classes.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(c.errorMessage.value, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => c.loadBootstrap(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (c.academicYears.isNotEmpty)
                    DropdownButtonFormField<int>(
                      value: c.selectedYearId.value,
                      decoration: const InputDecoration(
                        labelText: 'Năm học',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: c.academicYears
                          .map(
                            (y) => DropdownMenuItem(
                              value: y.academicYearId,
                              child: Text(y.yearName),
                            ),
                          )
                          .toList(),
                      onChanged: c.onYearChanged,
                    ),
                  const SizedBox(height: 10),
                  if (c.classes.length > 1)
                    DropdownButtonFormField<int>(
                      value: c.selectedClassId.value,
                      decoration: const InputDecoration(
                        labelText: 'Lớp chủ nhiệm',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: c.classes
                          .map(
                            (cl) => DropdownMenuItem(
                              value: cl['classId'] as int,
                              child: Text(cl['className']?.toString() ?? ''),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) c.selectClass(v);
                      },
                    )
                  else if (c.classes.isNotEmpty)
                    Text(
                      'Lớp ${c.classes.first['className']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  const SizedBox(height: 10),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'semester', label: Text('Học kỳ')),
                      ButtonSegment(value: 'yearly', label: Text('Cả năm')),
                    ],
                    selected: {c.boardMode.value},
                    onSelectionChanged: (s) => c.setBoardMode(s.first),
                  ),
                  if (c.boardMode.value == 'semester' &&
                      c.yearSemesters.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    SegmentedButton<int>(
                      segments: c.yearSemesters
                          .map(
                            (s) => ButtonSegment(
                              value: s.semesterId,
                              label: Text(s.semesterName),
                            ),
                          )
                          .toList(),
                      selected: {
                        c.selectedSemesterId.value ??
                            c.yearSemesters.first.semesterId,
                      },
                      onSelectionChanged: (s) => c.selectSemester(s.first),
                    ),
                  ],
                ],
              ),
            ),
            if (c.errorMessage.value.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  c.errorMessage.value,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            Expanded(
              child: c.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : c.rows.isEmpty
                      ? Center(
                          child: Text(
                            'Chưa có học sinh / tổng kết cho kỳ này.',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: c.rows.length,
                          separatorBuilder: (_, index) => const SizedBox(height: 8),
                          itemBuilder: (_, i) {
                            final row = c.rows[i];
                            final name = row['studentName']?.toString() ?? '—';
                            final code = row['studentCode']?.toString() ?? '';
                            final isYearly = c.boardMode.value == 'yearly';
                            final avg = isYearly ? row['yearlyGpa'] : row['gpa'];
                            final conduct = isYearly
                                ? row['yearlyConduct']?.toString()
                                : row['conduct']?.toString();
                            final rank = row['rankName']?.toString();
                            final has = row['isFinalized'] == true;

                            return Card(
                              elevation: 0,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFFE3F2FD),
                                  child: Text(
                                    '${i + 1}',
                                    style: const TextStyle(
                                      color: Color(0xFF1565C0),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  has
                                      ? [
                                          if (code.isNotEmpty) code,
                                          if (avg != null)
                                            'ĐTB: ${(avg as num).toStringAsFixed(1)}',
                                          if (conduct != null &&
                                              conduct.isNotEmpty)
                                            'Hạnh kiểm: $conduct',
                                          if (rank != null && rank.isNotEmpty)
                                            'Xếp loại: $rank',
                                        ]
                                          .where((e) => e.isNotEmpty)
                                          .join(' · ')
                                      : (code.isNotEmpty
                                          ? '$code · Chưa có tổng kết'
                                          : 'Chưa có tổng kết'),
                                  style: TextStyle(
                                    color: has
                                        ? Colors.grey.shade700
                                        : Colors.orange.shade800,
                                    fontSize: 12,
                                  ),
                                ),
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

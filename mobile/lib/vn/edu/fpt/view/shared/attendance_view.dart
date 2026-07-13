import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/student_attendance_controller.dart';
import '../student/notifications_view.dart';

class AttendanceView extends StatelessWidget {
  const AttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    // Luôn inject/find controller
    final controller = Get.put(StudentAttendanceController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Điểm danh học tập',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
              );
            },
            icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF424242), size: 26),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFE65100)),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, size: 56, color: Colors.red.shade400),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chọn con (Cho Phụ huynh có nhiều con)
              if (controller.linkedStudents.length > 1) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: controller.targetStudentId.value,
                      hint: const Text('Chọn con'),
                      items: controller.linkedStudents.map((s) {
                        return DropdownMenuItem<int>(
                          value: s['studentId'],
                          child: Text(
                            s['studentName'] ?? 'Học sinh',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          final s = controller.linkedStudents.firstWhere((e) => e['studentId'] == val);
                          controller.switchToStudent(val, s['studentName'] ?? 'Học sinh');
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Header: Thông tin học sinh
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.targetStudentName.value,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Chuyên cần học tập',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Dropdowns: Năm học & Học kỳ
              Row(
                children: [
                  // Năm học dropdown
                  if (controller.academicYears.isNotEmpty)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300, width: 1),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            value: controller.selectedYearId.value,
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 13),
                            hint: const Text('Chọn năm học'),
                            items: controller.academicYears.map((year) {
                              return DropdownMenuItem<int>(
                                value: year['academicYearId'] as int,
                                child: Text(year['yearName'] ?? 'Năm học', style: const TextStyle(fontSize: 13)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) controller.selectedYearId.value = val;
                            },
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  // Học kỳ dropdown
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFCC80), width: 1),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: controller.selectedSemesterId.value,
                          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFE65100)),
                          style: const TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.bold, fontSize: 13),
                          hint: const Text('Chọn học kỳ'),
                          items: controller.filteredSemesters.map((sem) {
                            return DropdownMenuItem<int>(
                              value: sem['semesterId'] as int,
                              child: Text(sem['semesterName'] ?? 'Học kỳ', style: const TextStyle(fontSize: 13)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) controller.selectedSemesterId.value = val;
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Thống kê tổng hợp kỳ học
              _buildSemesterSummary(controller),
              const SizedBox(height: 24),

              // Tiêu đề danh sách môn
              const Text(
                'Thống kê theo môn học',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
              ),
              const SizedBox(height: 12),

              // Danh sách các môn học
              if (controller.subjectStatsList.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(Icons.event_busy_outlined, size: 56, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          'Không có dữ liệu điểm danh môn học',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.subjectStatsList.length,
                  itemBuilder: (context, idx) {
                    final stats = controller.subjectStatsList[idx];
                    return _SubjectAttendanceCard(stats: stats);
                  },
                ),
            ],
          ),
        );
      }),
    );
  }

  // Widget Thống kê tổng quan của học kỳ
  Widget _buildSemesterSummary(StudentAttendanceController controller) {
    final summary = controller.attendanceSummary.value;
    if (summary == null) return const SizedBox.shrink();

    final totalPres = summary.totalPresent;
    final totalAbs = summary.totalAbsent;
    final totalLate = summary.totalLate;
    final totalExc = summary.totalExcused;

    final total = totalPres + totalAbs + totalLate + totalExc;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng quan học kỳ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
              ),
              if (total > 0)
                Text(
                  'Tỉ lệ đi học: ${((totalPres + totalLate) / total * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2E7D32)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSummaryItem('Có mặt', totalPres, const Color(0xFF2E7D32), const Color(0xFFE8F5E9)),
              const SizedBox(width: 8),
              _buildSummaryItem('Vắng mặt', totalAbs, const Color(0xFFC62828), const Color(0xFFFFEBEE)),
              const SizedBox(width: 8),
              _buildSummaryItem('Đi muộn', totalLate, const Color(0xFFF57F17), const Color(0xFFFFF8E1)),
              const SizedBox(width: 8),
              _buildSummaryItem('Có phép', totalExc, const Color(0xFF1565C0), const Color(0xFFE3F2FD)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, int count, Color fg, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: fg),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg),
            ),
          ],
        ),
      ),
    );
  }
}

// Card thông tin điểm danh của từng môn (Có thể Click để expand xem chi tiết)
class _SubjectAttendanceCard extends StatefulWidget {
  final SubjectAttendanceStats stats;
  const _SubjectAttendanceCard({required this.stats});

  @override
  State<_SubjectAttendanceCard> createState() => _SubjectAttendanceCardState();
}

class _SubjectAttendanceCardState extends State<_SubjectAttendanceCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final stats = widget.stats;
    final rate = stats.attendanceRate;
    final ratePercent = (rate * 100).toStringAsFixed(0);

    // Color coding based on attendance rate
    Color themeColor = const Color(0xFF2E7D32); // Green
    Color progressBg = const Color(0xFFE8F5E9);
    if (rate < 0.8) {
      themeColor = const Color(0xFFC62828); // Red if attendance under 80%
      progressBg = const Color(0xFFFFEBEE);
    } else if (rate < 0.9) {
      themeColor = const Color(0xFFF57F17); // Orange if under 90%
      progressBg = const Color(0xFFFFF8E1);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isExpanded ? themeColor.withValues(alpha: 0.3) : Colors.grey.shade100,
          width: _isExpanded ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Card (Clickable)
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          stats.subjectName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Tỷ lệ phần trăm
                      Text(
                        '$ratePercent%',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: themeColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Thông tin số tiết
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Đi học: ${stats.presentCount + stats.lateCount}/${stats.totalCount} tiết',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'Vắng: ${stats.absentCount} | Muộn: ${stats.lateCount} | Có phép: ${stats.excusedCount}',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: stats.totalCount == 0 ? 0 : rate,
                      backgroundColor: progressBg,
                      valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.center,
                    child: Icon(
                      _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Detail Section (Khi Expanded)
          if (_isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            if (stats.details.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Chưa có lịch học nào được ghi nhận cho môn này.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: stats.details.length,
                itemBuilder: (context, index) {
                  final item = stats.details[index];
                  return _buildDetailItem(item);
                },
              ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(AttendanceDetailItem item) {
    final dayLabel = DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(item.date);
    String statusLabel = 'Chưa điểm danh';
    Color fg = Colors.grey.shade600;
    Color bg = Colors.grey.shade100;
    IconData icon = Icons.help_outline_rounded;

    switch (item.status.toLowerCase()) {
      case 'present':
        statusLabel = 'Có mặt';
        fg = const Color(0xFF2E7D32);
        bg = const Color(0xFFE8F5E9);
        icon = Icons.check_circle_outline_rounded;
        break;
      case 'absent':
        statusLabel = 'Vắng mặt';
        fg = const Color(0xFFC62828);
        bg = const Color(0xFFFFEBEE);
        icon = Icons.cancel_outlined;
        break;
      case 'late':
        statusLabel = 'Đi muộn';
        fg = const Color(0xFFF57F17);
        bg = const Color(0xFFFFF8E1);
        icon = Icons.watch_later_outlined;
        break;
      case 'excused':
        statusLabel = 'Có phép';
        fg = const Color(0xFF1565C0);
        bg = const Color(0xFFE3F2FD);
        icon = Icons.assignment_turned_in_outlined;
        break;
      case 'future':
        statusLabel = 'Chưa diễn ra';
        fg = Colors.blueGrey.shade600;
        bg = Colors.blueGrey.shade50;
        icon = Icons.schedule_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayLabel,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.slotName}${item.roomName != null && item.roomName!.isNotEmpty ? ' | Phòng: ${item.roomName}' : ''}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                if (item.note != null && item.note!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Ghi chú: ${item.note}',
                    style: TextStyle(fontSize: 11, color: Colors.amber.shade900, fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
            child: Text(
              statusLabel,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg),
            ),
          ),
        ],
      ),
    );
  }
}

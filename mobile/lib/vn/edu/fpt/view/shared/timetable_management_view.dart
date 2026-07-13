import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/auth/role_context.dart';
import '../../core/timetable_status_helper.dart';
import '../../controllers/timetable_controller.dart';
import '../../models/timetable_model.dart';
import '../../models/timetable_template_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog_actions.dart';
import 'package:intl/intl.dart';

class TimetableManagementView extends StatelessWidget {
  final ScopeMode scopeMode;
  const TimetableManagementView({super.key, this.scopeMode = ScopeMode.admin});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TimetableController(scopeMode: scopeMode));

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: const Text('Thời khóa biểu theo Lớp', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        actions: [
          Obx(() {
            if (controller.selectedSemesterId.value != null && controller.isMasterMode.value) {
              return TextButton.icon(
                icon: const Icon(Icons.calendar_month, color: Colors.amber, size: 20),
                label: const Text('Sinh lịch', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                onPressed: () => _showGenerateDialog(context, controller),
              );
            }
            return const SizedBox.shrink();
          })
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.academicYears.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFE65100)));
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                const SizedBox(height: 16),
                Text(controller.errorMessage.value, style: const TextStyle(color: Colors.redAccent)),
                const SizedBox(height: 16),
                AppButton.retry(onPressed: controller.fetchInitialData),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Header (Year -> Semester -> Class)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.teal, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            value: controller.selectedYearId.value,
                            hint: const Text('Chọn năm học'),
                            items: controller.academicYears.map((year) {
                              return DropdownMenuItem<int>(
                                value: year.academicYearId,
                                child: Text(year.yearName, style: const TextStyle(fontSize: 14)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                controller.selectedYearId.value = val;
                                if (controller.filteredSemesters.isNotEmpty) {
                                  controller.selectedSemesterId.value = controller.filteredSemesters.first.semesterId;
                                } else {
                                  controller.selectedSemesterId.value = null;
                                }
                                if (controller.filteredClasses.isNotEmpty) {
                                  controller.selectedClassId.value = controller.filteredClasses.first.classId;
                                } else {
                                  controller.selectedClassId.value = null;
                                }
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.view_week, color: Colors.blue, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            value: controller.selectedSemesterId.value,
                            hint: const Text('Chọn học kỳ'),
                            items: controller.filteredSemesters.map((sem) {
                              return DropdownMenuItem<int>(
                                value: sem.semesterId,
                                child: Text(sem.semesterName, style: const TextStyle(fontSize: 14)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                controller.selectedSemesterId.value = val;
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 8, thickness: 1),
                  Row(
                    children: [
                      const Icon(Icons.class_, color: Colors.orange, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            value: controller.selectedClassId.value,
                            hint: const Text('Chọn lớp học'),
                            items: controller.filteredClasses.map((cls) {
                              return DropdownMenuItem<int>(
                                value: cls.classId,
                                child: Text(cls.className, style: const TextStyle(fontSize: 14)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                controller.selectedClassId.value = val;
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),

            Obx(() {
              if (controller.selectedSemesterId.value == null) return const SizedBox.shrink();
              final sem = controller.semesters.firstWhereOrNull((s) => s.semesterId == controller.selectedSemesterId.value);
              if (sem == null) return const SizedBox.shrink();

              // Định dạng ngày đẹp
              final startStr = DateFormat('dd/MM/yyyy').format(DateTime.parse(sem.startDate));
              final endStr = DateFormat('dd/MM/yyyy').format(DateTime.parse(sem.endDate));

              return Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blueAccent, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Thời gian kỳ: $startStr - $endStr',
                      style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 2),

            if (controller.selectedYearId.value == null || controller.selectedSemesterId.value == null || controller.selectedClassId.value == null)
              const Expanded(child: Center(child: Text('Vui lòng chọn Năm học, Học kỳ và Lớp học.')))
            else ...[
              // Toggle Mode (Lịch thực tế vs Cấu hình Master)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Lịch thực tế (Ngày)')),
                        selected: !controller.isMasterMode.value,
                        onSelected: (selected) {
                          if (selected) controller.isMasterMode.value = false;
                        },
                        selectedColor: const Color(0xFFC2410C),
                        backgroundColor: Colors.grey.shade100,
                        labelStyle: TextStyle(
                          color: !controller.isMasterMode.value ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Cấu hình Lịch mẫu (Tuần)')),
                        selected: controller.isMasterMode.value,
                        onSelected: (selected) {
                          if (selected) controller.isMasterMode.value = true;
                        },
                        selectedColor: const Color(0xFFC2410C),
                        backgroundColor: Colors.grey.shade100,
                        labelStyle: TextStyle(
                          color: controller.isMasterMode.value ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // TODO: xóa sau khi test - Nút xóa lịch đã sinh
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                color: Colors.white,
                child: AppButton(
                  variant: AppButtonVariant.dangerOutlined,
                  icon: Icons.delete_sweep,
                  label: 'TODO: Xóa sau khi test - Xóa lịch đã sinh',
                  onPressed: () => _showClearConfirmDialog(context, controller),
                ),
              ),

              // UI tương ứng với từng chế độ
              if (controller.isMasterMode.value) ...[
                // Cấu hình Master Mode (Chỉ chọn Thứ 2 - CN)
                Container(
                  height: 55,
                  color: Colors.white,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      children: List.generate(7, (index) {
                        final day = index + 2; // 2 to 8
                        final isSelected = controller.selectedMasterDay.value == day;
                        final dayName = day == 8 ? 'Chủ Nhật' : 'Thứ $day';

                        return GestureDetector(
                          onTap: () {
                            controller.selectedMasterDay.value = day;
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFC2410C) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isSelected ? const Color(0xFFC2410C) : Colors.grey.shade300),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              dayName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Danh sách slots của Master Mode
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: controller.slots.length,
                    itemBuilder: (context, slotIndex) {
                      final slot = controller.slots[slotIndex];
                      final matchingTemplates = controller.filteredTemplatesByDay.where((t) => t.slotId == slot.slotId).toList();

                      if (matchingTemplates.isEmpty) {
                        return Card(
                          color: const Color(0xFFF3F4F6),
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: InkWell(
                            onTap: () => _showTemplateFormDialog(context, controller, preselectedSlotId: slot.slotId),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Icon(Icons.schedule, color: Colors.grey.shade500, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${slot.slotName} (${slot.startTime.substring(0, 5)} - ${slot.endTime.substring(0, 5)})',
                                      style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Icon(Icons.add_circle_outline, color: Colors.grey.shade500),
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Column(
                          children: matchingTemplates.map((t) {
                        return Card(
                          color: Colors.white,
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  width: 4,
                                  decoration: const BoxDecoration(
                                    color: Colors.blueAccent,
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time, size: 16, color: Colors.blueAccent),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${t.startTime.substring(0, 5)} - ${t.endTime.substring(0, 5)} (${t.slotName})',
                                          style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Text(
                                            'Lịch mẫu',
                                            style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      t.subjectName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.person_outline, size: 16, color: Colors.black54),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            t.teacherName,
                                            style: const TextStyle(color: Colors.black54, fontSize: 13),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on_outlined, size: 16, color: Colors.black54),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            t.roomName ?? 'Phòng chưa xếp',
                                            style: const TextStyle(color: Colors.black54, fontSize: 13),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent, size: 20),
                                              onPressed: () => _showTemplateFormDialog(context, controller, template: t),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                            const SizedBox(width: 12),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                              onPressed: () => _showDeleteTemplateConfirm(context, controller, t),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                          }).toList(),
                        );
                      }
                    },
                  ),
                ),
              ] else ...[
                // Lịch thực tế (Ngày cụ thể)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Bộ chọn Tháng/Năm nhanh
                      TextButton.icon(
                        icon: const Icon(Icons.calendar_month, color: Color(0xFFC2410C)),
                        label: Text(
                          DateFormat('MMMM yyyy').format(controller.selectedDate.value),
                          style: const TextStyle(color: Color(0xFFC2410C), fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: controller.selectedDate.value,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            if (!controller.isDateInSelectedSemester(picked)) {
                              Get.snackbar('Cảnh báo', 'Ngày chọn nằm ngoài thời gian học kỳ.', backgroundColor: Colors.orange, colorText: Colors.white);
                              return;
                            }
                            controller.selectedDate.value = picked;
                          }
                        },
                      ),
                      // Nút Lùi/Tiến tuần
                      Row(
                        children: [
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.arrow_back_ios, size: 16, color: Colors.black87),
                            tooltip: 'Tuần trước',
                            onPressed: () {
                              controller.selectedDate.value = controller.selectedDate.value.subtract(const Duration(days: 7));
                            },
                          ),
                          const Text('Tuần', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black87),
                            tooltip: 'Tuần sau',
                            onPressed: () {
                              controller.selectedDate.value = controller.selectedDate.value.add(const Duration(days: 7));
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1),

                // Day Selector
                Container(
                  height: 65,
                  color: Colors.white,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      children: controller.currentWeekDays.map((day) {
                        final isSelected = DateFormat('yyyy-MM-dd').format(controller.selectedDate.value) == DateFormat('yyyy-MM-dd').format(day);
                        final dayVal = day.weekday;
                        final dayName = dayVal == 7 ? 'CN' : 'T${dayVal + 1}';
                        final dayStr = DateFormat('dd/MM').format(day);

                        return GestureDetector(
                          onTap: () {
                            controller.selectedDate.value = day;
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: 60,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFC2410C) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isSelected ? const Color(0xFFC2410C) : Colors.grey.shade300),
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  dayName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: isSelected ? Colors.white : Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dayStr,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Danh sách các slots thực tế
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: controller.slots.length,
                    itemBuilder: (context, slotIndex) {
                      final slot = controller.slots[slotIndex];
                      final slotTimetables = controller.filteredTimetablesByDay.where((t) => t.slotName == slot.slotName).toList();

                      if (slotTimetables.isEmpty) {
                        return Card(
                          color: const Color(0xFFF3F4F6),
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: InkWell(
                            onTap: () => _showFormDialog(context, controller, preselectedSlotId: slot.slotId),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Icon(Icons.schedule, color: Colors.grey.shade500, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${slot.slotName} (${slot.startTime.substring(0, 5)} - ${slot.endTime.substring(0, 5)})',
                                      style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Icon(Icons.add_circle_outline, color: Colors.grey.shade500),
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Column(
                          children: slotTimetables.map((t) {
                        return Card(
                          color: Colors.white,
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  width: 4,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFC2410C),
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time, size: 16, color: Color(0xFFC2410C)),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${t.startTime.substring(0, 5)} - ${t.endTime.substring(0, 5)} (${t.slotName})',
                                          style: const TextStyle(
                                            color: Color(0xFFC2410C),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: TimetableStatusHelper.color(t.status).withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            TimetableStatusHelper.label(t.status),
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: TimetableStatusHelper.color(t.status)),
                                          ),
                                        ),
                                        if (t.note != null && t.note!.isNotEmpty) ...[
                                          const SizedBox(width: 8),
                                          Expanded(child: Text(t.note!, style: const TextStyle(fontSize: 11, color: Colors.black54), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      t.subjectName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.person_outline, size: 16, color: Colors.black54),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            t.teacherName,
                                            style: const TextStyle(color: Colors.black54, fontSize: 13),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on_outlined, size: 16, color: Colors.black54),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            t.roomName ?? 'Phòng chưa xếp',
                                            style: const TextStyle(color: Colors.black54, fontSize: 13),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        PopupMenuButton<int>(
                                          icon: const Icon(Icons.more_vert, color: Colors.black54, size: 20),
                                          padding: EdgeInsets.zero,
                                          onSelected: (val) {
                                            if (val == 1) {
                                              _showFormDialog(context, controller, timetable: t);
                                            } else if (val == 2) {
                                              _showDeleteConfirm(context, controller, t);
                                            } else if (val >= 10 && val <= 13) {
                                              final statuses = [1, 2, 3, 4];
                                              _showStatusNoteDialog(context, controller, t, statuses[val - 10]);
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(value: 1, child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text('Sửa tiết học')])),
                                            const PopupMenuItem(value: 10, child: Row(children: [Icon(Icons.check_circle_outline, size: 18), SizedBox(width: 8), Text('Bình thường')])),
                                            const PopupMenuItem(value: 11, child: Row(children: [Icon(Icons.swap_horiz, size: 18), SizedBox(width: 8), Text('Đổi lịch')])),
                                            const PopupMenuItem(value: 12, child: Row(children: [Icon(Icons.event_busy, size: 18), SizedBox(width: 8), Text('Nghỉ học')])),
                                            const PopupMenuItem(value: 13, child: Row(children: [Icon(Icons.event_available, size: 18), SizedBox(width: 8), Text('Dạy bù')])),
                                            const PopupMenuItem(value: 2, child: Row(children: [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 8), Text('Xóa lịch học', style: TextStyle(color: Colors.red))])),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                          }).toList(),
                        );
                      }
                    },
                  ),
                ),
              ]
            ]
          ],
        );
      }),
      floatingActionButton: Obx(() {
        if (controller.selectedClassId.value == null) return const SizedBox.shrink();
        return AppFab.add(
          onPressed: () {
            if (controller.isMasterMode.value) {
              _showTemplateFormDialog(context, controller);
            } else {
              _showFormDialog(context, controller);
            }
          },
        );
      }),
    );
  }

  void _showFormDialog(BuildContext context, TimetableController controller, {int? preselectedSlotId, TimetableModel? timetable}) {
    if (controller.selectedYearId.value == null || controller.selectedSemesterId.value == null || controller.selectedClassId.value == null) {
      Get.snackbar('Lỗi', 'Vui lòng chọn Năm học, Học kỳ và Lớp học trước', backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    int? selectedTaId = timetable?.teachingAssignmentId;
    int? selectedSlotId = timetable?.timetableId != null ? controller.slots.firstWhereOrNull((s) => s.slotName == timetable!.slotName)?.slotId : preselectedSlotId;
    bool isSlotFixed = preselectedSlotId != null || timetable != null;

    final roomController = TextEditingController(text: timetable?.roomName);

    // Lọc Phân công giảng dạy theo Lớp và Kỳ đang chọn
    final classTAs = controller.assignments
        .where((ta) => ta.classId == controller.selectedClassId.value && ta.semesterId == controller.selectedSemesterId.value)
        .toList();
    
    if (selectedTaId == null && classTAs.isNotEmpty) {
      selectedTaId = classTAs.first.teachingAssignmentId;
    }
    
    if (controller.slots.isNotEmpty && selectedSlotId == null) {
      selectedSlotId = controller.slots.first.slotId;
    }

    Get.dialog(
      StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(timetable == null ? 'Thêm Lịch học thực tế' : 'Sửa Lịch học thực tế', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Phân công giảng dạy',
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  value: selectedTaId,
                  isExpanded: true,
                  items: classTAs.map((ta) {
                    final teacher = controller.teachers.firstWhereOrNull((t) => t.userId == ta.teacherId)?.fullName ?? '?';
                    final subject = controller.subjects.firstWhereOrNull((s) => s.subjectId == ta.subjectId)?.subjectName ?? '?';
                    return DropdownMenuItem<int>(
                      value: ta.teachingAssignmentId,
                      child: Text('$subject ($teacher)', overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedTaId = val;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Tiết học',
                    filled: true,
                    fillColor: isSlotFixed ? Colors.grey.shade100 : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  ),
                  value: selectedSlotId,
                  items: controller.slots.map((s) {
                    return DropdownMenuItem<int>(
                      value: s.slotId,
                      child: Text(s.slotName),
                    );
                  }).toList(),
                  onChanged: isSlotFixed ? null : (val) {
                    setState(() {
                      selectedSlotId = val;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: roomController,
                  decoration: InputDecoration(
                    labelText: 'Phòng học (VD: P.101)',
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            AppDialogActions.reactive(
              isSubmitting: controller.isSubmitting,
              onCancel: () => Get.back(),
              onSubmit: () {
                if (selectedTaId == null || selectedSlotId == null) {
                  Get.snackbar('Lỗi', 'Vui lòng chọn phân công giảng dạy và tiết học', backgroundColor: Colors.redAccent, colorText: Colors.white);
                  return;
                }
                final date = DateFormat('yyyy-MM-dd').format(controller.selectedDate.value);
                if (!controller.isDateInSelectedSemester(controller.selectedDate.value)) {
                  Get.snackbar('Lỗi', 'Ngày chọn nằm ngoài thời gian học kỳ.', backgroundColor: Colors.redAccent, colorText: Colors.white);
                  return;
                }
                final conflict = controller.checkScheduleConflict(
                  taId: selectedTaId!,
                  slotId: selectedSlotId!,
                  date: date,
                  excludeTimetableId: timetable?.timetableId,
                );
                if (conflict != null) {
                  Get.snackbar('Cảnh báo trùng lịch', conflict, backgroundColor: Colors.orange, colorText: Colors.white);
                  return;
                }
                if (timetable == null) {
                  controller.createTimetable(
                    selectedTaId!,
                    DateFormat('yyyy-MM-dd').format(controller.selectedDate.value),
                    selectedSlotId!,
                    roomController.text.trim(),
                  );
                } else {
                  controller.updateTimetableDetail(
                    timetable.timetableId,
                    selectedTaId!,
                    selectedSlotId!,
                    roomController.text.trim(),
                  );
                }
              },
            ),
          ],
        );
      }),
    );
  }

  void _showTemplateFormDialog(BuildContext context, TimetableController controller, {int? preselectedSlotId, TimetableTemplateModel? template}) {
    if (controller.selectedYearId.value == null || controller.selectedSemesterId.value == null || controller.selectedClassId.value == null) {
      Get.snackbar('Lỗi', 'Vui lòng chọn Năm học, Học kỳ và Lớp học trước', backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    final isEditing = template != null;
    int? selectedTaId = template?.teachingAssignmentId;
    int? selectedSlotId = template?.slotId ?? preselectedSlotId;
    final int dayOfWeek = template?.dayOfWeek ?? controller.selectedMasterDay.value;

    final roomController = TextEditingController(text: template?.roomName);

    final classTAs = controller.assignments
        .where((ta) => ta.classId == controller.selectedClassId.value && ta.semesterId == controller.selectedSemesterId.value)
        .toList();
    
    if (selectedTaId == null && classTAs.isNotEmpty) {
      selectedTaId = classTAs.first.teachingAssignmentId;
    }
    
    if (controller.slots.isNotEmpty && selectedSlotId == null) {
      selectedSlotId = controller.slots.first.slotId;
    }

    String dayLabel(int day) => day == 8 ? 'Chủ Nhật' : 'Thứ $day';
    final slotLabel = template?.slotName ??
        controller.slots.firstWhereOrNull((s) => s.slotId == selectedSlotId)?.slotName ??
        '—';

    Get.dialog(
      StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isEditing ? 'Sửa giáo viên / phòng' : 'Thêm Cấu hình Lịch mẫu',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isEditing) ...[
                  Text('${dayLabel(dayOfWeek)} · $slotLabel', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
                  const SizedBox(height: 4),
                  const Text(
                    'Không đổi thứ hoặc tiết. Muốn đổi slot hãy xóa và tạo lại.',
                    style: TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                  const SizedBox(height: 16),
                ],
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Phân công giảng dạy (GV / môn)',
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  value: selectedTaId,
                  isExpanded: true,
                  items: classTAs.map((ta) {
                    final teacher = controller.teachers.firstWhereOrNull((t) => t.userId == ta.teacherId)?.fullName ?? '?';
                    final subject = controller.subjects.firstWhereOrNull((s) => s.subjectId == ta.subjectId)?.subjectName ?? '?';
                    return DropdownMenuItem<int>(
                      value: ta.teachingAssignmentId,
                      child: Text('$subject ($teacher)', overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedTaId = val;
                    });
                  },
                ),
                if (!isEditing) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Tiết học',
                      filled: true,
                      fillColor: preselectedSlotId != null ? Colors.grey.shade100 : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    ),
                    value: selectedSlotId,
                    items: controller.slots.map((s) {
                      return DropdownMenuItem<int>(
                        value: s.slotId,
                        child: Text(s.slotName),
                      );
                    }).toList(),
                    onChanged: preselectedSlotId != null ? null : (val) {
                      setState(() {
                        selectedSlotId = val;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Thứ: ${dayLabel(dayOfWeek)} (theo tab đang chọn)',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: roomController,
                  decoration: InputDecoration(
                    labelText: 'Phòng học (VD: P.101)',
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            AppDialogActions.reactive(
              isSubmitting: controller.isSubmitting,
              onCancel: () => Get.back(),
              onSubmit: () {
                if (selectedTaId == null || selectedSlotId == null) {
                  Get.snackbar('Lỗi', 'Vui lòng chọn phân công giảng dạy', backgroundColor: Colors.redAccent, colorText: Colors.white);
                  return;
                }
                final conflict = controller.checkTemplateConflict(
                  taId: selectedTaId!,
                  dayOfWeek: dayOfWeek,
                  slotId: selectedSlotId!,
                  excludeTemplateId: template?.templateId,
                );
                if (conflict != null) {
                  Get.snackbar('Cảnh báo trùng lịch', conflict, backgroundColor: Colors.orange, colorText: Colors.white);
                  return;
                }
                if (!isEditing) {
                  controller.createTimetableTemplate(
                    selectedTaId!,
                    dayOfWeek,
                    selectedSlotId!,
                    roomController.text.trim(),
                  );
                } else {
                  controller.updateTimetableTemplate(
                    template!.templateId,
                    selectedTaId!,
                    template.dayOfWeek,
                    template.slotId,
                    roomController.text.trim(),
                  );
                }
              },
            ),
          ],
        );
      }),
    );
  }

  void _showGenerateDialog(BuildContext context, TimetableController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sinh lịch từ lịch mẫu', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Bạn có chắc chắn muốn sinh tự động lịch học cho lớp này trong Học kỳ hiện tại từ cấu hình lịch mẫu?\n\n'
          'Lưu ý: Tất cả lịch học của học kỳ này đã sinh trước đó sẽ bị xóa để ghi đè lịch mới.',
        ),
        actions: [
          AppDialogActions.reactive(
            isSubmitting: controller.isSubmitting,
            onCancel: () => Get.back(),
            labels: AppDialogLabels.confirm,
            submitColor: const Color(0xFFC2410C),
            disableCancelWhileSubmitting: true,
            onSubmit: () {
              Get.back();
              controller.generateFromDatabaseTemplates();
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, TimetableController controller, TimetableModel t) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xóa', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Bạn có chắc chắn muốn xóa tiết học thực tế này không?'),
        actions: [
          AppDialogActions.reactive(
            isSubmitting: controller.isSubmitting,
            onCancel: () => Get.back(),
            labels: AppDialogLabels.delete,
            disableCancelWhileSubmitting: true,
            onSubmit: () => controller.deleteTimetable(t.timetableId),
          ),
        ],
      ),
    );
  }

  void _showDeleteTemplateConfirm(BuildContext context, TimetableController controller, TimetableTemplateModel t) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xóa', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Bạn có chắc chắn muốn xóa lịch mẫu này không?'),
        actions: [
          AppDialogActions.reactive(
            isSubmitting: controller.isSubmitting,
            onCancel: () => Get.back(),
            labels: AppDialogLabels.delete,
            disableCancelWhileSubmitting: true,
            onSubmit: () => controller.deleteTimetableTemplate(t.templateId),
          ),
        ],
      ),
    );
  }

  void _showStatusNoteDialog(BuildContext context, TimetableController controller, TimetableModel t, int status) {
    final noteController = TextEditingController(text: t.note);
    Get.dialog(
      AlertDialog(
        title: Text('Cập nhật: ${TimetableStatusHelper.label(status)}'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(labelText: 'Ghi chú (tuỳ chọn)'),
          maxLines: 2,
        ),
        actions: [
          AppDialogActions.reactive(
            isSubmitting: controller.isSubmitting,
            onCancel: () => Get.back(),
            labels: AppDialogLabels.save,
            onSubmit: () {
              controller.updateTimetableStatus(
                t.timetableId,
                status,
                noteController.text.trim().isEmpty ? null : noteController.text.trim(),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showClearConfirmDialog(BuildContext context, TimetableController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('TODO: Xóa sau khi test', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
        content: const Text(
          'Hành động này sẽ XÓA TOÀN BỘ lịch học thực tế đã sinh của lớp học trong học kỳ hiện tại.\n\n'
          'Dữ liệu cấu hình lịch mẫu sẽ KHÔNG bị ảnh hưởng.',
        ),
        actions: [
          AppDialogActions.reactive(
            isSubmitting: controller.isSubmitting,
            onCancel: () => Get.back(),
            labels: AppDialogLabels.confirmDelete,
            disableCancelWhileSubmitting: true,
            onSubmit: () {
              Get.back();
              controller.clearGeneratedTimetables();
            },
          ),
        ],
      ),
    );
  }
}

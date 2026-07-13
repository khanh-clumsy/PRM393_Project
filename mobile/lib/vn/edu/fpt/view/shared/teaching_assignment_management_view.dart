import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/auth/role_context.dart';
import '../../controllers/teaching_assignment_controller.dart';
import '../../models/teaching_assignment_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog_actions.dart';

class TeachingAssignmentManagementView extends StatelessWidget {
  final ScopeMode scopeMode;
  const TeachingAssignmentManagementView({super.key, this.scopeMode = ScopeMode.admin});

  static int? _validDropdownValue(int? value, Iterable<int> options) {
    if (value == null) return null;
    return options.contains(value) ? value : null;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TeachingAssignmentController(scopeMode: scopeMode));

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: const Text('Phân công Giảng dạy', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
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
          children: [
            // Filter Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.teal, size: 20),
                      const SizedBox(width: 8),
                      const Text('Năm học:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(width: 16),
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
                                controller.onYearChanged(val);
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
                      const Icon(Icons.view_week, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      const Text('Học kỳ:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            value: _validDropdownValue(
                              controller.selectedSemesterId.value,
                              controller.filteredSemesters.map((s) => s.semesterId),
                            ),
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
                  Row(
                    children: [
                      const Icon(Icons.class_, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      const Text('Lớp học:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            value: _validDropdownValue(
                              controller.selectedClassId.value,
                              controller.filteredClasses.map((c) => c.classId),
                            ),
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
            

            // Main List
            Expanded(
              child: Builder(builder: (context) {
                if (controller.selectedYearId.value == null || controller.selectedSemesterId.value == null || controller.selectedClassId.value == null) {
                  return const Center(child: Text('Vui lòng chọn Năm học, Học kỳ và Lớp học.'));
                }

                if (controller.filteredAssignments.isEmpty) {
                  return const Center(child: Text('Chưa có dữ liệu phân công giảng dạy cho học kỳ này.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredAssignments.length,
                  itemBuilder: (context, index) {
                    final ta = controller.filteredAssignments[index];
                    final teacher = controller.teachers.firstWhereOrNull((t) => t.userId == ta.teacherId);
                    final cls = controller.classes.firstWhereOrNull((c) => c.classId == ta.classId);
                    final subject = controller.subjects.firstWhereOrNull((s) => s.subjectId == ta.subjectId);
                    
                    return Card(
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE3F2FD),
                          child: Icon(Icons.assignment_ind, color: Colors.blue),
                        ),
                        title: Text('${teacher?.fullName ?? 'N/A'} - ${subject?.subjectName ?? 'N/A'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Lớp: ${cls?.className ?? 'N/A'}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
                              onPressed: () => _showFormDialog(context, controller, ta: ta),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => _showDeleteConfirm(context, controller, ta),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        );
      }),
      floatingActionButton: AppFab.add(
        onPressed: () => _showFormDialog(context, controller),
      ),
    );
  }

  void _showFormDialog(BuildContext context, TeachingAssignmentController controller, {TeachingAssignmentModel? ta}) {
    if (controller.selectedYearId.value == null || controller.selectedSemesterId.value == null || controller.selectedClassId.value == null) {
      Get.snackbar('Lỗi', 'Vui lòng chọn đầy đủ Năm học, Học kỳ, Lớp học', backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    int? selectedTeacherId = ta?.teacherId;
    int? selectedClassId = ta?.classId ?? controller.selectedClassId.value;
    int? selectedSubjectId = ta?.subjectId;

    if (ta == null) {
      if (controller.teachers.isNotEmpty) selectedTeacherId = controller.teachers.first.userId;
      if (controller.subjects.isNotEmpty) selectedSubjectId = controller.subjects.first.subjectId;
    }

    Get.dialog(
      StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(ta == null ? 'Thêm Phân công' : 'Sửa Phân công', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Giáo viên',
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  value: selectedTeacherId,
                  items: controller.teachers.map((t) {
                    return DropdownMenuItem<int>(
                      value: t.userId,
                      child: Text(t.fullName),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedTeacherId = val;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Môn học',
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  value: selectedSubjectId,
                  items: controller.activeSubjects.map((s) {
                    return DropdownMenuItem<int>(
                      value: s.subjectId,
                      child: Text(s.subjectName),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedSubjectId = val;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Lớp học (thuộc Năm học đang chọn)',
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  value: selectedClassId,
                  items: controller.filteredClasses.map((c) {
                    return DropdownMenuItem<int>(
                      value: c.classId,
                      child: Text(c.className),
                    );
                  }).toList(),
                  onChanged: null, // Vô hiệu hóa chọn vì đã ở sẵn 1 lớp học
                ),
              ],
            ),
          ),
          actions: [
            AppDialogActions.reactive(
              isSubmitting: controller.isSubmitting,
              onCancel: () => Get.back(),
              labels: AppDialogLabels.save,
              onSubmit: () {
                if (selectedTeacherId == null || selectedClassId == null || selectedSubjectId == null) {
                  Get.snackbar('Lỗi', 'Vui lòng chọn đầy đủ thông tin', backgroundColor: Colors.redAccent, colorText: Colors.white);
                  return;
                }
                if (ta == null) {
                  controller.createAssignment(selectedTeacherId!, selectedClassId!, selectedSubjectId!, controller.selectedSemesterId.value!);
                } else {
                  controller.updateAssignment(ta.teachingAssignmentId, selectedTeacherId!, selectedClassId!, selectedSubjectId!, controller.selectedSemesterId.value!);
                }
              },
            ),
          ],
        );
      }),
    );
  }

  void _showDeleteConfirm(BuildContext context, TeachingAssignmentController controller, TeachingAssignmentModel ta) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận hủy', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Bạn có chắc chắn muốn hủy phân công này không?'),
        actions: [
          AppDialogActions.reactive(
            isSubmitting: controller.isSubmitting,
            onCancel: () => Get.back(),
            labels: AppDialogLabels.unassign,
            disableCancelWhileSubmitting: true,
            onSubmit: () => controller.deleteAssignment(ta.teachingAssignmentId),
          ),
        ],
      ),
    );
  }
}

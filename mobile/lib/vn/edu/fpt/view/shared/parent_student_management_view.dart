import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/parent_student_controller.dart';
import '../../models/parent_student_model.dart';

class ParentStudentManagementView extends StatelessWidget {
  const ParentStudentManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ParentStudentController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: const Text('Liên kết Phụ huynh - Học sinh', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.allParents.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFE65100)));
        }

        if (controller.errorMessage.value.isNotEmpty && controller.allParents.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                const SizedBox(height: 16),
                Text(controller.errorMessage.value, style: const TextStyle(color: Colors.redAccent)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.fetchInitialData,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (controller.allParents.isEmpty) {
          return const Center(child: Text('Không có dữ liệu phụ huynh nào trong hệ thống.'));
        }

        return Column(
          children: [
            // Filter Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.family_restroom, color: Colors.blue, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return DropdownMenu<int>(
                          width: constraints.maxWidth,
                          initialSelection: controller.selectedParentId.value,
                          enableFilter: true,
                          requestFocusOnTap: true,
                          label: const Text('Tìm hoặc chọn Phụ huynh', style: TextStyle(color: Colors.grey)),
                          inputDecorationTheme: const InputDecorationTheme(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                          ),
                          dropdownMenuEntries: controller.allParents.map((p) {
                            return DropdownMenuEntry<int>(
                              value: p.userId,
                              label: '${p.fullName} (${p.username})',
                            );
                          }).toList(),
                          onSelected: (val) {
                            if (val != null) {
                              controller.selectedParentId.value = val;
                              controller.fetchByParent(val);
                            }
                          },
                        );
                      }
                    ),
                  ),
                ],
              ),
            ),
            
            // List Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Danh sách liên kết (${controller.parentStudents.length})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // List
            Expanded(
              child: controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFE65100)))
                  : controller.parentStudents.isEmpty
                      ? const Center(child: Text('Chưa có liên kết học sinh nào', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: controller.parentStudents.length,
                          itemBuilder: (context, index) {
                            final ps = controller.parentStudents[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.orange.shade50,
                                  child: const Icon(Icons.school, color: Colors.orange),
                                ),
                                title: Text(ps.studentName ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Mã HS: ${ps.studentCode ?? 'N/A'}'),
                                    Text('Quan hệ: ${ps.relationship}', style: const TextStyle(color: Colors.blue)),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                      onPressed: () => _showFormDialog(context, controller, ps: ps),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                      onPressed: () => _showDeleteConfirm(context, controller, ps),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        );
      }),
      floatingActionButton: Obx(() {
        if (controller.selectedParentId.value == null) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          onPressed: () => _showFormDialog(context, controller),
          backgroundColor: const Color(0xFFE65100),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Thêm Liên kết', style: TextStyle(color: Colors.white)),
        );
      }),
    );
  }

  void _showFormDialog(BuildContext context, ParentStudentController controller, {ParentStudentModel? ps}) {
    final isEditing = ps != null;
    int? selectedStudentId = ps?.studentId;
    final relationshipController = TextEditingController(text: ps?.relationship ?? '');

    // Available students to link (if adding new)
    final availableStudents = controller.allStudents.where((s) {
      if (isEditing && s.userId == ps.studentId) return true; // keep current
      return !controller.parentStudents.any((existing) => existing.studentId == s.userId);
    }).toList();

    Get.dialog(
      StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isEditing ? 'Sửa Liên kết' : 'Thêm Liên kết', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isEditing)
                  DropdownMenu<int>(
                    width: MediaQuery.of(context).size.width * 0.7,
                    enableFilter: true,
                    requestFocusOnTap: true,
                    label: const Text('Tìm hoặc chọn Học sinh'),
                    inputDecorationTheme: InputDecorationTheme(
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    dropdownMenuEntries: availableStudents.map((s) {
                      return DropdownMenuEntry<int>(
                        value: s.userId,
                        label: '${s.fullName} (${s.username})',
                      );
                    }).toList(),
                    onSelected: (val) {
                      setState(() {
                        selectedStudentId = val;
                      });
                    },
                  ),
                if (!isEditing) const SizedBox(height: 16),
                TextField(
                  controller: relationshipController,
                  decoration: InputDecoration(
                    labelText: 'Mối quan hệ (VD: Bố, Mẹ)',
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
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE65100),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final rel = relationshipController.text.trim();
                if (rel.isEmpty) {
                  Get.snackbar('Lỗi', 'Vui lòng nhập mối quan hệ', backgroundColor: Colors.redAccent, colorText: Colors.white);
                  return;
                }
                
                if (isEditing) {
                  controller.updateParentStudent(ps.parentStudentId, rel, controller.selectedParentId.value!);
                } else {
                  if (selectedStudentId == null) {
                    Get.snackbar('Lỗi', 'Vui lòng chọn học sinh', backgroundColor: Colors.redAccent, colorText: Colors.white);
                    return;
                  }
                  controller.createParentStudent(controller.selectedParentId.value!, selectedStudentId!, rel);
                }
              },
              child: Text(isEditing ? 'Lưu' : 'Thêm'),
            ),
          ],
        );
      }),
    );
  }

  void _showDeleteConfirm(BuildContext context, ParentStudentController controller, ParentStudentModel ps) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xóa', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc chắn muốn xóa liên kết với học sinh ${ps.studentName}?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              controller.deleteParentStudent(ps.parentStudentId, controller.selectedParentId.value!);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/announcement_controller.dart';
import '../../models/announcement_model.dart';
import 'package:intl/intl.dart';

class AnnouncementManagementView extends StatelessWidget {
  const AnnouncementManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AnnouncementController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: const Text('Quản lý Bảng tin', style: TextStyle(fontWeight: FontWeight.bold)),
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
                ElevatedButton(
                  onPressed: controller.fetchInitialData,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (controller.announcements.isEmpty) {
          return const Center(child: Text('Chưa có thông báo nào.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.announcements.length,
          itemBuilder: (context, index) {
            final announcement = controller.announcements[index];
            final date = DateTime.tryParse(announcement.createdAt);
            final dateStr = date != null ? DateFormat('dd/MM/yyyy HH:mm').format(date) : announcement.createdAt;
            
            Color priorityColor = Colors.green;
            if (announcement.priority.toLowerCase() == 'high') priorityColor = Colors.red;
            if (announcement.priority.toLowerCase() == 'medium') priorityColor = Colors.orange;

            return Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: priorityColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            announcement.priority.toUpperCase(),
                            style: TextStyle(color: priorityColor, fontWeight: FontWeight.bold, fontSize: 10),
                          ),
                        ),
                        Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(announcement.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                      announcement.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => _showFormDialog(context, controller, announcement: announcement),
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Sửa'),
                        ),
                        TextButton.icon(
                          onPressed: () => _showDeleteConfirm(context, controller, announcement),
                          icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                          label: const Text('Xóa', style: TextStyle(color: Colors.redAccent)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(context, controller),
        backgroundColor: const Color(0xFFE65100),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showFormDialog(BuildContext context, AnnouncementController controller, {AnnouncementModel? announcement}) {
    final isEditing = announcement != null;
    final titleController = TextEditingController(text: announcement?.title ?? '');
    final contentController = TextEditingController(text: announcement?.content ?? '');
    
    String selectedType = announcement?.announcementType ?? 'General';
    String selectedPriority = announcement?.priority ?? 'Low';
    List<int> selectedClassIds = [];

    Get.dialog(
      StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(isEditing ? 'Sửa Bảng tin' : 'Tạo Bảng tin', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Tiêu đề', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Nội dung', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                if (!isEditing) ...[
                  const Text('Loại thông báo:', style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: selectedType,
                    items: const [
                      DropdownMenuItem(value: 'General', child: Text('Thông báo chung (Toàn trường)')),
                      DropdownMenuItem(value: 'Class', child: Text('Thông báo lớp (Chọn lớp)')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        selectedType = val!;
                        if (selectedType == 'General') {
                          selectedClassIds.clear();
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (selectedType == 'Class') ...[
                    const Text('Chọn lớp nhận thông báo:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ListView.builder(
                        itemCount: controller.classes.length,
                        itemBuilder: (context, index) {
                          final cls = controller.classes[index];
                          final isSelected = selectedClassIds.contains(cls.classId);
                          return CheckboxListTile(
                            title: Text(cls.className),
                            value: isSelected,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  selectedClassIds.add(cls.classId);
                                } else {
                                  selectedClassIds.remove(cls.classId);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
                const Text('Mức độ ưu tiên:', style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  isExpanded: true,
                  value: selectedPriority,
                  items: const [
                    DropdownMenuItem(value: 'Low', child: Text('Thấp (Low)')),
                    DropdownMenuItem(value: 'Medium', child: Text('Trung bình (Medium)')),
                    DropdownMenuItem(value: 'High', child: Text('Cao (High)')),
                  ],
                  onChanged: (val) {
                    setState(() {
                      selectedPriority = val!;
                    });
                  },
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
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE65100), foregroundColor: Colors.white),
              onPressed: () {
                final title = titleController.text.trim();
                final content = contentController.text.trim();

                if (title.isEmpty || content.isEmpty) {
                  Get.snackbar('Lỗi', 'Vui lòng nhập đủ tiêu đề và nội dung', backgroundColor: Colors.redAccent, colorText: Colors.white);
                  return;
                }

                if (!isEditing && selectedType == 'Class' && selectedClassIds.isEmpty) {
                  Get.snackbar('Lỗi', 'Vui lòng chọn ít nhất 1 lớp', backgroundColor: Colors.redAccent, colorText: Colors.white);
                  return;
                }

                if (isEditing) {
                  controller.updateAnnouncement(announcement.announcementId, title, content, selectedPriority);
                } else {
                  controller.createAnnouncement(title, content, selectedType, selectedPriority, selectedClassIds);
                }
              },
              child: Text(isEditing ? 'Lưu' : 'Đăng tải'),
            ),
          ],
        );
      }),
    );
  }

  void _showDeleteConfirm(BuildContext context, AnnouncementController controller, AnnouncementModel announcement) {
    Get.dialog(
      AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa bản tin này không?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              controller.deleteAnnouncement(announcement.announcementId);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

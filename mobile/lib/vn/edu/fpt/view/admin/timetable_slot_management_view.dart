import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/timetable_slot_controller.dart';
import '../../models/timetable_slot_model.dart';

class TimetableSlotManagementView extends StatelessWidget {
  const TimetableSlotManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TimetableSlotController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: const Text('Quản lý Ca học', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  onPressed: controller.fetchSlots,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (controller.slots.isEmpty) {
          return const Center(child: Text('Chưa có dữ liệu ca học.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.slots.length,
          itemBuilder: (context, index) {
            final slot = controller.slots[index];
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
                  backgroundColor: Color(0xFFFFF3E0),
                  child: Icon(Icons.schedule, color: Color(0xFFE65100)),
                ),
                title: Text(slot.slotName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${slot.startTime} - ${slot.endTime}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                      onPressed: () => _showFormDialog(context, controller, slot: slot),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => _showDeleteConfirm(context, controller, slot),
                    ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showFormDialog(BuildContext context, TimetableSlotController controller, {TimetableSlotModel? slot}) {
    final isEditing = slot != null;
    final nameController = TextEditingController(text: slot?.slotName ?? '');
    final startController = TextEditingController(text: slot?.startTime ?? '');
    final endController = TextEditingController(text: slot?.endTime ?? '');

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isEditing ? 'Sửa Ca Học' : 'Thêm Ca Học', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Tên ca học (VD: Slot 1)',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: startController,
                readOnly: true,
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) {
                    startController.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00";
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Giờ bắt đầu (HH:mm)',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  suffixIcon: const Icon(Icons.access_time, color: Colors.blue),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: endController,
                readOnly: true,
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) {
                    endController.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00";
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Giờ kết thúc (HH:mm)',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  suffixIcon: const Icon(Icons.access_time, color: Colors.blue),
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
              final name = nameController.text.trim();
              final start = startController.text.trim();
              final end = endController.text.trim();
              if (name.isEmpty || start.isEmpty || end.isEmpty) {
                Get.snackbar('Lỗi', 'Vui lòng nhập đủ thông tin', backgroundColor: Colors.redAccent, colorText: Colors.white);
                return;
              }
              
              try {
                final startParts = start.split(':');
                final endParts = end.split(':');
                final startMins = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
                final endMins = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
                if (startMins >= endMins) {
                  Get.snackbar('Lỗi', 'Giờ bắt đầu phải nhỏ hơn giờ kết thúc', backgroundColor: Colors.redAccent, colorText: Colors.white);
                  return;
                }
              } catch (e) {
                Get.snackbar('Lỗi', 'Định dạng giờ không hợp lệ', backgroundColor: Colors.redAccent, colorText: Colors.white);
                return;
              }
              if (isEditing) {
                controller.updateSlot(slot.slotId, name, start, end);
              } else {
                controller.createSlot(name, start, end);
              }
            },
            child: Text(isEditing ? 'Lưu' : 'Thêm'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, TimetableSlotController controller, TimetableSlotModel slot) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xóa', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc chắn muốn xóa "${slot.slotName}" không?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              controller.deleteSlot(slot.slotId);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

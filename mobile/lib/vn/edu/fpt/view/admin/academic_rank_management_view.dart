import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/academic_rank_controller.dart';
import '../../models/academic_rank_model.dart';

class AcademicRankManagementView extends StatelessWidget {
  const AcademicRankManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AcademicRankController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: const Text('Quản lý Xếp loại', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  onPressed: controller.fetchRanks,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (controller.ranks.isEmpty) {
          return const Center(child: Text('Chưa có dữ liệu xếp loại.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.ranks.length,
          itemBuilder: (context, index) {
            final rank = controller.ranks[index];
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
                  child: Icon(Icons.grade, color: Colors.orange),
                ),
                title: Text(rank.rankName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Điểm: ${rank.minScore} - ${rank.maxScore}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                      onPressed: () => _showFormDialog(context, controller, rank: rank),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => _showDeleteConfirm(context, controller, rank),
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

  void _showFormDialog(BuildContext context, AcademicRankController controller, {AcademicRankModel? rank}) {
    final isEditing = rank != null;
    final nameController = TextEditingController(text: rank?.rankName ?? '');
    final minController = TextEditingController(text: rank?.minScore.toString() ?? '');
    final maxController = TextEditingController(text: rank?.maxScore.toString() ?? '');

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isEditing ? 'Sửa Xếp Loại' : 'Thêm Xếp Loại', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Tên xếp loại (VD: Giỏi)',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: minController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Điểm tối thiểu (VD: 8.0)',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: maxController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Điểm tối đa (VD: 10.0)',
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
              final name = nameController.text.trim();
              final minText = minController.text.trim();
              final maxText = maxController.text.trim();

              if (name.isEmpty || minText.isEmpty || maxText.isEmpty) {
                Get.snackbar('Lỗi', 'Vui lòng nhập đủ thông tin', backgroundColor: Colors.redAccent, colorText: Colors.white);
                return;
              }

              final minVal = double.tryParse(minText);
              final maxVal = double.tryParse(maxText);

              if (minVal == null || maxVal == null) {
                Get.snackbar('Lỗi', 'Điểm phải là một con số hợp lệ', backgroundColor: Colors.redAccent, colorText: Colors.white);
                return;
              }

              if (minVal > maxVal) {
                 Get.snackbar('Lỗi', 'Điểm tối thiểu không được lớn hơn điểm tối đa', backgroundColor: Colors.redAccent, colorText: Colors.white);
                 return;
              }

              if (isEditing) {
                controller.updateRank(rank.rankId, name, minVal, maxVal);
              } else {
                controller.createRank(name, minVal, maxVal);
              }
            },
            child: Text(isEditing ? 'Lưu' : 'Thêm'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, AcademicRankController controller, AcademicRankModel rank) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xóa', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc chắn muốn xóa xếp loại "${rank.rankName}" không?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              controller.deleteRank(rank.rankId);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

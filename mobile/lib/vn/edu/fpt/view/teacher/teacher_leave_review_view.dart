import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/teacher_leave_review_controller.dart';
import '../../models/student_request_model.dart';

class TeacherLeaveReviewView extends StatefulWidget {
  const TeacherLeaveReviewView({super.key});

  @override
  State<TeacherLeaveReviewView> createState() => _TeacherLeaveReviewViewState();
}

class _TeacherLeaveReviewViewState extends State<TeacherLeaveReviewView> {
  late final TeacherLeaveReviewController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(TeacherLeaveReviewController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: const Text('Duyệt đơn nghỉ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Obx(() {
          if (_ctrl.isLoading.value) return const Center(child: CircularProgressIndicator());
          if (_ctrl.errorMessage.value.isNotEmpty) return Center(child: Text(_ctrl.errorMessage.value));
          if (_ctrl.pending.isEmpty) return const Center(child: Text('Không có đơn chờ duyệt.'));

          return RefreshIndicator(
            onRefresh: _ctrl.fetchPending,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _ctrl.pending.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildRequestCard(_ctrl.pending[index]),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRequestCard(StudentRequestModel req) {
    final date = DateFormat('dd/MM/yyyy').format(DateTime.parse(req.leaveDate));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFFFF3E0),
                child: Icon(Icons.event_busy_outlined, color: Color(0xFFE65100)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(req.studentName ?? 'Học sinh #${req.studentId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(date, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(req.reason, style: const TextStyle(fontSize: 13, height: 1.35)),
          if (req.attachmentUrl != null && req.attachmentUrl!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(req.attachmentUrl!, style: const TextStyle(fontSize: 12, color: Color(0xFFE65100))),
          ],
          const SizedBox(height: 14),
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _ctrl.isSubmitting.value ? null : () => _showRejectDialog(req.studentRequestId),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Từ chối'),
                    style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFC62828)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _ctrl.isSubmitting.value ? null : () => _ctrl.review(req.studentRequestId, 'Approved'),
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Duyệt'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showRejectDialog(int requestId) async {
    final noteCtrl = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lý do từ chối'),
        content: TextField(
          controller: noteCtrl,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Nhập ghi chú'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(context, noteCtrl.text.trim()), child: const Text('Từ chối')),
        ],
      ),
    );
    noteCtrl.dispose();
    if (note != null) {
      await _ctrl.review(requestId, 'Rejected', note: note);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/leave_request_controller.dart';
import '../../controllers/user_controller.dart';
import '../../models/student_request_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/student_welcome_app_bar.dart';

class LeaveRequestListPage extends StatefulWidget {
  final String? controllerTag;
  final int? studentId;
  final int? requestedBy;
  final String? title;
  final String? subtitle;

  const LeaveRequestListPage({
    super.key,
    this.controllerTag,
    this.studentId,
    this.requestedBy,
    this.title,
    this.subtitle,
  });

  @override
  State<LeaveRequestListPage> createState() => _LeaveRequestListPageState();
}

class _LeaveRequestListPageState extends State<LeaveRequestListPage> {
  late final LeaveRequestController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(LeaveRequestController(), tag: widget.controllerTag);
    if (widget.studentId != null && widget.requestedBy != null) {
      _ctrl.init(studentId: widget.studentId!, requestedBy: widget.requestedBy!);
    } else {
      _ctrl.initForCurrentStudent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userController = Get.isRegistered<UserController>() ? Get.find<UserController>() : null;

    return Obx(() {
      return Scaffold(
        backgroundColor: const Color(0xFFF9FAFC),
        appBar: userController == null
            ? AppBar(
                title: Text(widget.title ?? 'Đơn xin nghỉ'),
                backgroundColor: Colors.white,
                elevation: 0,
                scrolledUnderElevation: 0,
              )
            : StudentWelcomeAppBar(
                welcomeLine: userController.welcomeText,
              ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _ctrl.fetchRequests,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title ?? 'Đơn xin nghỉ',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle ?? 'Theo dõi và quản lý đơn xin nghỉ học.',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateLeaveRequestPage(controllerTag: widget.controllerTag),
                        ),
                      ),
                      icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                      label: const Text('Tạo đơn mới', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE65100),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 2,
                        shadowColor: const Color(0xFFE65100).withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Lịch sử gần đây',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
                  ),
                  const SizedBox(height: 8),
                  if (_ctrl.isLoading.value)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 36),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_ctrl.errorMessage.value.isNotEmpty)
                    _buildEmpty(_ctrl.errorMessage.value)
                  else if (_ctrl.requests.isEmpty)
                    _buildEmpty('Chưa có đơn xin nghỉ.')
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _ctrl.requests.length,
                      itemBuilder: (context, index) => _buildHistoryItem(_ctrl.requests[index]),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHistoryItem(StudentRequestModel req) {
    final isRejected = req.status == 'Rejected';
    final isApproved = req.status == 'Approved';

    final badgeBgColor = isApproved
        ? const Color(0xFFE8F5E9)
        : isRejected
            ? const Color(0xFFFFEBEE)
            : const Color(0xFFFFF3E0);
    final badgeTextColor = isApproved
        ? const Color(0xFF2E7D32)
        : isRejected
            ? const Color(0xFFC62828)
            : const Color(0xFFE65100);
    final statusIcon = isApproved
        ? Icons.check_circle_outline_rounded
        : isRejected
            ? Icons.cancel_outlined
            : Icons.pending_actions_rounded;

    final leaveDate = DateFormat('dd/MM/yyyy').format(DateTime.parse(req.leaveDate));
    final detail = [
      req.reason,
      if (req.reviewNote != null && req.reviewNote!.trim().isNotEmpty) 'Ghi chú: ${req.reviewNote}',
      if (req.attachmentUrl != null && req.attachmentUrl!.trim().isNotEmpty) 'Minh chứng: ${req.attachmentUrl}',
    ].join('\n');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 3)),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: badgeBgColor, shape: BoxShape.circle),
                child: Icon(statusIcon, color: badgeTextColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      req.studentName ?? 'Học sinh #${req.studentId}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
                    ),
                    const SizedBox(height: 2),
                    Text(leaveDate, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: badgeBgColor, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 13, color: badgeTextColor),
                    const SizedBox(width: 4),
                    Text(
                      req.statusLabelVi,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: badgeTextColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isRejected ? const Color(0xFFFFEBEE).withValues(alpha: 0.5) : const Color(0xFFF5F6F8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              detail,
              style: TextStyle(fontSize: 12.5, color: isRejected ? const Color(0xFFC62828) : Colors.grey.shade700, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Center(child: Text(message, style: TextStyle(color: Colors.grey.shade600))),
    );
  }
}

class CreateLeaveRequestPage extends StatefulWidget {
  final String? controllerTag;

  const CreateLeaveRequestPage({super.key, this.controllerTag});

  @override
  State<CreateLeaveRequestPage> createState() => _CreateLeaveRequestPageState();
}

class _CreateLeaveRequestPageState extends State<CreateLeaveRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _attachmentUrlController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  late final LeaveRequestController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<LeaveRequestController>(tag: widget.controllerTag);
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _attachmentUrlController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      locale: const Locale('vi', 'VN'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFE65100), onPrimary: Colors.white, onSurface: Colors.black87),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateString = DateFormat('dd/MM/yyyy').format(_selectedDate);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tạo đơn xin nghỉ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF212121))),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Điền thông tin đơn xin nghỉ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                const Text('Ngày nghỉ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _selectDate(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(dateString, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        const Icon(Icons.calendar_today_rounded, color: Color(0xFFE65100), size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Lý do', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _reasonController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Mô tả lý do xin nghỉ...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE65100), width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Vui lòng nhập lý do xin nghỉ' : null,
                ),
                const SizedBox(height: 20),
                const Text('Link minh chứng (tuỳ chọn)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _attachmentUrlController,
                  decoration: InputDecoration(
                    hintText: 'https://...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE65100), width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 36),
                Obx(
                  () => AppButton(
                    label: _ctrl.isSubmitting.value ? 'Đang gửi...' : 'Gửi đơn',
                    fullWidth: true,
                    borderRadius: 30,
                    onPressed: _ctrl.isSubmitting.value ? null : _submit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await _ctrl.submitRequest(
      leaveDate: _selectedDate,
      reason: _reasonController.text.trim(),
      attachmentUrl: _attachmentUrlController.text,
    );
    if (ok && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gửi đơn xin nghỉ thành công!'), backgroundColor: Color(0xFF2E7D32)),
      );
    }
  }
}

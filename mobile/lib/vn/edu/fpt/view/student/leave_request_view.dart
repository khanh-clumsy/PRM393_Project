import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/student_welcome_app_bar.dart';

class LeaveRequestData {
  final String title;
  final String date;
  final String status;
  final String details;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;

  const LeaveRequestData({
    required this.title,
    required this.date,
    required this.status,
    required this.details,
    required this.icon,
    this.iconBackground = const Color(0xFFF5F5F5),
    this.iconColor = Colors.grey,
  });
}

class LeaveRequestListPage extends StatefulWidget {
  const LeaveRequestListPage({super.key});

  @override
  State<LeaveRequestListPage> createState() => _LeaveRequestListPageState();
}

class _LeaveRequestListPageState extends State<LeaveRequestListPage> {
  final List<LeaveRequestData> _history = [
    const LeaveRequestData(
      title: 'Nghỉ ốm',
      date: '20/10/2023',
      status: 'Đã duyệt',
      details: 'Sốt cao và đau đầu. Bác sĩ khuyên nghỉ 2 ngày. Đã đính kèm giấy xác nhận y tế.',
      icon: Icons.vaccines_outlined,
      iconBackground: Color(0xFFE8F5E9),
      iconColor: Color(0xFF2E7D32),
    ),
    const LeaveRequestData(
      title: 'Nghỉ việc riêng',
      date: '25/10/2023',
      status: 'Chờ duyệt',
      details: 'Tham dự lễ cưới người thân ở tỉnh khác. Xin nghỉ 1 ngày.',
      icon: Icons.people_outline_rounded,
      iconBackground: Color(0xFFFFF3E0),
      iconColor: Color(0xFFE65100),
    ),
    const LeaveRequestData(
      title: 'Nghỉ phép',
      date: '02/11/2023',
      status: 'Từ chối',
      details: 'Dự định đi du lịch ngắn. Ghi chú: không duyệt vì trùng tuần thi giữa kỳ.',
      icon: Icons.flight_takeoff_outlined,
      iconBackground: Color(0xFFFFEBEE),
      iconColor: Color(0xFFC62828),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();

    return Obx(() {
      return Scaffold(
        backgroundColor: const Color(0xFFF9FAFC),
        appBar: StudentWelcomeAppBar(
          welcomeLine: userController.welcomeText,
          showNotificationBadge: false,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Đơn xin nghỉ',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Theo dõi và quản lý đơn xin nghỉ học của bạn.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final newRequest = await Navigator.push<LeaveRequestData>(
                        context,
                        MaterialPageRoute(builder: (_) => const CreateLeaveRequestPage()),
                      );
                      if (newRequest != null) {
                        setState(() => _history.insert(0, newRequest));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Gửi đơn xin nghỉ thành công!'),
                              backgroundColor: Color(0xFF2E7D32),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                    label: const Text(
                      'Tạo đơn mới',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE65100),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 2,
                      shadowColor: const Color(0xFFE65100).withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Lịch sử gần đây',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFE65100),
                        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      child: const Text('Xem tất cả'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _history.length,
                  itemBuilder: (context, index) => _buildHistoryItem(_history[index]),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHistoryItem(LeaveRequestData req) {
    final isRejected = req.status == 'Từ chối';
    final isApproved = req.status == 'Đã duyệt';

    Color badgeBgColor;
    Color badgeTextColor;
    IconData statusIcon;

    if (isApproved) {
      badgeBgColor = const Color(0xFFE8F5E9);
      badgeTextColor = const Color(0xFF2E7D32);
      statusIcon = Icons.check_circle_outline_rounded;
    } else if (isRejected) {
      badgeBgColor = const Color(0xFFFFEBEE);
      badgeTextColor = const Color(0xFFC62828);
      statusIcon = Icons.cancel_outlined;
    } else {
      badgeBgColor = const Color(0xFFFFF3E0);
      badgeTextColor = const Color(0xFFE65100);
      statusIcon = Icons.pending_actions_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
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
                decoration: BoxDecoration(color: req.iconBackground, shape: BoxShape.circle),
                child: Icon(req.icon, color: req.iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      req.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      req.date,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 13, color: badgeTextColor),
                    const SizedBox(width: 4),
                    Text(
                      req.status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: badgeTextColor,
                      ),
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
              color: isRejected
                  ? const Color(0xFFFFEBEE).withValues(alpha: 0.5)
                  : const Color(0xFFF5F6F8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              req.details,
              style: TextStyle(
                fontSize: 12.5,
                color: isRejected ? const Color(0xFFC62828) : Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CreateLeaveRequestPage extends StatefulWidget {
  const CreateLeaveRequestPage({super.key});

  @override
  State<CreateLeaveRequestPage> createState() => _CreateLeaveRequestPageState();
}

class _CreateLeaveRequestPageState extends State<CreateLeaveRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  String _selectedType = 'Nghỉ ốm';
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _reasonController.dispose();
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
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE65100),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
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
    final dateString =
        '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Tạo đơn xin nghỉ',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF212121)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF212121), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Điền thông tin đơn xin nghỉ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Loại nghỉ',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE65100), width: 1.5),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Nghỉ ốm', child: Text('Nghỉ ốm')),
                    DropdownMenuItem(value: 'Nghỉ việc riêng', child: Text('Nghỉ việc riêng')),
                    DropdownMenuItem(value: 'Nghỉ phép', child: Text('Nghỉ phép')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedType = val);
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Ngày nghỉ',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _selectDate(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dateString,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                        ),
                        const Icon(Icons.calendar_today_rounded, color: Color(0xFFE65100), size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Lý do',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _reasonController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Mô tả lý do xin nghỉ (ví dụ: ốm, việc gia đình)...',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE65100), width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Vui lòng nhập lý do xin nghỉ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 36),
                AppButton(
                  label: 'Gửi đơn',
                  fullWidth: true,
                  borderRadius: 30,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      IconData icon;
                      Color iconBg;
                      Color iconColor;

                      if (_selectedType == 'Nghỉ ốm') {
                        icon = Icons.vaccines_outlined;
                        iconBg = const Color(0xFFE8F5E9);
                        iconColor = const Color(0xFF2E7D32);
                      } else if (_selectedType == 'Nghỉ phép') {
                        icon = Icons.flight_takeoff_outlined;
                        iconBg = const Color(0xFFFFEBEE);
                        iconColor = const Color(0xFFC62828);
                      } else {
                        icon = Icons.people_outline_rounded;
                        iconBg = const Color(0xFFFFF3E0);
                        iconColor = const Color(0xFFE65100);
                      }

                      Navigator.pop(
                        context,
                        LeaveRequestData(
                          title: _selectedType,
                          date: dateString,
                          status: 'Chờ duyệt',
                          details: _reasonController.text.trim(),
                          icon: icon,
                          iconBackground: iconBg,
                          iconColor: iconColor,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

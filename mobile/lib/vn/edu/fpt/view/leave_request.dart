import 'package:flutter/material.dart';
import 'package:prm393_mobile/vn/edu/fpt/view/notifications.dart';

class LeaveRequestData {
  final String title;
  final String date;
  final String status; // 'Approved', 'Pending', 'Rejected'
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
  // Lịch sử yêu cầu nghỉ phép ban đầu
  final List<LeaveRequestData> _history = [
    const LeaveRequestData(
      title: 'Sickness Leave',
      date: '20 Oct 2023',
      status: 'Approved',
      details: 'High fever and headache. Doctor recommended 2 days of rest. Medical certificate attached.',
      icon: Icons.vaccines_outlined,
      iconBackground: Color(0xFFE8F5E9),
      iconColor: Color(0xFF2E7D32),
    ),
    const LeaveRequestData(
      title: 'Personal Leave',
      date: '25 Oct 2023',
      status: 'Pending',
      details: 'Attending a family wedding in another city. Need one day off.',
      icon: Icons.people_outline_rounded,
      iconBackground: Color(0xFFFFF3E0),
      iconColor: Color(0xFFE65100),
    ),
    const LeaveRequestData(
      title: 'Vacation',
      date: '02 Nov 2023',
      status: 'Rejected',
      details: 'Planned a short trip. Note: Rejected due to clashing with midterm exams.',
      icon: Icons.flight_takeoff_outlined,
      iconBackground: Color(0xFFFFEBEE),
      iconColor: Color(0xFFC62828),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFCC80), width: 1.5),
              ),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFFFE0B2),
                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&auto=format&fit=crop'),
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'FSchool',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE65100),
                  ),
                ),
                Text(
                  'Welcome, Alex Johnson',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
              );
            },
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF424242),
              size: 26,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề trang
              const Text(
                '[Student] Leave Requests',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Manage and track your absence forms.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),

              // Nút tạo yêu cầu mới to nổi bật
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // Mở trang tạo yêu cầu và lấy dữ liệu trả về
                    final newRequest = await Navigator.push<LeaveRequestData>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateLeaveRequestPage(),
                      ),
                    );

                    if (newRequest != null) {
                      setState(() {
                        // Thêm vào đầu lịch sử
                        _history.insert(0, newRequest);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Leave request submitted successfully!'),
                          backgroundColor: Color(0xFF2E7D32),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                  label: const Text(
                    'Create New Request',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE65100),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 2,
                    shadowColor: const Color(0xFFE65100).withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Tiêu đề danh sách lịch sử
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent History',
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
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Danh sách lịch sử
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  final req = _history[index];
                  final isRejected = req.status == 'Rejected';
                  final isApproved = req.status == 'Approved';

                  // Chọn màu tương ứng cho Badge Trạng thái
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
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dòng 1: Icon, Tiêu đề và Badge trạng thái
                        Row(
                          children: [
                            // Icon tròn bên trái
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: req.iconBackground,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                req.icon,
                                color: req.iconColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Tiêu đề & Ngày
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
                            // Badge trạng thái
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
                        // Hộp chi tiết lý do (Màu đỏ nhạt nếu bị từ chối, màu xám nhạt nếu được duyệt/đang chờ)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isRejected ? const Color(0xFFFFEBEE).withOpacity(0.5) : const Color(0xFFF5F6F8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            req.details,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isRejected ? const Color(0xFFC62828) : Colors.grey.shade700,
                              height: 1.4,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Màn hình nhập Form Yêu cầu mới
class CreateLeaveRequestPage extends StatefulWidget {
  const CreateLeaveRequestPage({super.key});

  @override
  State<CreateLeaveRequestPage> createState() => _CreateLeaveRequestPageState();
}

class _CreateLeaveRequestPageState extends State<CreateLeaveRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  String _selectedType = 'Sickness Leave';
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  // Hàm hiển thị DatePicker để chọn ngày xin nghỉ
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
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
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Định nghĩa định dạng ngày đơn giản
    final dateString = '${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'New Leave Request',
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
                  'Fill in your request details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
                ),
                const SizedBox(height: 24),

                // 1. Loại xin nghỉ (Dropdown)
                const Text(
                  'Leave Type',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE65100), width: 1.5),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Sickness Leave', child: Text('Sickness Leave 🤒')),
                    DropdownMenuItem(value: 'Personal Leave', child: Text('Personal Leave 💼')),
                    DropdownMenuItem(value: 'Vacation', child: Text('Vacation ✈️')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedType = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),

                // 2. Chọn ngày nghỉ
                const Text(
                  'Date of Absence',
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

                // 3. Lý do xin nghỉ (TextField)
                const Text(
                  'Reason for Absence',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _reasonController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Describe your reason here (e.g. sickness, family trip)...',
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
                      return 'Please provide a reason for leave';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 36),

                // Nút gửi yêu cầu
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Xác định icon và màu theo loại xin nghỉ
                        IconData icon;
                        Color iconBg;
                        Color iconColor;

                        if (_selectedType == 'Sickness Leave') {
                          icon = Icons.vaccines_outlined;
                          iconBg = const Color(0xFFE8F5E9);
                          iconColor = const Color(0xFF2E7D32);
                        } else if (_selectedType == 'Vacation') {
                          icon = Icons.flight_takeoff_outlined;
                          iconBg = const Color(0xFFFFEBEE);
                          iconColor = const Color(0xFFC62828);
                        } else {
                          icon = Icons.people_outline_rounded;
                          iconBg = const Color(0xFFFFF3E0);
                          iconColor = const Color(0xFFE65100);
                        }

                        // Tạo đối tượng dữ liệu nghỉ phép mới (trạng thái mặc định là Pending)
                        final newRequest = LeaveRequestData(
                          title: _selectedType,
                          date: dateString,
                          status: 'Pending',
                          details: _reasonController.text.trim(),
                          icon: icon,
                          iconBackground: iconBg,
                          iconColor: iconColor,
                        );

                        // Trả về trang trước kèm đối tượng mới tạo
                        Navigator.pop(context, newRequest);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE65100),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Submit Request',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Trợ giúp lấy tên tháng tiếng Anh
  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

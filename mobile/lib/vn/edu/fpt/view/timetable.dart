import 'package:flutter/material.dart';
import 'package:prm393_mobile/vn/edu/fpt/view/notifications.dart';

class ClassScheduleData {
  final String subjectName;
  final String teacherName;
  final String timeString;
  final String room;
  final bool isOngoing;
  final double elapsedProgress; // 0.0 to 1.0
  final String timeLabel;
  final String timeSub; // AM or PM

  const ClassScheduleData({
    required this.subjectName,
    required this.teacherName,
    required this.timeString,
    required this.room,
    this.isOngoing = false,
    this.elapsedProgress = 0.0,
    required this.timeLabel,
    required this.timeSub,
  });
}

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  int _selectedDayIndex = 2; // Mặc định chọn Thứ 4 (ngày 16)

  // Danh sách các ngày hiển thị trên lịch tuần
  final List<Map<String, dynamic>> _weekDays = [
    {'weekday': 'MON', 'day': '14', 'date': '2023-10-14'},
    {'weekday': 'TUE', 'day': '15', 'date': '2023-10-15'},
    {'weekday': 'WED', 'day': '16', 'date': '2023-10-16'},
    {'weekday': 'THU', 'day': '17', 'date': '2023-10-17'},
    {'weekday': 'FRI', 'day': '18', 'date': '2023-10-18'},
  ];

  // Lịch học mẫu cho ngày Thứ 4 (WED 16) - Giống hệt hình vẽ
  final List<ClassScheduleData> _wednesdayClasses = [
    const ClassScheduleData(
      subjectName: 'Mathematics',
      teacherName: 'Mr. Smith',
      timeString: '08:00 - 09:30',
      room: '402',
      timeLabel: '08:00',
      timeSub: 'AM',
    ),
    const ClassScheduleData(
      subjectName: 'Physics',
      teacherName: 'Dr. Adams',
      timeString: '09:45 - 11:15 • Ongoing',
      room: 'Lab 3',
      isOngoing: true,
      elapsedProgress: 0.45, // Thanh tiến trình chạy được 45%
      timeLabel: '09:45',
      timeSub: 'AM',
    ),
    const ClassScheduleData(
      subjectName: 'Literature',
      teacherName: 'Ms. Johnson',
      timeString: '11:30 - 13:00',
      room: '105',
      timeLabel: '11:30',
      timeSub: 'AM',
    ),
    const ClassScheduleData(
      subjectName: 'Computer Science',
      teacherName: 'Mr. Davis',
      timeString: '02:00 - 03:30',
      room: 'Comp Lab',
      timeLabel: '02:00',
      timeSub: 'PM',
    ),
  ];

  // Lịch học mẫu cho các ngày khác để demo chuyển ngày
  final List<ClassScheduleData> _otherDaysClasses = [
    const ClassScheduleData(
      subjectName: 'English',
      teacherName: 'Ms. Lee',
      timeString: '08:00 - 09:30',
      room: '102',
      timeLabel: '08:00',
      timeSub: 'AM',
    ),
    const ClassScheduleData(
      subjectName: 'Chemistry',
      teacherName: 'Dr. Adams',
      timeString: '09:45 - 11:15',
      room: 'Lab 1',
      timeLabel: '09:45',
      timeSub: 'AM',
    ),
    const ClassScheduleData(
      subjectName: 'Mathematics',
      teacherName: 'Mr. Smith',
      timeString: '11:30 - 13:00',
      room: '402',
      timeLabel: '11:30',
      timeSub: 'AM',
    ),
    const ClassScheduleData(
      subjectName: 'Geography',
      teacherName: 'Mrs. Green',
      timeString: '02:00 - 03:30',
      room: '204',
      timeLabel: '02:00',
      timeSub: 'PM',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Lấy danh sách môn học của ngày được chọn
    final dayClasses = _selectedDayIndex == 2 ? _wednesdayClasses : _otherDaysClasses;

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
                MaterialPageRoute(
                  builder: (context) => const NotificationsPage(),
                ),
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
              // Tiêu đề Timetable
              const Text(
                'Timetable',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Week 42, Semester 1',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),

              // Header tháng & nút điều hướng ngày
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'October 2023',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          if (_selectedDayIndex > 0) {
                            setState(() => _selectedDayIndex--);
                          }
                        },
                        icon: const Icon(Icons.chevron_left_rounded, size: 20),
                        color: Colors.grey.shade700,
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          if (_selectedDayIndex < _weekDays.length - 1) {
                            setState(() => _selectedDayIndex++);
                          }
                        },
                        icon: const Icon(Icons.chevron_right_rounded, size: 20),
                        color: Colors.grey.shade700,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Hàng lịch ngang chứa các ngày trong tuần
              SizedBox(
                height: 72,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _weekDays.length + 1, // +1 cho nút quay lại ở đầu hàng
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Nút lùi tuần/quay lại ở đầu hàng
                      return Container(
                        width: 48,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: IconButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Previous week selected')),
                            );
                          },
                          icon: const Icon(Icons.chevron_left_rounded, color: Colors.black54),
                        ),
                      );
                    }

                    final dayIndex = index - 1;
                    final dayData = _weekDays[dayIndex];
                    final isSelected = dayIndex == _selectedDayIndex;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDayIndex = dayIndex;
                        });
                      },
                      child: Container(
                        width: 54,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFE65100) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.transparent : Colors.grey.shade100,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFE65100).withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              dayData['weekday'],
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white.withOpacity(0.8) : Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              dayData['day'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : const Color(0xFF212121),
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(height: 4),
                              Container(
                                width: 3,
                                height: 3,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Danh sách Timeline và Thẻ lịch học
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dayClasses.length,
                itemBuilder: (context, index) {
                  final cls = dayClasses[index];

                  // Hiển thị phần nghỉ trưa giữa các ca học thứ 3 và thứ 4
                  final showLunchBreak = index == 3;

                  return Column(
                    children: [
                      if (showLunchBreak) ...[
                        // Component Dải phân cách Lunch Break
                        Padding(
                          padding: const EdgeInsets.only(left: 60, top: 8, bottom: 20),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Divider(
                                  color: Color(0xFFE0E0E0),
                                  thickness: 1,
                                  indent: 0,
                                  endIndent: 10,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.restaurant_rounded,
                                      size: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Lunch Break',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Expanded(
                                child: Divider(
                                  color: Color(0xFFE0E0E0),
                                  thickness: 1,
                                  indent: 10,
                                  endIndent: 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. Trục thời gian (Thời gian bên trái)
                            SizedBox(
                              width: 60,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cls.timeLabel,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: cls.isOngoing ? const Color(0xFFE65100) : const Color(0xFF212121),
                                    ),
                                  ),
                                  Text(
                                    cls.timeSub,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: cls.isOngoing ? const Color(0xFFE65100) : Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // 2. Trục đứng timeline nối tiếp
                            Column(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: cls.isOngoing ? const Color(0xFFE65100) : Colors.grey.shade300,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    width: 1.5,
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 14),

                            // 3. Card thông tin môn học cụ thể
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: cls.isOngoing
                                        ? const Color(0xFFE65100) // Đổi viền cam nếu đang học
                                        : Colors.grey.shade100,
                                    width: cls.isOngoing ? 1.5 : 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Dòng 1: Tên môn & Phòng học
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              cls.subjectName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF212121),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // Badge phòng học
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: cls.isOngoing
                                                  ? const Color(0xFFFFE0B2)
                                                  : Colors.grey.shade100,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              cls.room,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: cls.isOngoing
                                                    ? const Color(0xFFE65100)
                                                    : Colors.grey.shade600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // Dòng 2: Tên Giáo viên
                                      Row(
                                        children: [
                                          Icon(Icons.person_outline_rounded, size: 14, color: Colors.grey.shade600),
                                          const SizedBox(width: 6),
                                          Text(
                                            cls.teacherName,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),

                                      // Dòng 3: Thời gian ca học
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time_rounded,
                                            size: 14,
                                            color: cls.isOngoing ? const Color(0xFFE65100) : Colors.grey.shade500,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            cls.timeString,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: cls.isOngoing ? const Color(0xFFE65100) : Colors.grey.shade600,
                                              fontWeight: cls.isOngoing ? FontWeight.bold : FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Nếu là ca học đang diễn ra, vẽ thanh tiến trình thời gian ở dưới cùng
                                      if (cls.isOngoing) ...[
                                        const SizedBox(height: 14),
                                        Stack(
                                          children: [
                                            Container(
                                              height: 4,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade200,
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                            ),
                                            FractionallySizedBox(
                                              widthFactor: cls.elapsedProgress,
                                              child: Container(
                                                height: 4,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFE65100),
                                                  borderRadius: BorderRadius.circular(2),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

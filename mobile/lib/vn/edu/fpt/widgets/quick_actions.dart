import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../view/shared/attendance_view.dart';
import '../view/shared/timetable_view.dart';
import 'package:prm393_mobile/vn/edu/fpt/view/student/leave_request_view.dart';
import '../view/student/student_grade_view.dart';

class QuickActionItemData {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  const QuickActionItemData({
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor = const Color(0xFFE65100),
    this.iconColor = Colors.white,
  });
}

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final List<QuickActionItemData> actions = [
      QuickActionItemData(
        icon: Icons.fact_check_outlined,
        label: 'Điểm danh',
        onTap: () => Get.to(() => const AttendanceView()),
      ),
      QuickActionItemData(
        icon: Icons.bar_chart_rounded,
        label: 'Điểm số',
        onTap: () => Get.to(() => const StudentGradeView()),
      ),
      QuickActionItemData(
        icon: Icons.calendar_month_outlined,
        label: 'Thời khóa biểu',
        onTap: () => Get.to(() => const TimetablePage()),
      ),
      QuickActionItemData(
        icon: Icons.flight_takeoff_outlined,
        label: 'Đơn xin nghỉ',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LeaveRequestListPage()),
          );
        },
      ),
      QuickActionItemData(
        icon: Icons.more_horiz_rounded,
        label: 'Thêm',
        backgroundColor: Colors.grey.shade200,
        iconColor: Colors.grey.shade700,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tính năng đang phát triển')),
          );
        },
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thao tác nhanh',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.95,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            return QuickActionWidget(item: actions[index]);
          },
        ),
      ],
    );
  }
}

class QuickActionWidget extends StatefulWidget {
  final QuickActionItemData item;

  const QuickActionWidget({super.key, required this.item});

  @override
  State<QuickActionWidget> createState() => _QuickActionWidgetState();
}

class _QuickActionWidgetState extends State<QuickActionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) {
        _animationController.reverse();
        widget.item.onTap();
      },
      onTapCancel: () => _animationController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: widget.item.backgroundColor,
                shape: BoxShape.circle,
                boxShadow: widget.item.backgroundColor == const Color(0xFFE65100)
                    ? [
                        BoxShadow(
                          color: const Color(0xFFE65100).withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : null,
              ),
              child: Center(
                child: Icon(
                  widget.item.icon,
                  color: widget.item.iconColor,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.item.label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF424242),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

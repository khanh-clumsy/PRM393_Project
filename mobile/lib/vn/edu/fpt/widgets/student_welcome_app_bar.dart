import 'package:flutter/material.dart';
import '../view/student/notifications_view.dart';

/// AppBar chung cho màn học sinh: không avatar ảnh mặc định, hiển thị tên thật.
class StudentWelcomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String welcomeLine;
  final bool showNotificationBadge;

  const StudentWelcomeAppBar({
    super.key,
    required this.welcomeLine,
    this.showNotificationBadge = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: StudentWelcomeTitle(welcomeLine: welcomeLine),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsPage()),
            );
          },
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF424242),
                size: 26,
              ),
              if (showNotificationBadge)
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class StudentWelcomeTitle extends StatelessWidget {
  final String welcomeLine;

  const StudentWelcomeTitle({super.key, required this.welcomeLine});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'FSchool',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE65100),
          ),
        ),
        Text(
          welcomeLine,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black54,
            fontWeight: FontWeight.w400,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

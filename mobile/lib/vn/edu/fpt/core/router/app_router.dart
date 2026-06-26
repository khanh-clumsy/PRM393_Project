import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../view/auth/login_view.dart';
import '../../view/student/student_main_view.dart';
import '../../view/teacher/teacher_main_view.dart';
import '../../view/admin/admin_main_view.dart';
import '../../view/admin/department_management_view.dart';
import '../../view/admin/academic_year_management_view.dart';
import '../../view/admin/semester_management_view.dart';
import '../../view/admin/subject_management_view.dart';
import '../../view/admin/timetable_slot_management_view.dart';
import '../../view/admin/user_management_view.dart';
import '../../view/admin/class_management_view.dart';
import '../../view/admin/academic_rank_management_view.dart';
import '../../view/admin/announcement_management_view.dart';

// Placeholder screens cho các role chưa có UI
import 'package:flutter/material.dart';

class AppPages {
  static final routes = [
    GetPage(name: '/login', page: () => const LoginPage()),
    GetPage(name: '/student', page: () => const StudentMainView()),
    GetPage(
      name: '/teacher',
      page: () => const TeacherMainView(),
    ),
    GetPage(
      name: '/admin',
      page: () => const AdminMainView(),
    ),
    GetPage(
      name: '/admin/departments',
      page: () => const DepartmentManagementView(),
    ),
    GetPage(
      name: '/admin/academic-years',
      page: () => const AcademicYearManagementView(),
    ),
    GetPage(
      name: '/admin/semesters',
      page: () => const SemesterManagementView(),
    ),
    GetPage(
      name: '/admin/subjects',
      page: () => const SubjectManagementView(),
    ),
    GetPage(
      name: '/admin/slots',
      page: () => const TimetableSlotManagementView(),
    ),
    GetPage(
      name: '/admin/users',
      page: () => const UserManagementView(),
    ),
    GetPage(
      name: '/admin/classes',
      page: () => const ClassManagementView(),
    ),
    GetPage(
      name: '/admin/ranks',
      page: () => const AcademicRankManagementView(),
    ),
    GetPage(
      name: '/admin/announcements',
      page: () => const AnnouncementManagementView(),
    ),
    GetPage(
      name: '/head',
      page: () => const _PlaceholderScreen(title: 'Trưởng bộ môn'),
    ),
    GetPage(
      name: '/parent',
      page: () => const _PlaceholderScreen(title: 'Phụ huynh'),
    ),
  ];
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFFE65100),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Get.find<AuthController>().logout(),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Màn hình $title\n(Đang phát triển)',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
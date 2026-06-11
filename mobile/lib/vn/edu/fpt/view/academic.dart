import 'package:flutter/material.dart';
import 'package:myfschoolse1913/vn/edu/fpt/view/notifications.dart';

class SubjectGradeData {
  final String subjectName;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final double overallScore;
  final List<double> scores15m;
  final double midtermScore;
  final double finalScore;

  const SubjectGradeData({
    required this.subjectName,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.overallScore,
    required this.scores15m,
    required this.midtermScore,
    required this.finalScore,
  });
}

class AcademicPage extends StatefulWidget {
  const AcademicPage({super.key});

  @override
  State<AcademicPage> createState() => _AcademicPageState();
}

class _AcademicPageState extends State<AcademicPage> {
  int _subTab = 0; // 0: Grades, 1: Assignments
  int _selectedSemester = 1; // 1: Semester 1, 2: Semester 2
  int _assignmentTab = 0; // 0: To-Do, 1: Submitted, 2: Overdue

  // Dữ liệu mẫu các môn học cho Học kỳ 1
  final List<SubjectGradeData> _semester1Subjects = [
    const SubjectGradeData(
      subjectName: 'Mathematics',
      icon: Icons.calculate_outlined,
      iconBackground: Color(0xFFFFF3E0),
      iconColor: Color(0xFFE65100),
      overallScore: 9.2,
      scores15m: [9.5, 9.0],
      midtermScore: 9.0,
      finalScore: 9.5,
    ),
    const SubjectGradeData(
      subjectName: 'Physics',
      icon: Icons.science_outlined,
      iconBackground: Color(0xFFE0F2F1),
      iconColor: Color(0xFF00796B),
      overallScore: 8.5,
      scores15m: [8.0, 8.5],
      midtermScore: 9.0,
      finalScore: 8.5,
    ),
    const SubjectGradeData(
      subjectName: 'English',
      icon: Icons.translate_rounded,
      iconBackground: Color(0xFFFFEBEE),
      iconColor: Color(0xFFC62828),
      overallScore: 4.5,
      scores15m: [5.0, 4.0],
      midtermScore: 4.5,
      finalScore: 4.5,
    ),
    const SubjectGradeData(
      subjectName: 'Literature',
      icon: Icons.menu_book_rounded,
      iconBackground: Color(0xFFE8EAF6),
      iconColor: Color(0xFF3F51B5),
      overallScore: 7.8,
      scores15m: [8.0, 7.5],
      midtermScore: 7.0,
      finalScore: 8.5,
    ),
    const SubjectGradeData(
      subjectName: 'Chemistry',
      icon: Icons.biotech_outlined,
      iconBackground: Color(0xFFF3E5F5),
      iconColor: Color(0xFF8E24AA),
      overallScore: 8.2,
      scores15m: [8.0, 8.5],
      midtermScore: 8.0,
      finalScore: 8.5,
    ),
    const SubjectGradeData(
      subjectName: 'Biology',
      icon: Icons.grass_outlined,
      iconBackground: Color(0xFFE8F5E9),
      iconColor: Color(0xFF2E7D32),
      overallScore: 8.9,
      scores15m: [9.0, 8.5],
      midtermScore: 9.0,
      finalScore: 9.0,
    ),
    const SubjectGradeData(
      subjectName: 'History',
      icon: Icons.history_edu_outlined,
      iconBackground: Color(0xFFEFEBE9),
      iconColor: Color(0xFF5D4037),
      overallScore: 7.5,
      scores15m: [7.0, 8.0],
      midtermScore: 7.5,
      finalScore: 7.5,
    ),
    const SubjectGradeData(
      subjectName: 'Geography',
      icon: Icons.public_outlined,
      iconBackground: Color(0xFFE1F5FE),
      iconColor: Color(0xFF0288D1),
      overallScore: 8.0,
      scores15m: [8.0, 8.0],
      midtermScore: 8.0,
      finalScore: 8.0,
    ),
  ];

  // Dữ liệu mẫu các môn học cho Học kỳ 2
  final List<SubjectGradeData> _semester2Subjects = [
    const SubjectGradeData(
      subjectName: 'Mathematics',
      icon: Icons.calculate_outlined,
      iconBackground: Color(0xFFFFF3E0),
      iconColor: Color(0xFFE65100),
      overallScore: 9.5,
      scores15m: [9.5, 9.5],
      midtermScore: 9.5,
      finalScore: 9.5,
    ),
    const SubjectGradeData(
      subjectName: 'Physics',
      icon: Icons.science_outlined,
      iconBackground: Color(0xFFE0F2F1),
      iconColor: Color(0xFF00796B),
      overallScore: 8.8,
      scores15m: [8.5, 9.0],
      midtermScore: 8.5,
      finalScore: 9.0,
    ),
    const SubjectGradeData(
      subjectName: 'English',
      icon: Icons.translate_rounded,
      iconBackground: Color(0xFFFFEBEE),
      iconColor: Color(0xFFC62828),
      overallScore: 6.2,
      scores15m: [6.0, 6.5],
      midtermScore: 6.0,
      finalScore: 6.5,
    ),
    const SubjectGradeData(
      subjectName: 'Literature',
      icon: Icons.menu_book_rounded,
      iconBackground: Color(0xFFE8EAF6),
      iconColor: Color(0xFF3F51B5),
      overallScore: 8.0,
      scores15m: [8.0, 8.0],
      midtermScore: 8.0,
      finalScore: 8.0,
    ),
    const SubjectGradeData(
      subjectName: 'Chemistry',
      icon: Icons.biotech_outlined,
      iconBackground: Color(0xFFF3E5F5),
      iconColor: Color(0xFF8E24AA),
      overallScore: 8.5,
      scores15m: [8.5, 8.5],
      midtermScore: 8.5,
      finalScore: 8.5,
    ),
    const SubjectGradeData(
      subjectName: 'Biology',
      icon: Icons.grass_outlined,
      iconBackground: Color(0xFFE8F5E9),
      iconColor: Color(0xFF2E7D32),
      overallScore: 9.1,
      scores15m: [9.0, 9.0],
      midtermScore: 9.0,
      finalScore: 9.5,
    ),
    const SubjectGradeData(
      subjectName: 'History',
      icon: Icons.history_edu_outlined,
      iconBackground: Color(0xFFEFEBE9),
      iconColor: Color(0xFF5D4037),
      overallScore: 7.8,
      scores15m: [8.0, 7.5],
      midtermScore: 7.5,
      finalScore: 8.0,
    ),
    const SubjectGradeData(
      subjectName: 'Geography',
      icon: Icons.public_outlined,
      iconBackground: Color(0xFFE1F5FE),
      iconColor: Color(0xFF0288D1),
      overallScore: 8.2,
      scores15m: [8.0, 8.5],
      midtermScore: 8.0,
      finalScore: 8.5,
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
        child: Column(
          children: [
            // Segmented Tab Switcher: Grades vs Assignments ở đầu màn hình
            Container(
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _subTab = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _subTab == 0 ? const Color(0xFFE65100) : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Grades',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: _subTab == 0 ? FontWeight.bold : FontWeight.w500,
                              color: _subTab == 0 ? const Color(0xFFE65100) : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _subTab = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _subTab == 1 ? const Color(0xFFE65100) : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Assignments',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: _subTab == 1 ? FontWeight.bold : FontWeight.w500,
                              color: _subTab == 1 ? const Color(0xFFE65100) : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Nội dung thay đổi theo Tab
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: _subTab == 0 ? _buildGradesTab() : _buildAssignmentsTab(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 1. Layout hiển thị Tab Grades (Giao diện cũ)
  Widget _buildGradesTab() {
    final activeSubjects = _selectedSemester == 1 ? _semester1Subjects : _semester2Subjects;
    final double gpaSum = activeSubjects.fold(0.0, (sum, sub) => sum + sub.overallScore);
    final double averageScore = activeSubjects.isNotEmpty ? (gpaSum / activeSubjects.length) : 0.0;
    final double cumulativeGpa = double.parse((averageScore * 4 / 10).toStringAsFixed(2));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Academic Records',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 16),

        // Capsule Semester Selector
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F3),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedSemester = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _selectedSemester == 1 ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: _selectedSemester == 1
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        'Semester 1',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: _selectedSemester == 1 ? FontWeight.bold : FontWeight.w500,
                          color: _selectedSemester == 1 ? const Color(0xFFE65100) : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedSemester = 2),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _selectedSemester == 2 ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: _selectedSemester == 2
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        'Semester 2',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: _selectedSemester == 2 ? FontWeight.bold : FontWeight.w500,
                          color: _selectedSemester == 2 ? const Color(0xFFE65100) : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // GPA & Conduct Summary Card
        Stack(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cumulative GPA',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$cumulativeGpa',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD84315),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '/ 4.0',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Conduct Rating',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: Color(0xFF2E7D32),
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Excellent',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0).withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // Title Subject Grades
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Subject Grades',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            Text(
              '${activeSubjects.length} Subjects',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // List of Subject Cards
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activeSubjects.length,
          itemBuilder: (context, index) {
            final subject = activeSubjects[index];
            final isBelowAverage = subject.overallScore < 5.0;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubjectGradeDetailPage(subject: subject),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
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
                border: Border.all(
                  color: isBelowAverage ? const Color(0xFFFFCDD2) : Colors.grey.shade100,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    border: isBelowAverage
                        ? const Border(
                            left: BorderSide(
                              color: Color(0xFFD32F2F),
                              width: 4,
                            ),
                          )
                        : null,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: subject.iconBackground,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              subject.icon,
                              color: subject.iconColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              subject.subjectName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF212121),
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Overall',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${subject.overallScore}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isBelowAverage
                                      ? const Color(0xFFD32F2F)
                                      : (subject.overallScore >= 8.0
                                          ? const Color(0xFF2E7D32)
                                          : const Color(0xFF212121)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '15 Min',
                                  style: TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  subject.scores15m.join(', '),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isBelowAverage ? const Color(0xFFE57373) : const Color(0xFF424242),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Midterm',
                                  style: TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${subject.midtermScore}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: subject.midtermScore < 5.0 ? const Color(0xFFD32F2F) : const Color(0xFF424242),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Final',
                                  style: TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${subject.finalScore}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: subject.finalScore < 5.0 ? const Color(0xFFD32F2F) : const Color(0xFF424242),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      ],
    );
  }

  // 2. Layout hiển thị Tab Assignments (Giao diện mới theo hình vẽ)
  Widget _buildAssignmentsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tiêu đề Assignments & mô tả phụ
        const Text(
          'Assignments',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Manage and track your coursework',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 18),

        // Capsule Sub-selector: To-Do vs Submitted vs Overdue
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildAssignmentSubTabButton(0, 'To-Do'),
              ),
              Expanded(
                child: _buildAssignmentSubTabButton(1, 'Submitted'),
              ),
              Expanded(
                child: _buildAssignmentSubTabButton(2, 'Overdue'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Thẻ tiến trình tuần: Weekly Progress
        Container(
          width: double.infinity,
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
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Weekly Progress',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  Text(
                    '60%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE65100),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Thanh tiến trình
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: const LinearProgressIndicator(
                  value: 0.6,
                  backgroundColor: Color(0xFFECEFF1),
                  color: Color(0xFFE65100),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '3/5 assignments completed this week',
                style: TextStyle(
                  fontSize: 11.5,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Danh sách bài tập
        if (_assignmentTab == 0) ...[
          // Bài tập 1: Software Engineering (còn 2 ngày)
          _buildAssignmentCard(
            subject: 'SOFTWARE ENGINEERING',
            dueText: 'Due in 2 days',
            dueColor: const Color(0xFFE65100),
            dueIcon: Icons.access_time_rounded,
            title: 'Design Architecture Document',
            description: 'PDF format required',
            descIcon: Icons.insert_drive_file_outlined,
            isUrgent: false,
          ),
          // Bài tập 2: Mathematics (còn 5 giờ - Cảnh báo khẩn cấp!)
          _buildAssignmentCard(
            subject: 'MATHEMATICS',
            dueText: 'Due in 5 hours',
            dueColor: const Color(0xFFD32F2F),
            dueIcon: Icons.warning_amber_rounded,
            title: 'Calculus Homework 4',
            description: 'Chapters 5 & 6',
            descIcon: Icons.grid_on_outlined,
            isUrgent: true,
          ),
          // Bài tập 3: English (còn ngày mai)
          _buildAssignmentCard(
            subject: 'ENGLISH',
            dueText: 'Due tomorrow',
            dueColor: const Color(0xFFE65100),
            dueIcon: Icons.access_time_rounded,
            title: 'Essay: Future of AI',
            description: '1500 words minimum',
            descIcon: Icons.description_outlined,
            isUrgent: false,
          ),
        ] else
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(Icons.folder_open_outlined, size: 54, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text(
                    'No assignments in this tab',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // Nút chuyển đổi Tab bài tập con
  Widget _buildAssignmentSubTabButton(int index, String label) {
    final isSelected = _assignmentTab == index;
    return GestureDetector(
      onTap: () => setState(() => _assignmentTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? const Color(0xFF212121) : Colors.grey.shade500,
            ),
          ),
        ),
      ),
    );
  }

  // Widget xây dựng thẻ thông tin bài tập chi tiết
  Widget _buildAssignmentCard({
    required String subject,
    required String dueText,
    required Color dueColor,
    required IconData dueIcon,
    required String title,
    required String description,
    required IconData descIcon,
    required bool isUrgent,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        border: Border.all(
          color: isUrgent ? const Color(0xFFFFCDD2) : Colors.grey.shade100,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isUrgent ? const Color(0xFFD32F2F) : const Color(0xFFE65100),
                width: 4,
              ),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dòng 1: Tên môn (Badge) & Thời gian nộp
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      subject,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(dueIcon, size: 13, color: dueColor),
                      const SizedBox(width: 4),
                      Text(
                        dueText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: dueColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Dòng 2: Tiêu đề Bài tập
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 8),

              // Dòng 3: Yêu cầu định dạng tệp nộp
              Row(
                children: [
                  Icon(descIcon, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Nút Submit Work to đùng màu cam
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Submitting work for "$title"...'),
                        backgroundColor: const Color(0xFFE65100),
                      ),
                    );
                  },
                  icon: const Icon(Icons.upload_file_rounded, size: 16),
                  label: const Text(
                    'Submit Work',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE65100),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SubjectGradeDetailPage extends StatelessWidget {
  final SubjectGradeData subject;

  const SubjectGradeDetailPage({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    // Determine dynamic assessment performance text and badge color
    String performanceText;
    Color performanceBg;
    Color performanceTextColor;
    IconData performanceIcon;

    if (subject.overallScore >= 8.0) {
      performanceText = 'Excellent Performance';
      performanceBg = const Color(0xFFE8F5E9);
      performanceTextColor = const Color(0xFF2E7D32);
      performanceIcon = Icons.trending_up_rounded;
    } else if (subject.overallScore >= 5.0) {
      performanceText = 'Good Progress';
      performanceBg = const Color(0xFFFFF3E0);
      performanceTextColor = const Color(0xFFE65100);
      performanceIcon = Icons.trending_flat_rounded;
    } else {
      performanceText = 'Needs Improvement';
      performanceBg = const Color(0xFFFFEBEE);
      performanceTextColor = const Color(0xFFC62828);
      performanceIcon = Icons.trending_down_rounded;
    }

    // Dynamic grade component values based on the subject's scores
    final double attendanceScore = 10.0;
    final double quizScore = subject.scores15m.isNotEmpty ? subject.scores15m.first : 9.0;
    final double assignmentScore = subject.midtermScore;
    final double practicalScore = subject.finalScore;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: Text(
          subject.subjectName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF212121)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF212121), size: 20),
          onPressed: () => Navigator.pop(context),
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Current Standing Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  children: [
                    Text(
                      'CURRENT STANDING',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Circular Progress chart
                    SizedBox(
                      width: 130,
                      height: 130,
                      child: Stack(
                        children: [
                          Center(
                            child: SizedBox(
                              width: 120,
                              height: 120,
                              child: CircularProgressIndicator(
                                value: 1.0,
                                strokeWidth: 12,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade100),
                              ),
                            ),
                          ),
                          Center(
                            child: SizedBox(
                              width: 120,
                              height: 120,
                              child: CircularProgressIndicator(
                                value: subject.overallScore / 10.0,
                                strokeWidth: 12,
                                strokeCap: StrokeCap.round,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  subject.overallScore >= 8.0
                                      ? const Color(0xFFE65100) // Orange stroke
                                      : (subject.overallScore >= 5.0
                                          ? const Color(0xFFFFB74D)
                                          : const Color(0xFFD32F2F)),
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${subject.overallScore}',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF212121),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '/ 10',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Performance Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: performanceBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(performanceIcon, size: 14, color: performanceTextColor),
                          const SizedBox(width: 6),
                          Text(
                            performanceText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: performanceTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // 2. Grade Components Header
              const Text(
                'Grade Components',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Components cards list
              _buildComponentCard(
                icon: Icons.assignment_ind_outlined,
                title: 'Attendance',
                weight: '10%',
                score: attendanceScore,
                isTbd: false,
              ),
              _buildComponentCard(
                icon: Icons.quiz_outlined,
                title: 'Quiz 1',
                weight: '10%',
                score: quizScore,
                isTbd: false,
              ),
              _buildComponentCard(
                icon: Icons.assignment_outlined,
                title: 'Assignment 1',
                weight: '20%',
                score: assignmentScore,
                isTbd: false,
              ),
              _buildComponentCard(
                icon: Icons.laptop_chromebook_rounded,
                title: 'Practical Exam',
                weight: '30%',
                score: practicalScore,
                isTbd: false,
              ),
              _buildComponentCard(
                icon: Icons.school_outlined,
                title: 'Final Exam',
                weight: '30%',
                score: 0.0,
                isTbd: true, // Marked as TBD as in the screenshot
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComponentCard({
    required IconData icon,
    required String title,
    required String weight,
    required double score,
    required bool isTbd,
  }) {
    Color scoreColor = const Color(0xFF2E7D32);
    if (score < 5.0) {
      scoreColor = const Color(0xFFC62828);
    } else if (score < 8.0) {
      scoreColor = const Color(0xFFE65100);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon tròn bên trái
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.grey.shade600, size: 18),
          ),
          const SizedBox(width: 12),
          // Tiêu đề & Trọng số
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Weight: $weight',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Điểm hiển thị bên phải
          if (isTbd)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'TBD',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$score',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
                Text(
                  '/ 10',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

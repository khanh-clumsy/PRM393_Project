import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/announcement_controller.dart';
import '../../controllers/teacher_classes_controller.dart';
import '../../models/teaching_assignment_model.dart';

class TeacherClassAnnouncementView extends StatefulWidget {
  const TeacherClassAnnouncementView({super.key});

  @override
  State<TeacherClassAnnouncementView> createState() => _TeacherClassAnnouncementViewState();
}

class _TeacherClassAnnouncementViewState extends State<TeacherClassAnnouncementView> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  late final TeacherClassesController _classesCtrl;
  late final AnnouncementController _announcementCtrl;
  TeachingAssignmentModel? _selectedAssignment;
  String _priority = 'Normal';

  @override
  void initState() {
    super.initState();
    _classesCtrl = Get.put(TeacherClassesController(), tag: 'teacher_class_announcement_classes');
    _announcementCtrl = Get.put(AnnouncementController(), tag: 'teacher_class_announcement');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: const Text('Dang thong bao lop', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Obx(() {
          if (_classesCtrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_classesCtrl.errorMessage.value.isNotEmpty) {
            return Center(child: Text(_classesCtrl.errorMessage.value));
          }

          final assignments = _classesCtrl.filteredAssignments;
          _selectedAssignment ??= assignments.isNotEmpty ? assignments.first : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<TeachingAssignmentModel>(
                    value: _selectedAssignment,
                    decoration: const InputDecoration(
                      labelText: 'Lop',
                      border: OutlineInputBorder(),
                    ),
                    items: assignments
                        .map(
                          (a) => DropdownMenuItem(
                            value: a,
                            child: Text('${a.className ?? 'Lop ${a.classId}'} - ${a.subjectName ?? 'Mon hoc'}'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _selectedAssignment = value),
                    validator: (value) => value == null ? 'Vui long chon lop' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(labelText: 'Tieu de', border: OutlineInputBorder()),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Vui long nhap tieu de' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _contentCtrl,
                    decoration: const InputDecoration(labelText: 'Noi dung', border: OutlineInputBorder()),
                    minLines: 5,
                    maxLines: 8,
                    validator: (value) => value == null || value.trim().isEmpty ? 'Vui long nhap noi dung' : null,
                  ),
                  const SizedBox(height: 14),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'Normal', label: Text('Binh thuong'), icon: Icon(Icons.info_outline)),
                      ButtonSegment(value: 'Urgent', label: Text('Khan'), icon: Icon(Icons.priority_high_rounded)),
                    ],
                    selected: {_priority},
                    onSelectionChanged: (values) => setState(() => _priority = values.first),
                  ),
                  const SizedBox(height: 22),
                  Obx(
                    () => FilledButton.icon(
                      onPressed: _announcementCtrl.isSubmitting.value ? null : _submit,
                      icon: _announcementCtrl.isSubmitting.value
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.send_rounded),
                      label: const Text('Dang thong bao'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final assignment = _selectedAssignment;
    if (assignment == null) return;

    await _announcementCtrl.createAnnouncement(
      _titleCtrl.text.trim(),
      _contentCtrl.text.trim(),
      'Class',
      _priority,
      [assignment.classId],
    );
    if (mounted) Navigator.of(context).pop();
  }
}

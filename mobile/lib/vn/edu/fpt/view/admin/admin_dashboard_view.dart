import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  bool _loading = true;
  String _error = '';
  int _userCount = 0;
  int _classCount = 0;
  int _subjectCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final results = await Future.wait([
        ApiClient.instance.get('/api/user'),
        ApiClient.instance.get('/api/class'),
        ApiClient.instance.get('/api/subject'),
      ]);
      _userCount = (results[0].data as List).length;
      _classCount = (results[1].data as List).length;
      _subjectCount = (results[2].data as List).length;
    } on DioException {
      _error = 'Không thể tải thống kê.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: const Text('Thống kê tổng quan', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE65100)))
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _statCard('Người dùng', _userCount, Icons.people, Colors.blue),
                      const SizedBox(height: 12),
                      _statCard('Lớp học', _classCount, Icons.class_, Colors.teal),
                      const SizedBox(height: 12),
                      _statCard('Môn học', _subjectCount, Icons.book, Colors.green),
                    ],
                  ),
                ),
    );
  }

  Widget _statCard(String title, int count, IconData icon, Color color) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withValues(alpha: 0.15), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text('$count', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../models/attendance_model.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<AttendanceModel> _attendanceList = [];

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
      if (userId != null) {
        final response = await _apiService.getUserAttendance(userId);
        if (response.statusCode == 200 && response.data['success']) {
          setState(() {
            _attendanceList = (response.data['data'] as List)
                .map((json) => AttendanceModel.fromJson(json))
                .toList();
            _attendanceList.sort((a, b) => b.date.compareTo(a.date));
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _markAttendance() async {
    try {
      final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
      if (userId == null) {
        Fluttertoast.showToast(msg: 'User not found');
        return;
      }

      final response = await _apiService.markAttendance({
        'userId': userId,
        'date': DateTime.now().toIso8601String(),
        'status': 'present',
      });

      if (response.statusCode == 201 && response.data['success']) {
        Fluttertoast.showToast(msg: 'Attendance marked successfully');
        _loadAttendance();
      } else {
        Fluttertoast.showToast(msg: response.data['message'] ?? 'Failed to mark attendance');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.deepPurple.shade50,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mark Today\'s Attendance',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        DateTime.now().toString().split(' ')[0],
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _markAttendance,
                  icon: Icon(Icons.check_circle),
                  label: Text('Mark Present'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _attendanceList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_busy, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No attendance records',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadAttendance,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _attendanceList.length,
                          itemBuilder: (context, index) {
                            final attendance = _attendanceList[index];
                            final isPresent = attendance.status == 'present';
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isPresent ? Colors.green : Colors.red,
                                  child: Icon(
                                    isPresent ? Icons.check : Icons.close,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  attendance.date.toLocal().toString().split(' ')[0],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  attendance.date.toLocal().toString().split(' ')[1].substring(0, 5),
                                ),
                                trailing: Chip(
                                  label: Text(
                                    attendance.status.toUpperCase(),
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  backgroundColor: isPresent
                                      ? Colors.green.shade100
                                      : Colors.red.shade100,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

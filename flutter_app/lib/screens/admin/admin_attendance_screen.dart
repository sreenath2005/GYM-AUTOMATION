import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../models/attendance_model.dart';

class AdminAttendanceScreen extends StatefulWidget {
  const AdminAttendanceScreen({super.key});

  @override
  State<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends State<AdminAttendanceScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<AttendanceModel> _attendance = [];
  DateTime _selectedDate = DateTime.now();

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
      final dateStr = _selectedDate.toIso8601String().split('T')[0];
      final response = await _apiService.getAllAttendance(date: dateStr);
      if (response.statusCode == 200 && response.data['success']) {
        setState(() {
          _attendance = (response.data['data'] as List)
              .map((json) => AttendanceModel.fromJson(json))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadAttendance();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Date: ${_selectedDate.toLocal().toString().split(' ')[0]}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadAttendance,
                    child: _attendance.isEmpty
                        ? Center(child: Text('No attendance records for this date'))
                        : ListView.builder(
                            itemCount: _attendance.length,
                            padding: const EdgeInsets.all(8),
                            itemBuilder: (context, index) {
                              final record = _attendance[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: record.status == 'present'
                                        ? Colors.green
                                        : Colors.red,
                                    child: Icon(
                                      record.status == 'present'
                                          ? Icons.check
                                          : Icons.close,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(record.userName ?? 'Unknown'),
                                  subtitle: Text(record.date.toLocal().toString()),
                                  trailing: Chip(
                                    label: Text(record.status.toUpperCase()),
                                    backgroundColor: record.status == 'present'
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show mark attendance dialog
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

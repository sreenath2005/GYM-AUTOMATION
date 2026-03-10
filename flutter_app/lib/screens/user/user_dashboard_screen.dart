import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/services/api_service.dart';
import 'attendance_history_screen.dart';
import 'membership_plans_screen.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  Map<String, dynamic>? _attendanceStats;
  Map<String, dynamic>? _paymentStats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
      if (userId != null) {
        final attendanceResponse = await _apiService.getAttendanceStats(userId);
        final paymentResponse = await _apiService.getPaymentStats(userId);

        if (mounted && attendanceResponse.statusCode == 200 &&
            attendanceResponse.data['success']) {
          _attendanceStats = attendanceResponse.data['data'];
        }

        if (mounted && paymentResponse.statusCode == 200 &&
            paymentResponse.data['success']) {
          _paymentStats = paymentResponse.data['data'];
        }
      }
    } catch (e) {
      // Ignore - show empty state
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome,',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.name ?? 'User',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (user?.membershipType != null) ...[
                              const SizedBox(height: 8),
                              Chip(
                                label: Text(user!.membershipType!),
                                backgroundColor: Colors.green.shade100,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AttendanceHistoryScreen(),
                          ),
                        );
                      },
                      child: _buildStatCard(
                        'Today\'s Status',
                        _attendanceStats?['todayStatus'] == 'present'
                            ? 'Present'
                            : _attendanceStats?['todayStatus'] == 'absent'
                                ? 'Absent'
                                : 'Not Marked',
                        Icons.check_circle,
                        _attendanceStats?['todayStatus'] == 'present'
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatCard(
                      'Monthly Attendance',
                      '${_attendanceStats?['attendancePercentage']?.toStringAsFixed(1) ?? '0'}%',
                      Icons.trending_up,
                      Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const MembershipPlansScreen(),
                          ),
                        );
                      },
                      child: _buildStatCard(
                        'Membership',
                        user?.membershipType ?? 'No Plan',
                        Icons.card_membership,
                        Colors.purple,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildStatCard(
                      'Pending Dues',
                      '₹${_paymentStats?['pendingTotal']?.toString() ?? '0'}',
                      Icons.payment,
                      Colors.orange,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

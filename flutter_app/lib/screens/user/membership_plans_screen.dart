import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/services/api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'payment_screen.dart';

class MembershipPlansScreen extends StatefulWidget {
  const MembershipPlansScreen({super.key});

  @override
  State<MembershipPlansScreen> createState() => _MembershipPlansScreenState();
}

class _MembershipPlansScreenState extends State<MembershipPlansScreen> {

  final List<Map<String, dynamic>> _plans = [
    {
      'name': '1 Month',
      'duration': 1,
      'price': 1000,
      'discount': 0,
      'color': Colors.blue,
    },
    {
      'name': '3 Months',
      'duration': 3,
      'price': 2700,
      'discount': 10,
      'color': Colors.green,
      'popular': true,
    },
    {
      'name': '6 Months',
      'duration': 6,
      'price': 4800,
      'discount': 20,
      'color': Colors.orange,
    },
    {
      'name': '1 Year',
      'duration': 12,
      'price': 8400,
      'discount': 30,
      'color': Colors.purple,
    },
  ];

  Future<void> _selectPlan(Map<String, dynamic> plan) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) {
      Fluttertoast.showToast(msg: 'User not found');
      return;
    }

    // Navigate to payment screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          plan: plan,
          userId: user.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentPlan = authProvider.user?.membershipType;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Membership Plans'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (currentPlan != null) ...[
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Plan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              currentPlan,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            Text(
              'Available Plans',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._plans.map((plan) {
              final isPopular = plan['popular'] == true;
              final originalPrice = plan['price'] / (1 - plan['discount'] / 100);
              final finalPrice = plan['price'];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: isPopular ? 8 : 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isPopular
                      ? BorderSide(color: plan['color'], width: 2)
                      : BorderSide.none,
                ),
                child: InkWell(
                  onTap: () => _selectPlan(plan),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: plan['color'].withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.fitness_center,
                                    color: plan['color'],
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  plan['name'],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            if (isPopular)
                              Chip(
                                label: Text('POPULAR'),
                                backgroundColor: plan['color'],
                                labelStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 16),
                        if (plan['discount'] > 0) ...[
                          Row(
                            children: [
                              Text(
                                '₹${originalPrice.toStringAsFixed(0)}',
                                style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${plan['discount']}% OFF',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                        ],
                        Text(
                          '₹${finalPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: plan['color'],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '₹${(finalPrice / plan['duration']).toStringAsFixed(0)}/month',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _selectPlan(plan),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: plan['color'],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.payment),
                              SizedBox(width: 8),
                              Text('Select Plan'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../models/payment_model.dart';

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<PaymentModel> _payments = [];

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.getPayments();
      if (response.statusCode == 200 && response.data['success']) {
        setState(() {
          _payments = (response.data['data'] as List)
              .map((json) => PaymentModel.fromJson(json))
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Show add payment dialog
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPayments,
              child: _payments.isEmpty
                  ? Center(child: Text('No payments found'))
                  : ListView.builder(
                      itemCount: _payments.length,
                      padding: const EdgeInsets.all(8),
                      itemBuilder: (context, index) {
                        final payment = _payments[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: payment.status == 'paid'
                                  ? Colors.green
                                  : Colors.orange,
                              child: Icon(
                                Icons.currency_rupee,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(payment.userName ?? 'Unknown'),
                            subtitle: Text(
                              '${payment.date.toLocal().toString().split(' ')[0]}\n${payment.method.toUpperCase()}',
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${payment.amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    payment.status.toUpperCase(),
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  backgroundColor: payment.status == 'paid'
                                      ? Colors.green.shade100
                                      : Colors.orange.shade100,
                                ),
                              ],
                            ),
                            onTap: () {
                              // Show payment details
                            },
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

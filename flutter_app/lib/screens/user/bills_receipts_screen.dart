import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../models/payment_model.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BillsReceiptsScreen extends StatefulWidget {
  const BillsReceiptsScreen({super.key});

  @override
  State<BillsReceiptsScreen> createState() => _BillsReceiptsScreenState();
}

class _BillsReceiptsScreenState extends State<BillsReceiptsScreen> {
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
          _payments.sort((a, b) => b.date.compareTo(a.date));
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateReceipt(PaymentModel payment) async {
    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'GYM AUTOMATION SYSTEM',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text('RECEIPT', style: pw.TextStyle(fontSize: 20)),
                pw.Divider(),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Receipt No: ${payment.id.length >= 8 ? payment.id.substring(0, 8) : payment.id}'),
                        pw.Text('Date: ${payment.date.toLocal().toString().split(' ')[0]}'),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Status: ${payment.status.toUpperCase()}'),
                        pw.Text('Method: ${payment.method.toUpperCase()}'),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),
                pw.Text('Bill To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text(user?.name ?? 'User'),
                pw.Text(user?.email ?? ''),
                pw.Text(user?.phone ?? ''),
                pw.SizedBox(height: 30),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(payment.description != null && payment.description!.isNotEmpty ? payment.description! : 'Membership Payment'),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('₹${payment.amount.toStringAsFixed(2)}', textAlign: pw.TextAlign.right),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('₹${payment.amount.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.Spacer(),
                pw.Center(
                  child: pw.Text(
                    'Thank you for your payment!',
                    style: pw.TextStyle(fontSize: 14, fontStyle: pw.FontStyle.italic),
                  ),
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error generating receipt: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bills & Receipts'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _payments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No bills found',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPayments,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _payments.length,
                    itemBuilder: (context, index) {
                      final payment = _payments[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: payment.status == 'paid' ? Colors.green : Colors.orange,
                            child: Icon(
                              Icons.receipt,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            '₹${payment.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(payment.description != null && payment.description!.isNotEmpty ? payment.description! : 'Membership Payment'),
                              SizedBox(height: 4),
                              Text(
                                '${payment.date.toLocal().toString().split(' ')[0]} • ${payment.method.toUpperCase()}',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Chip(
                                label: Text(
                                  payment.status.toUpperCase(),
                                  style: TextStyle(fontSize: 10),
                                ),
                                backgroundColor: payment.status == 'paid'
                                    ? Colors.green.shade100
                                    : Colors.orange.shade100,
                              ),
                              IconButton(
                                icon: Icon(Icons.download),
                                onPressed: () => _generateReceipt(payment),
                                tooltip: 'Download Receipt',
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

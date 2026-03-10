import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/services/razorpay_stub.dart'
    if (dart.library.js) '../../core/services/razorpay_web_service.dart';
import '../../core/services/api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> plan;
  final String userId;

  const PaymentScreen({
    super.key,
    required this.plan,
    required this.userId,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

enum PaymentMethod { razorpay, cash }

class _PaymentScreenState extends State<PaymentScreen> {
  final RazorpayWebService _razorpayService = RazorpayWebService();
  final ApiService _apiService = ApiService();
  bool _isProcessing = false;
  PaymentMethod _selectedMethod = PaymentMethod.razorpay;

  // ── Razorpay ──────────────────────────────────────────────────────────────
  Future<void> _payWithRazorpay() async {
    setState(() => _isProcessing = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    final result = await _razorpayService.initiatePayment(
      amount: (widget.plan['price'] as num).toDouble(),
      planName: widget.plan['name'],
      userId: widget.userId,
      userEmail: user?.email ?? '',
      userName: user?.name ?? '',
      userPhone: user?.phone ?? '',
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (result['success'] == true) {
      final updatedUser = user?.copyWith(membershipType: widget.plan['name']);
      if (updatedUser != null) authProvider.updateUser(updatedUser);
      _showSuccessDialog(isCash: false);
    } else {
      Fluttertoast.showToast(msg: result['message'] ?? 'Payment failed', backgroundColor: Colors.red, textColor: Colors.white);
    }
  }

  // ── Cash ──────────────────────────────────────────────────────────────────
  Future<void> _payWithCash() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Cash Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.payments_outlined, size: 48, color: Colors.green),
            const SizedBox(height: 12),
            Text(
              'You selected to pay ₹${(widget.plan['price'] as num).toStringAsFixed(0)} in CASH at the gym counter.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(10)),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your membership will be activated after the gym owner confirms your cash payment.',
                      style: TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isProcessing = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await _apiService.recordCashPayment(
        amount: (widget.plan['price'] as num).toDouble(),
        planName: widget.plan['name'],
      );

      if (!mounted) return;
      setState(() => _isProcessing = false);

      if (response.statusCode == 201 && response.data['success']) {
        final user = authProvider.user;
        final updatedUser = user?.copyWith(membershipType: widget.plan['name']);
        if (updatedUser != null) authProvider.updateUser(updatedUser);
        final receiptNo = response.data['data']['receiptNo'] ?? '';
        _showSuccessDialog(isCash: true, receiptNo: receiptNo);
      } else {
        Fluttertoast.showToast(msg: response.data['message'] ?? 'Failed', backgroundColor: Colors.red);
      }
    } catch (e) {
      if (mounted) setState(() => _isProcessing = false);
      Fluttertoast.showToast(msg: 'Error: $e', backgroundColor: Colors.red);
    }
  }

  void _showSuccessDialog({required bool isCash, String receiptNo = ''}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(shape: BoxShape.circle, color: isCash ? Colors.green.shade50 : Colors.green.shade50),
              child: Icon(isCash ? Icons.payments_outlined : Icons.check_circle,
                  color: Colors.green, size: 56),
            ),
            const SizedBox(height: 20),
            Text(
              isCash ? 'Cash Request Recorded!' : 'Payment Successful!',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isCash
                  ? 'Please visit the gym counter to complete your payment.'
                  : '${widget.plan['name']} membership activated!',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            if (isCash && receiptNo.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    const Text('Receipt No.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Text(receiptNo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(10)),
                child: const Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.orange, size: 16),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text('Membership activates after admin confirms your payment.',
                          style: TextStyle(fontSize: 11, color: Colors.orange)),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Go to Dashboard', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final price = (widget.plan['price'] as num).toDouble();
    final planName = widget.plan['name'] as String;
    final durationRaw = widget.plan['duration'];
    final duration = durationRaw != null ? '$durationRaw Month${durationRaw == 1 ? '' : 's'}' : '';
    final features = widget.plan['features'] as List? ?? [];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Complete Payment', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Plan Card ──
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple.shade700, Colors.purple.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.deepPurple.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                        child: Text(planName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const Spacer(),
                      if (duration.isNotEmpty)
                        Text(duration, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('₹${price.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.bold)),
                  if (features.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white30),
                    const SizedBox(height: 10),
                    ...features.take(4).map((f) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.greenAccent, size: 18),
                              const SizedBox(width: 8),
                              Expanded(child: Text(f.toString(), style: const TextStyle(color: Colors.white, fontSize: 13))),
                            ],
                          ),
                        )),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Payment Method Selector ──
            const Text('Select Payment Method',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: _methodCard(
                  icon: Icons.payment,
                  label: 'Razorpay',
                  subtitle: 'UPI · Cards · Net Banking',
                  color: const Color(0xFF3395FF),
                  method: PaymentMethod.razorpay,
                )),
                const SizedBox(width: 12),
                Expanded(child: _methodCard(
                  icon: Icons.payments_outlined,
                  label: 'Cash',
                  subtitle: 'Pay at gym counter',
                  color: Colors.green,
                  method: PaymentMethod.cash,
                )),
              ],
            ),

            const SizedBox(height: 20),

            // ── Order Summary ──
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Order Summary', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _summaryRow('Plan', planName),
                  if (duration.isNotEmpty) _summaryRow('Duration', duration),
                  _summaryRow('Method', _selectedMethod == PaymentMethod.cash ? 'Cash at Counter' : 'Razorpay'),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('₹${price.toStringAsFixed(0)}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepPurple.shade700)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Cash info banner ──
            if (_selectedMethod == PaymentMethod.cash)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.green),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'A cash payment request will be recorded. Visit the gym counter to pay and get your membership activated.',
                        style: TextStyle(color: Colors.green, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            if (_selectedMethod == PaymentMethod.razorpay)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 6),
                  Text('Secured by Razorpay · 256-bit SSL', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                ],
              ),

            const SizedBox(height: 24),

            // ── Pay Button ──
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isProcessing
                    ? null
                    : (_selectedMethod == PaymentMethod.cash ? _payWithCash : _payWithRazorpay),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedMethod == PaymentMethod.cash ? Colors.green : const Color(0xFF3395FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 24, width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_selectedMethod == PaymentMethod.cash ? Icons.payments_outlined : Icons.payment, size: 22),
                          const SizedBox(width: 10),
                          Text(
                            _selectedMethod == PaymentMethod.cash
                                ? 'Request Cash Payment for ₹${price.toStringAsFixed(0)}'
                                : 'Pay ₹${price.toStringAsFixed(0)} with Razorpay',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _methodCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required PaymentMethod method,
  }) {
    final selected = _selectedMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? color : Colors.grey.shade200, width: selected ? 2 : 1),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: selected ? color : Colors.grey, size: 22),
                const Spacer(),
                Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: selected ? color : Colors.grey.shade400, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: selected ? color : Colors.black87)),
            Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

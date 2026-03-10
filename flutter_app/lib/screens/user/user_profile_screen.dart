import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/services/profile_image_service.dart';
import '../../models/payment_model.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';
import 'bills_receipts_screen.dart';
import 'progress_tracking_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<PaymentModel> _payments = [];
  Uint8List? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadPayments();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
    if (userId == null) return;
    final bytes = await ProfileImageService.loadImage(userId);
    if (mounted) setState(() => _profileImage = bytes);
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
    if (userId != null) await ProfileImageService.saveImage(userId, bytes);
    if (mounted) setState(() => _profileImage = bytes);
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.getPayments();
      if (response.statusCode == 200 && response.data['success']) {
        setState(() {
          _payments = (response.data['data'] as List)
              .map((j) => PaymentModel.fromJson(j))
              .toList();
        });
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final initials = (user?.name ?? 'U').split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // ── Hero AppBar ──
          SliverAppBar(
            expandedHeight: 230,
            pinned: true,
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit Profile',
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const EditProfileScreen()))
                      .then((_) {
                    setState(() {});
                    _loadProfileImage();
                  });
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF512DA8), Color(0xFF9C27B0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          GestureDetector(
                            onTap: _pickProfileImage,
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.2),
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                              child: ClipOval(
                                child: _profileImage != null
                                    ? Image.memory(
                                        _profileImage!,
                                        fit: BoxFit.cover,
                                        width: 90,
                                        height: 90,
                                      )
                                    : Center(
                                        child: Text(initials,
                                            style: const TextStyle(
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                      ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _pickProfileImage,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                              child: const Icon(Icons.camera_alt, size: 16, color: Colors.deepPurple),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(user?.name ?? 'User',
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(user?.email ?? '',
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Info Card ──
                  _sectionCard([
                    _infoRow(Icons.person_outline, 'Full Name', user?.name ?? '—'),
                    const Divider(height: 1),
                    _infoRow(Icons.email_outlined, 'Email', user?.email ?? '—'),
                    const Divider(height: 1),
                    _infoRow(Icons.phone_outlined, 'Phone', user?.phone ?? '—'),
                    if (user?.membershipType != null) ...[
                      const Divider(height: 1),
                      _infoRow(Icons.card_membership, 'Membership', user!.membershipType!,
                          valueColor: Colors.green.shade700),
                    ],
                  ]),

                  const SizedBox(height: 16),

                  // ── Edit Profile button ──
                  _actionTile(
                    icon: Icons.edit_note,
                    color: Colors.deepPurple,
                    title: 'Edit Profile',
                    subtitle: 'Update your name, email & phone',
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) => const EditProfileScreen()))
                          .then((_) => setState(() {}));
                    },
                  ),

                  const SizedBox(height: 10),

                  _actionTile(
                    icon: Icons.trending_up,
                    color: Colors.teal,
                    title: 'Progress Tracking',
                    subtitle: 'Track your weight and measurements',
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ProgressTrackingScreen())),
                  ),

                  const SizedBox(height: 10),

                  _actionTile(
                    icon: Icons.receipt_long,
                    color: Colors.indigo,
                    title: 'Bills & Receipts',
                    subtitle: 'View all your payment receipts',
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const BillsReceiptsScreen())),
                  ),

                  const SizedBox(height: 20),

                  // ── Payment History ──
                  const Text('Payment History',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                  const SizedBox(height: 10),

                  _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
                      : _payments.isEmpty
                          ? _emptyCard('No payment history yet.')
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _payments.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (_, i) => _paymentCard(_payments[i]),
                            ),

                  const SizedBox(height: 20),

                  // ── Logout ──
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await authProvider.logout();
                        if (mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      },
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 18, color: Colors.deepPurple),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value,
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600, color: valueColor ?? const Color(0xFF222222))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionTile({required IconData icon, required Color color, required String title, required String subtitle, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _paymentCard(PaymentModel payment) {
    final isPaid = payment.status == 'paid';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isPaid ? Colors.green : Colors.orange).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.currency_rupee, color: isPaid ? Colors.green : Colors.orange, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('₹${payment.amount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text('${payment.date.toLocal().toString().split(' ')[0]} · ${payment.method.toUpperCase()}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (isPaid ? Colors.green : Colors.orange).withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(payment.status.toUpperCase(),
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.bold, color: isPaid ? Colors.green.shade700 : Colors.orange.shade700)),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500])),
    );
  }
}

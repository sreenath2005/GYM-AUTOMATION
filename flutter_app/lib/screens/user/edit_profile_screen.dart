import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/services/profile_image_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _nameChanged = false;
  bool _emailChanged = false;
  bool _phoneChanged = false;
  Uint8List? _profileImage;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _nameController.text = user?.name ?? '';
    _emailController.text = user?.email ?? '';
    _phoneController.text = user?.phone ?? '';

    _nameController.addListener(() => setState(() => _nameChanged = true));
    _emailController.addListener(() => setState(() => _emailChanged = true));
    _phoneController.addListener(() => setState(() => _phoneChanged = true));
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool get _hasChanges => _nameChanged || _emailChanged || _phoneChanged;

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;
      if (userId == null) {
        Fluttertoast.showToast(msg: 'User not found');
        return;
      }

      final response = await _apiService.updateUser(userId, {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
      });

      if (response.statusCode == 200 && response.data['success']) {
        final updatedUser = authProvider.user?.copyWith(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
        );
        if (updatedUser != null) authProvider.updateUser(updatedUser);
        if (mounted) {
          _showSuccessDialog();
        }
      } else {
        Fluttertoast.showToast(msg: response.data['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
              child: Icon(Icons.check_circle, color: Colors.green, size: 50),
            ),
            const SizedBox(height: 16),
            const Text('Profile Updated!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Your profile has been successfully updated.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
                Navigator.of(context).pop(); // go back to profile
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    final initials = (user?.name ?? 'U').split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Avatar header ──
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF512DA8), Color(0xFF9C27B0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickProfileImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.25),
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: ClipOval(
                            child: _profileImage != null
                                ? Image.memory(
                                    _profileImage!,
                                    fit: BoxFit.cover,
                                    width: 88,
                                    height: 88,
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
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: Colors.white),
                          child: const Icon(Icons.camera_alt,
                              size: 15, color: Colors.deepPurple),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('Tap photo to change',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 2),
                  const Text('Update your personal info',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),

            // ── Form ──
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    _fieldLabel('Full Name'),
                    const SizedBox(height: 6),
                    _buildField(
                      controller: _nameController,
                      icon: Icons.person_outline,
                      hint: 'Enter your full name',
                      changed: _nameChanged,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 18),
                    _fieldLabel('Email Address'),
                    const SizedBox(height: 6),
                    _buildField(
                      controller: _emailController,
                      icon: Icons.email_outlined,
                      hint: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      changed: _emailChanged,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Please enter your email';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    _fieldLabel('Phone Number'),
                    const SizedBox(height: 6),
                    _buildField(
                      controller: _phoneController,
                      icon: Icons.phone_outlined,
                      hint: 'Enter your phone number',
                      keyboardType: TextInputType.phone,
                      changed: _phoneChanged,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your phone number' : null,
                    ),

                    const SizedBox(height: 32),

                    // ── Save Button ──
                    SizedBox(
                      width: double.infinity,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _hasChanges ? Colors.deepPurple : Colors.grey.shade400,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: _hasChanges ? 4 : 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.save_outlined, size: 20),
                                    const SizedBox(width: 8),
                                    const Text('Save Changes',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Cancel ──
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF444444)));
  }

  Widget _buildField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    required bool changed,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFBBBBBB)),
        prefixIcon: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: changed ? Colors.deepPurple.withOpacity(0.08) : Colors.grey.withOpacity(0.06),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: changed ? Colors.deepPurple : Colors.grey),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: changed ? Colors.deepPurple.withOpacity(0.4) : Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: changed
            ? const Icon(Icons.edit, size: 16, color: Colors.deepPurple)
            : null,
      ),
    );
  }
}

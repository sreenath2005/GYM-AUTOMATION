/// Stub implementation for non-web platforms (Android, iOS, Windows, etc.)
/// Razorpay web checkout is not available on these platforms.

class RazorpayWebService {
  Future<Map<String, dynamic>> initiatePayment({
    required double amount,
    required String planName,
    required String userId,
    required String userEmail,
    required String userName,
    required String userPhone,
  }) async {
    return {
      'success': false,
      'message': 'Online payment via Razorpay is only available on the web app. Please use Cash payment or visit the gym counter.',
    };
  }
}

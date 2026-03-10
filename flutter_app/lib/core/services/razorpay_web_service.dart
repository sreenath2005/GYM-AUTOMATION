// This file is only compiled for web via conditional import in payment_screen.dart
// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import '../services/api_service.dart';

@JS('openRazorpay')
external void _openRazorpay(JSAny options);

class RazorpayWebService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> initiatePayment({
    required double amount,
    required String planName,
    required String userId,
    required String userEmail,
    required String userName,
    required String userPhone,
  }) async {
    final completer = Completer<Map<String, dynamic>>();

    try {
      final orderResponse = await _apiService.createRazorpayOrder({
        'amount': amount,
        'currency': 'INR',
        'planName': planName,
      });

      if (orderResponse.statusCode != 200 || !orderResponse.data['success']) {
        return {'success': false, 'message': 'Failed to create payment order'};
      }

      final orderData = orderResponse.data['data'];
      final orderId = orderData['orderId'] as String;
      final orderAmount = orderData['amount'];
      final keyId = orderData['keyId'] as String;

      // Build the Razorpay handler JS function
      // Note: .toJS does not support async closures; use a sync wrapper that
      // spawns the async work without awaiting it at the JS boundary.
      final handler = (JSAny response) {
        Future(() async {
          try {
            final jsResponse = response as JSObject;
            final ordId = jsResponse.getProperty<JSString>('razorpay_order_id'.toJS).toDart;
            final payId = jsResponse.getProperty<JSString>('razorpay_payment_id'.toJS).toDart;
            final sig = jsResponse.getProperty<JSString>('razorpay_signature'.toJS).toDart;

            final verifyResponse = await _apiService.verifyRazorpayPayment({
              'razorpay_order_id': ordId,
              'razorpay_payment_id': payId,
              'razorpay_signature': sig,
              'amount': orderAmount,
              'planName': planName,
              'userId': userId,
            });

            if (verifyResponse.statusCode == 200 && verifyResponse.data['success']) {
              completer.complete({'success': true, 'message': 'Payment successful! Membership activated.'});
            } else {
              completer.complete({'success': false, 'message': 'Payment verification failed'});
            }
          } catch (e) {
            completer.complete({'success': false, 'message': 'Verification error: $e'});
          }
        });
      }.toJS;

      final dismissHandler = () {
        if (!completer.isCompleted) {
          completer.complete({'success': false, 'message': 'Payment cancelled'});
        }
      }.toJS;

      final options = {
        'key': keyId,
        'amount': orderAmount,
        'currency': 'INR',
        'name': 'My Gym',
        'description': 'Membership: $planName',
        'order_id': orderId,
        'prefill': {
          'name': userName,
          'email': userEmail,
          'contact': userPhone,
        },
        'theme': {'color': '#6200EE'},
        'modal': {'ondismiss': dismissHandler},
        'handler': handler,
      }.jsify()!;

      _openRazorpay(options);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }

    return completer.future;
  }
}

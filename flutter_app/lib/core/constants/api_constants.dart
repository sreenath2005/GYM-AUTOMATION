import 'package:flutter/foundation.dart';

class ApiConstants {
  // Base URL - switches automatically between web and mobile
  // For web/Chrome: http://localhost:5000/api
  // For mobile (Android APK): use your PC's local Wi-Fi IP e.g. http://192.168.38.120:5000/api
  static String get baseUrl =>
      kIsWeb ? 'http://localhost:5000/api' : 'https://gym-automation.onrender.com';
  // For production: static const String baseUrl = 'https://your-backend-url.com/api';
  
  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String getMe = '/auth/me';
  static const String forgotPassword = '/auth/forgotpassword';
  static const String resetPassword = '/auth/resetpassword';
  
  // User endpoints
  static const String users = '/users';
  static const String dashboardStats = '/users/stats/dashboard';
  
  // Attendance endpoints
  static const String attendance = '/attendance';
  static const String attendanceStats = '/attendance/stats';
  
  // Payment endpoints
  static const String payments = '/payments';
  static const String paymentStats = '/payments/stats';
  static const String razorpayOrder = '/payments/razorpay/order';
  static const String razorpayVerify = '/payments/razorpay/verify';
  static const String cashPayment = '/payments/cash';
  
  // Diet Plan endpoints
  static const String dietPlans = '/diet-plans';
  
  // Workout endpoints
  static const String workouts = '/workouts';
}

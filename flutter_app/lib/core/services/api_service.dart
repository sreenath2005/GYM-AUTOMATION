import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import 'storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  
  late Dio _dio;
  final StorageService _storageService = StorageService();

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add interceptor for token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Token expired or invalid
            _storageService.clearAll();
          }
          // Log error for debugging
          if (kDebugMode) {
            print('API Error: ${error.requestOptions.path}');
            print('Status: ${error.response?.statusCode}');
            print('Message: ${error.response?.data}');
          }
          return handler.next(error);
        },
      ),
    );
  }

  // Auth APIs
  Future<Response> register(Map<String, dynamic> data) async {
    return await _dio.post(ApiConstants.register, data: data);
  }

  Future<Response> login(Map<String, dynamic> data) async {
    return await _dio.post(ApiConstants.login, data: data);
  }

  Future<Response> getMe() async {
    return await _dio.get(ApiConstants.getMe);
  }

  Future<Response> forgotPassword(Map<String, dynamic> data) async {
    return await _dio.post(ApiConstants.forgotPassword, data: data);
  }

  Future<Response> resetPassword(Map<String, dynamic> data) async {
    return await _dio.post(ApiConstants.resetPassword, data: data);
  }

  // User APIs
  Future<Response> getUsers() async {
    return await _dio.get(ApiConstants.users);
  }

  Future<Response> getUser(String id) async {
    return await _dio.get('${ApiConstants.users}/$id');
  }

  Future<Response> createUser(Map<String, dynamic> data) async {
    return await _dio.post(ApiConstants.users, data: data);
  }

  Future<Response> updateUser(String id, Map<String, dynamic> data) async {
    return await _dio.put('${ApiConstants.users}/$id', data: data);
  }

  Future<Response> deleteUser(String id) async {
    return await _dio.delete('${ApiConstants.users}/$id');
  }

  Future<Response> getDashboardStats() async {
    return await _dio.get(ApiConstants.dashboardStats);
  }

  // Attendance APIs
  Future<Response> markAttendance(Map<String, dynamic> data) async {
    return await _dio.post(ApiConstants.attendance, data: data);
  }

  Future<Response> getUserAttendance(String userId, {String? startDate, String? endDate}) async {
    String url = '${ApiConstants.attendance}/user/$userId';
    if (startDate != null && endDate != null) {
      url += '?startDate=$startDate&endDate=$endDate';
    }
    return await _dio.get(url);
  }

  Future<Response> getAllAttendance({String? date}) async {
    String url = ApiConstants.attendance;
    if (date != null) {
      url += '?date=$date';
    }
    return await _dio.get(url);
  }

  Future<Response> getAttendanceStats([String? userId]) async {
    String url = ApiConstants.attendanceStats;
    if (userId != null) {
      url += '/$userId';
    }
    return await _dio.get(url);
  }

  // Payment APIs
  Future<Response> createPayment(Map<String, dynamic> data) async {
    return await _dio.post(ApiConstants.payments, data: data);
  }

  Future<Response> getPayments({String? userId}) async {
    String url = ApiConstants.payments;
    if (userId != null) {
      url += '?userId=$userId';
    }
    return await _dio.get(url);
  }

  Future<Response> getPayment(String id) async {
    return await _dio.get('${ApiConstants.payments}/$id');
  }

  Future<Response> updatePayment(String id, Map<String, dynamic> data) async {
    return await _dio.put('${ApiConstants.payments}/$id', data: data);
  }

  Future<Response> deletePayment(String id) async {
    return await _dio.delete('${ApiConstants.payments}/$id');
  }

  Future<Response> getPaymentStats([String? userId]) async {
    String url = ApiConstants.paymentStats;
    if (userId != null) {
      url += '/$userId';
    }
    return await _dio.get(url);
  }

  Future<Response> createRazorpayOrder(Map<String, dynamic> data) async {
    return await _dio.post(ApiConstants.razorpayOrder, data: data);
  }

  Future<Response> verifyRazorpayPayment(Map<String, dynamic> data) async {
    return await _dio.post(ApiConstants.razorpayVerify, data: data);
  }

  // Diet Plan APIs
  Future<Response> getDietPlan([String? userId]) async {
    String url = ApiConstants.dietPlans;
    if (userId != null) {
      url += '/$userId';
    }
    return await _dio.get(url);
  }

  Future<Response> updateDietPlan(String userId, Map<String, dynamic> data) async {
    return await _dio.put('${ApiConstants.dietPlans}/$userId', data: data);
  }

  // Workout APIs
  Future<Response> getWorkouts({String? category}) async {
    String url = ApiConstants.workouts;
    if (category != null) {
      url += '?category=$category';
    }
    return await _dio.get(url);
  }

  Future<Response> getWorkout(String id) async {
    return await _dio.get('${ApiConstants.workouts}/$id');
  }

  Future<Response> createWorkout(Map<String, dynamic> data) async {
    return await _dio.post(ApiConstants.workouts, data: data);
  }

  Future<Response> updateWorkout(String id, Map<String, dynamic> data) async {
    return await _dio.put('${ApiConstants.workouts}/$id', data: data);
  }

  Future<Response> deleteWorkout(String id) async {
    return await _dio.delete('${ApiConstants.workouts}/$id');
  }

  Future<Response> seedWorkouts() async {
    return await _dio.post('${ApiConstants.workouts}/seed');
  }

  Future<Response> recordCashPayment({required double amount, required String planName}) async {
    return await _dio.post(
      ApiConstants.cashPayment,
      data: {'amount': amount, 'planName': planName},
    );
  }
}


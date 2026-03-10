class AppConstants {
  // App Info
  static const String appName = 'My Gym';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  
  // Membership Types
  static const List<String> membershipTypes = [
    'Basic',
    'Gold',
    'Platinum',
    'Premium',
  ];
  
  // Payment Methods
  static const List<String> paymentMethods = [
    'cash',
    'upi',
    'card',
  ];
  
  // Workout Categories
  static const List<String> workoutCategories = [
    'Chest',
    'Back',
    'Shoulders',
    'Arms',
    'Legs',
    'Cardio',
    'Abs',
    'Full Body',
  ];
}

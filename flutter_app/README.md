# Gym Automation Flutter App

Flutter application for Gym Automation System (Mobile + Web).

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (v3.0+)
- Dart SDK
- Android Studio / Xcode (for mobile)
- VS Code / Android Studio (IDE)

### Installation

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Update API base URL**
   
   Edit `lib/core/constants/api_constants.dart`:
   ```dart
   static const String baseUrl = 'http://localhost:5000/api';
   // For production: 'https://your-backend-url.com/api'
   ```

3. **Run the app**
   ```bash
   # Mobile (Android/iOS)
   flutter run
   
   # Web
   flutter run -d chrome
   
   # Specific device
   flutter devices
   flutter run -d <device-id>
   ```

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── api_constants.dart    # API endpoints
│   │   └── app_constants.dart     # App constants
│   └── services/
│       ├── api_service.dart       # HTTP client
│       └── storage_service.dart   # Local storage
├── models/
│   ├── user_model.dart
│   ├── attendance_model.dart
│   ├── payment_model.dart
│   ├── diet_plan_model.dart
│   └── workout_model.dart
├── providers/
│   └── auth_provider.dart         # Authentication state
├── screens/
│   ├── splash_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── admin/
│   │   ├── admin_home_screen.dart
│   │   ├── admin_dashboard_screen.dart
│   │   ├── admin_members_screen.dart
│   │   ├── admin_attendance_screen.dart
│   │   └── admin_payments_screen.dart
│   └── user/
│       ├── user_home_screen.dart
│       ├── user_dashboard_screen.dart
│       ├── user_workout_screen.dart
│       ├── user_diet_screen.dart
│       └── user_profile_screen.dart
└── main.dart
```

## 🎨 Features

### Authentication
- ✅ Splash screen with auto-login
- ✅ Login screen
- ✅ Signup screen
- ✅ JWT token storage
- ✅ Role-based navigation

### Admin Panel
- ✅ Dashboard with statistics
- ✅ Member management
- ✅ Attendance tracking
- ✅ Payment management

### User Panel
- ✅ Home dashboard
- ✅ Attendance status
- ✅ Payment history
- ✅ Workout videos
- ✅ Diet plan
- ✅ Profile management

## 🔧 Configuration

### API Configuration
Update `lib/core/constants/api_constants.dart`:

```dart
static const String baseUrl = 'http://your-backend-url.com/api';
```

### Storage
- JWT tokens stored securely using `flutter_secure_storage`
- User data stored in `SharedPreferences`

## 📱 Building

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🌐 Web Deployment

### Firebase Hosting
```bash
flutter build web
firebase init hosting
firebase deploy
```

### Vercel
1. Connect GitHub repository
2. Set build command: `flutter build web`
3. Set output directory: `build/web`
4. Deploy

### Netlify
1. Connect GitHub repository
2. Set build command: `flutter build web`
3. Set publish directory: `build/web`
4. Deploy

## 📦 Dependencies

### Core
- `provider` - State management
- `dio` - HTTP client
- `shared_preferences` - Local storage
- `flutter_secure_storage` - Secure token storage

### UI
- `google_fonts` - Custom fonts
- `cached_network_image` - Image caching
- `fluttertoast` - Toast notifications

### Features
- `video_player` - Video playback
- `chewie` - Video player UI
- `pdf` - PDF generation
- `printing` - PDF printing
- `image_picker` - Image selection

## 🔐 Authentication Flow

1. **Splash Screen**
   - Checks for stored JWT token
   - Validates token with backend
   - Redirects based on role

2. **Login/Signup**
   - User provides credentials
   - Token received from backend
   - Token stored securely
   - Navigate to appropriate dashboard

3. **API Requests**
   - Token automatically included in headers
   - Token refresh on 401 errors

## 🎯 State Management

Using **Provider** pattern:
- `AuthProvider` - Manages authentication state
- User data and token persistence
- Auto-login functionality

## 🐛 Troubleshooting

### API Connection Issues
- Check `api_constants.dart` base URL
- Verify backend is running
- Check CORS configuration

### Build Errors
```bash
flutter clean
flutter pub get
flutter run
```

### Token Issues
- Clear app data
- Re-login
- Check SecureStorage permissions

## 📝 Notes

- App supports both mobile and web platforms
- Responsive design for different screen sizes
- Dark mode support (can be added)
- Offline support (can be added)

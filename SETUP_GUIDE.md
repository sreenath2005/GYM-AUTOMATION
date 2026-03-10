# 🚀 Quick Setup Guide

Follow these steps to get your Gym Automation System up and running.

## Step 1: MongoDB Atlas Setup

1. **Create Account**
   - Go to https://www.mongodb.com/cloud/atlas
   - Sign up for free account

2. **Create Cluster**
   - Click "Build a Database"
   - Choose FREE tier (M0)
   - Select region
   - Click "Create"

3. **Create Database User**
   - Go to "Database Access"
   - Click "Add New Database User"
   - Choose "Password" authentication
   - Username: `gymadmin` (or your choice)
   - Password: Generate secure password (SAVE IT!)
   - Click "Add User"

4. **Whitelist IP**
   - Go to "Network Access"
   - Click "Add IP Address"
   - Click "Allow Access from Anywhere" (0.0.0.0/0)
   - Click "Confirm"

5. **Get Connection String**
   - Go to "Clusters" → Click "Connect"
   - Choose "Connect your application"
   - Copy connection string
   - Replace `<password>` with your database user password
   - Replace `<dbname>` with `gym`
   - Example: `mongodb+srv://gymadmin:yourpassword@cluster0.xxxxx.mongodb.net/gym?retryWrites=true&w=majority`

## Step 2: Backend Setup

1. **Navigate to backend**
   ```bash
   cd backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Create .env file**
   ```bash
   # Windows
   copy .env.example .env
   
   # Mac/Linux
   cp .env.example .env
   ```

4. **Edit .env file**
   ```env
   MONGO_URI=mongodb+srv://gymadmin:yourpassword@cluster0.xxxxx.mongodb.net/gym?retryWrites=true&w=majority
   JWT_SECRET=your_super_secret_jwt_key_min_32_characters_long
   PORT=5000
   NODE_ENV=development
   ```

5. **Start backend server**
   ```bash
   npm run dev
   ```

   ✅ Backend should be running on http://localhost:5000

## Step 3: Flutter App Setup

1. **Navigate to Flutter app**
   ```bash
   cd flutter_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Update API URL** (if needed)
   
   Edit `lib/core/constants/api_constants.dart`:
   ```dart
   static const String baseUrl = 'http://localhost:5000/api';
   ```
   
   For Android emulator, use: `http://10.0.2.2:5000/api`
   For iOS simulator, use: `http://localhost:5000/api`
   For physical device, use your computer's IP: `http://192.168.x.x:5000/api`

4. **Run Flutter app**
   ```bash
   # Check available devices
   flutter devices
   
   # Run on specific device
   flutter run -d <device-id>
   
   # Or run on web
   flutter run -d chrome
   ```

## Step 4: Test the Application

1. **Create Admin Account**
   - Open app → Sign Up
   - Fill details
   - Select "Gym Owner" role
   - Sign up

2. **Create Member Account**
   - Logout (if logged in)
   - Sign Up again
   - Select "Gym Member" role
   - Sign up

3. **Test Features**
   - Login as admin
   - Add members
   - Mark attendance
   - Record payments
   - Login as member
   - View dashboard
   - Check attendance
   - View diet plan

## 🔧 Troubleshooting

### Backend won't start
- Check MongoDB connection string
- Verify IP is whitelisted in MongoDB Atlas
- Check if port 5000 is available
- Check .env file exists and has correct values

### Flutter can't connect to backend
- Verify backend is running
- Check API base URL in `api_constants.dart`
- For Android emulator, use `10.0.2.2` instead of `localhost`
- For physical device, use computer's local IP address
- Check firewall settings

### MongoDB connection errors
- Verify connection string format
- Check username/password are correct
- Ensure IP is whitelisted (0.0.0.0/0 for development)
- Check cluster is running in MongoDB Atlas

### Build errors
```bash
# Flutter
flutter clean
flutter pub get

# Backend
rm -rf node_modules
npm install
```

## 📱 Testing on Different Platforms

### Android Emulator
- Use `http://10.0.2.2:5000/api` as base URL

### iOS Simulator
- Use `http://localhost:5000/api` as base URL

### Physical Device
1. Find your computer's IP address:
   ```bash
   # Windows
   ipconfig
   
   # Mac/Linux
   ifconfig
   ```
2. Use `http://YOUR_IP:5000/api` as base URL
3. Ensure device and computer are on same network

### Web
- Use `http://localhost:5000/api` as base URL
- Run: `flutter run -d chrome`

## ✅ Verification Checklist

- [ ] MongoDB Atlas cluster created
- [ ] Database user created
- [ ] IP whitelisted
- [ ] Connection string copied
- [ ] Backend .env file configured
- [ ] Backend server running
- [ ] Flutter dependencies installed
- [ ] API base URL updated
- [ ] App running successfully
- [ ] Can register/login
- [ ] Admin dashboard accessible
- [ ] User dashboard accessible

## 🎉 You're All Set!

Your Gym Automation System is now ready to use!

For detailed documentation, see:
- [Main README](README.md)
- [Backend README](backend/README.md)
- [Flutter README](flutter_app/README.md)

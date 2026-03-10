# ⚡ Quick Start - Running the Application

## Current Status
✅ Flutter dependencies installed
❌ Node.js not installed (needed for backend)

## Step 1: Install Node.js (Required for Backend)

1. **Download Node.js**
   - Go to: https://nodejs.org/
   - Download LTS version (recommended)
   - Run installer
   - Make sure to check "Add to PATH" during installation

2. **Verify Installation**
   ```powershell
   node --version
   npm --version
   ```

3. **Restart your terminal/IDE** after installation

## Step 2: Configure MongoDB Atlas

1. **Update Backend .env file**
   - File location: `backend\.env`
   - Update `MONGO_URI` with your MongoDB Atlas connection string
   - Update `JWT_SECRET` with a secure random string

## Step 3: Start Backend Server

```powershell
cd backend
npm install
npm run dev
```

Backend will run on: http://localhost:5000

## Step 4: Start Flutter App

**In a new terminal:**

```powershell
cd flutter_app
flutter run
```

Or for web:
```powershell
flutter run -d chrome
```

## Quick Commands Reference

### Backend
```powershell
cd backend
npm install          # Install dependencies (first time only)
npm run dev          # Start development server
npm start            # Start production server
```

### Flutter
```powershell
cd flutter_app
flutter pub get      # Install dependencies (already done ✅)
flutter run          # Run on connected device
flutter run -d chrome # Run on web browser
flutter devices      # List available devices
```

## Troubleshooting

### Node.js not found
- Install Node.js from https://nodejs.org/
- Restart terminal/IDE
- Verify with `node --version`

### MongoDB Connection Error
- Check `.env` file has correct `MONGO_URI`
- Verify MongoDB Atlas cluster is running
- Check IP whitelist in MongoDB Atlas

### Flutter API Connection Error
- Update `lib/core/constants/api_constants.dart`
- For Android emulator: use `http://10.0.2.2:5000/api`
- For physical device: use your computer's IP address

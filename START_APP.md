# 🚀 How to Run the Gym Automation App

## ⚠️ Current Status

✅ **Flutter App**: Starting in Chrome (will show connection errors until backend runs)
❌ **Backend Server**: Cannot start - Node.js not installed

## 📋 Step-by-Step Instructions

### Step 1: Install Node.js (REQUIRED)

1. **Download Node.js**
   - Visit: https://nodejs.org/
   - Download **LTS version** (recommended, e.g., v20.x.x)
   - Run the installer
   - ✅ **IMPORTANT**: Check "Add to PATH" during installation

2. **Verify Installation**
   - Close and reopen your terminal/IDE
   - Run these commands:
   ```powershell
   node --version    # Should show v20.x.x or similar
   npm --version     # Should show 10.x.x or similar
   ```

### Step 2: Configure MongoDB Connection

1. **Update `backend\.env` file**
   - Open `backend\.env`
   - Replace `<db_password>` with your actual MongoDB password
   - Update `MONGO_URI` to include database name:
   ```
   MONGO_URI=mongodb+srv://sreenathpalakkatt35_db_user:YOUR_PASSWORD@cluster0.w22fpwp.mongodb.net/gym?retryWrites=true&w=majority
   ```
   - Change `JWT_SECRET` to a secure random string (at least 32 characters)

### Step 3: Start Backend Server

**Open a NEW terminal window** and run:

```powershell
cd c:\Users\sreen\OneDrive\Desktop\gym2\backend
npm install
npm run dev
```

You should see:
```
MongoDB Connected: cluster0.xxxxx.mongodb.net
Server running in development mode on port 5000
```

✅ **Backend is now running on http://localhost:5000**

### Step 4: Verify Flutter App Connection

1. **Check Flutter App**
   - The app should already be running in Chrome
   - If not, run: `flutter run -d chrome` from `flutter_app` directory

2. **Test Connection**
   - Try to register/login
   - If you see connection errors, check:
     - Backend is running (Step 3)
     - API URL in `flutter_app/lib/core/constants/api_constants.dart` is `http://localhost:5000/api`

## 🎯 Quick Commands

### Backend (Terminal 1)
```powershell
cd backend
npm install      # First time only
npm run dev      # Start server
```

### Flutter App (Terminal 2)
```powershell
cd flutter_app
flutter run -d chrome
```

## 🔧 Troubleshooting

### "node is not recognized"
- **Solution**: Install Node.js from https://nodejs.org/
- Restart terminal/IDE after installation

### MongoDB Connection Error
- **Check**: `.env` file has correct password
- **Verify**: MongoDB Atlas cluster is running
- **Check**: IP whitelist allows connections (0.0.0.0/0 for development)

### Flutter Can't Connect to Backend
- **Check**: Backend is running (`npm run dev` in backend folder)
- **Verify**: API URL is `http://localhost:5000/api`
- **For Android Emulator**: Use `http://10.0.2.2:5000/api`
- **For Physical Device**: Use your computer's IP address

### Port 5000 Already in Use
- Change `PORT` in `backend\.env` to another port (e.g., 5001)
- Update Flutter API URL accordingly

## ✅ Success Checklist

- [ ] Node.js installed and verified
- [ ] MongoDB connection string configured in `.env`
- [ ] Backend server running (shows "Server running on port 5000")
- [ ] Flutter app running in browser
- [ ] Can register/login successfully
- [ ] No connection errors in browser console

## 📞 Need Help?

1. Check `SETUP_GUIDE.md` for detailed MongoDB setup
2. Check `README.md` for full documentation
3. Verify all prerequisites are installed

---

**Once Node.js is installed, you can run both backend and frontend!** 🚀

# 🔧 Fix MongoDB Connection

## ⚠️ Current Issue

The backend server started but crashed with:
```
Error: bad auth : authentication failed
```

## ✅ Solution: Update MongoDB Password

The `.env` file still has a placeholder password. You need to replace it with your actual MongoDB Atlas password.

### Steps:

1. **Open** `backend\.env` file

2. **Find this line:**
   ```
   MONGO_URI=mongodb+srv://sreenathpalakkatt35_db_user:<db_password>@cluster0.w22fpwp.mongodb.net/gym?retryWrites=true&w=majority
   ```

3. **Replace `<db_password>`** with your actual MongoDB password
   
   Example: If your password is `MySecurePass123`, change it to:
   ```
   MONGO_URI=mongodb+srv://sreenathpalakkatt35_db_user:MySecurePass123@cluster0.w22fpwp.mongodb.net/gym?retryWrites=true&w=majority
   ```

4. **Also update JWT_SECRET** (recommended):
   ```
   JWT_SECRET=your_random_secret_key_at_least_32_characters_long
   ```

5. **Save the file**

6. **The backend will automatically restart** (nodemon watches for file changes)

## ✅ Success Indicators

After updating the password, you should see:
```
MongoDB Connected: cluster0.xxxxx.mongodb.net
Server running in development mode on port 5000
```

## 🎯 What's Running Now

- ✅ **Backend**: Starting (will work after password update)
- ✅ **Flutter App**: Starting in Chrome
- ⚠️ **MongoDB**: Needs password in `.env` file

## 📝 Quick Fix

1. Edit `backend\.env`
2. Replace `<db_password>` with your MongoDB password
3. Save file
4. Backend will auto-restart
5. Refresh Flutter app in browser

---

**Once you update the MongoDB password, everything will work!** 🚀

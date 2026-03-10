# 🏋️‍♂️ Gym Automation System

A complete gym management system built with **Flutter** (Mobile + Web) and **Node.js + Express + MongoDB Atlas**.

## 🛠 Tech Stack

### Frontend
- **Flutter** - Cross-platform framework (Mobile + Web)
- **Provider** - State management
- **Dio** - HTTP client
- **SharedPreferences & SecureStorage** - Local storage

### Backend
- **Node.js** - Runtime environment
- **Express.js** - Web framework
- **MongoDB Atlas** - Cloud database
- **JWT** - Authentication
- **bcryptjs** - Password hashing

## 📁 Project Structure

```
gym2/
├── backend/              # Node.js + Express backend
│   ├── config/          # Database configuration
│   ├── controllers/     # Route controllers
│   ├── middleware/      # Auth & role middleware
│   ├── models/         # MongoDB schemas
│   ├── routes/         # API routes
│   ├── utils/          # Utility functions
│   ├── server.js       # Entry point
│   └── package.json    # Dependencies
│
└── flutter_app/        # Flutter frontend
    ├── lib/
    │   ├── core/       # Constants, services, utils
    │   ├── models/     # Data models
    │   ├── providers/   # State management
    │   ├── screens/    # UI screens
    │   └── main.dart   # Entry point
    └── pubspec.yaml    # Dependencies
```

## 🚀 Quick Start

### Prerequisites
- Node.js (v14+)
- Flutter SDK (v3.0+)
- MongoDB Atlas account
- Git

### Backend Setup

1. **Navigate to backend directory**
   ```bash
   cd backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure environment variables**
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` file:
   ```env
   MONGO_URI=mongodb+srv://username:password@cluster.mongodb.net/gym?retryWrites=true&w=majority
   JWT_SECRET=your_super_secret_jwt_key_change_this_in_production
   PORT=5000
   NODE_ENV=development
   ```

4. **Start the server**
   ```bash
   # Development mode
   npm run dev
   
   # Production mode
   npm start
   ```

   Server will run on `http://localhost:5000`

### Flutter App Setup

1. **Navigate to Flutter app directory**
   ```bash
   cd flutter_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Update API base URL**
   
   Edit `lib/core/constants/api_constants.dart`:
   ```dart
   static const String baseUrl = 'http://localhost:5000/api';
   // For production: 'https://your-backend-url.com/api'
   ```

4. **Run the app**
   ```bash
   # Mobile
   flutter run
   
   # Web
   flutter run -d chrome
   ```

## 🗄 MongoDB Atlas Setup

1. **Create MongoDB Atlas Account**
   - Go to [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
   - Sign up for free account

2. **Create a Cluster**
   - Choose free tier (M0)
   - Select region closest to you

3. **Create Database User**
   - Go to Database Access
   - Add new user with username and password
   - Save credentials

4. **Whitelist IP Address**
   - Go to Network Access
   - Add IP address (0.0.0.0/0 for development)

5. **Get Connection String**
   - Go to Clusters → Connect
   - Choose "Connect your application"
   - Copy connection string
   - Replace `<password>` with your database user password

## 🔐 Authentication Flow

1. **User Registration/Login**
   - User provides credentials
   - Backend validates and hashes password
   - JWT token generated and returned

2. **Token Storage**
   - Flutter stores token securely using SecureStorage
   - Token included in Authorization header for all requests

3. **Protected Routes**
   - Middleware verifies JWT token
   - Role-based access control (admin/user)

## 📱 Features

### Admin Panel
- ✅ Dashboard with statistics
- ✅ Member management (Add/Edit/Delete)
- ✅ Attendance tracking
- ✅ Payment management
- ✅ Reports generation

### User Panel
- ✅ Home dashboard
- ✅ Daily attendance status
- ✅ Payment history
- ✅ Workout videos
- ✅ Diet plan
- ✅ Profile management

## 🌍 Deployment

### Backend Deployment (Render/Railway)

#### Render
1. Create account on [Render](https://render.com)
2. Connect GitHub repository
3. Create new Web Service
4. Set environment variables
5. Deploy

#### Railway
1. Create account on [Railway](https://railway.app)
2. Create new project
3. Add MongoDB service
4. Deploy Node.js service
5. Set environment variables

### Flutter Web Deployment

1. **Build for web**
   ```bash
   flutter build web
   ```

2. **Deploy to Firebase Hosting**
   ```bash
   firebase init hosting
   firebase deploy
   ```

3. **Deploy to Vercel/Netlify**
   - Connect repository
   - Set build command: `flutter build web`
   - Set output directory: `build/web`

## 📚 API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `GET /api/auth/me` - Get current user

### Users (Admin)
- `GET /api/users` - Get all users
- `GET /api/users/:id` - Get user by ID
- `POST /api/users` - Create user
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user
- `GET /api/users/stats/dashboard` - Dashboard stats

### Attendance
- `POST /api/attendance` - Mark attendance
- `GET /api/attendance` - Get all attendance (Admin)
- `GET /api/attendance/user/:userId` - Get user attendance
- `GET /api/attendance/stats/:userId` - Get attendance stats

### Payments
- `POST /api/payments` - Create payment
- `GET /api/payments` - Get all payments
- `GET /api/payments/:id` - Get payment by ID
- `PUT /api/payments/:id` - Update payment (Admin)
- `DELETE /api/payments/:id` - Delete payment (Admin)
- `GET /api/payments/stats/:userId` - Get payment stats

### Diet Plans
- `GET /api/diet-plans/:userId` - Get diet plan
- `PUT /api/diet-plans/:userId` - Update diet plan (Admin)

### Workouts
- `GET /api/workouts` - Get all workouts
- `GET /api/workouts/:id` - Get workout by ID
- `POST /api/workouts` - Create workout (Admin)
- `PUT /api/workouts/:id` - Update workout (Admin)
- `DELETE /api/workouts/:id` - Delete workout (Admin)

## 🔒 Security Features

- ✅ JWT token-based authentication
- ✅ Password hashing with bcrypt
- ✅ Role-based access control
- ✅ Secure token storage
- ✅ Input validation
- ✅ CORS configuration
- ✅ Environment variables

## 📝 Environment Variables

### Backend (.env)
```env
MONGO_URI=mongodb+srv://username:password@cluster.mongodb.net/gym
JWT_SECRET=your_secret_key
PORT=5000
NODE_ENV=development
```

## 🐛 Troubleshooting

### Backend Issues
- **MongoDB connection failed**: Check MONGO_URI and network access
- **JWT errors**: Verify JWT_SECRET is set
- **Port already in use**: Change PORT in .env

### Flutter Issues
- **API connection failed**: Update baseUrl in api_constants.dart
- **Build errors**: Run `flutter pub get`
- **Token not persisting**: Check SecureStorage permissions

## 📄 License

This project is open source and available under the MIT License.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

## 📧 Support

For support, email your-email@example.com or create an issue in the repository.

---

**Built with ❤️ using Flutter & Node.js**

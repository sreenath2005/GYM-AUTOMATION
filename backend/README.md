# Gym Automation Backend

Node.js + Express + MongoDB Atlas backend for Gym Automation System.

## 🚀 Quick Start

### Installation

```bash
npm install
```

### Environment Setup

1. Copy `.env.example` to `.env`
2. Update the following variables:

```env
MONGO_URI=mongodb+srv://username:password@cluster.mongodb.net/gym
JWT_SECRET=your_super_secret_jwt_key
PORT=5000
NODE_ENV=development
```

### Run Server

```bash
# Development
npm run dev

# Production
npm start
```

## 📁 Project Structure

```
backend/
├── config/
│   └── db.js              # MongoDB connection
├── controllers/
│   ├── authController.js   # Authentication logic
│   ├── userController.js   # User management
│   ├── attendanceController.js
│   ├── paymentController.js
│   ├── dietPlanController.js
│   └── workoutController.js
├── middleware/
│   ├── authMiddleware.js   # JWT verification
│   └── roleMiddleware.js   # Role-based access
├── models/
│   ├── User.js
│   ├── Attendance.js
│   ├── Payment.js
│   ├── DietPlan.js
│   └── WorkoutAnimation.js
├── routes/
│   ├── authRoutes.js
│   ├── userRoutes.js
│   ├── attendanceRoutes.js
│   ├── paymentRoutes.js
│   ├── dietPlanRoutes.js
│   └── workoutRoutes.js
├── utils/
│   └── generateToken.js
├── server.js              # Entry point
└── package.json
```

## 🔐 Authentication

### Register
```bash
POST /api/auth/register
Body: {
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "1234567890",
  "password": "password123",
  "role": "user" // or "admin"
}
```

### Login
```bash
POST /api/auth/login
Body: {
  "email": "john@example.com",
  "password": "password123"
}
```

Response includes JWT token in `data.token`

## 📡 API Endpoints

### Authentication
- `POST /api/auth/register` - Register user
- `POST /api/auth/login` - Login user
- `GET /api/auth/me` - Get current user (Protected)

### Users
- `GET /api/users` - Get all users (Admin)
- `GET /api/users/:id` - Get user by ID (Protected)
- `POST /api/users` - Create user (Admin)
- `PUT /api/users/:id` - Update user (Protected)
- `DELETE /api/users/:id` - Delete user (Admin)
- `GET /api/users/stats/dashboard` - Dashboard stats (Admin)

### Attendance
- `POST /api/attendance` - Mark attendance (Protected)
- `GET /api/attendance` - Get all attendance (Admin)
- `GET /api/attendance/user/:userId` - Get user attendance (Protected)
- `GET /api/attendance/stats/:userId` - Get attendance stats (Protected)

### Payments
- `POST /api/payments` - Create payment (Protected)
- `GET /api/payments` - Get payments (Protected)
- `GET /api/payments/:id` - Get payment by ID (Protected)
- `PUT /api/payments/:id` - Update payment (Admin)
- `DELETE /api/payments/:id` - Delete payment (Admin)
- `GET /api/payments/stats/:userId` - Get payment stats (Protected)

### Diet Plans
- `GET /api/diet-plans/:userId` - Get diet plan (Protected)
- `PUT /api/diet-plans/:userId` - Update diet plan (Admin)

### Workouts
- `GET /api/workouts` - Get all workouts (Protected)
- `GET /api/workouts/:id` - Get workout by ID (Protected)
- `POST /api/workouts` - Create workout (Admin)
- `PUT /api/workouts/:id` - Update workout (Admin)
- `DELETE /api/workouts/:id` - Delete workout (Admin)

## 🔒 Security

- JWT token authentication
- Password hashing with bcrypt
- Role-based access control (admin/user)
- Input validation
- CORS enabled

## 🗄 Database Models

### User
- name, email, phone, password (hashed)
- role (admin/user)
- membershipType, profileImage

### Attendance
- userId, date, status (present/absent)

### Payment
- userId, amount, status (paid/pending)
- date, method (cash/upi/card)

### DietPlan
- userId, planDetails, updatedAt

### WorkoutAnimation
- title, description, videoUrl, category

## 🚢 Deployment

### Render
1. Connect GitHub repository
2. Create new Web Service
3. Set environment variables
4. Deploy

### Railway
1. Create new project
2. Add MongoDB service
3. Deploy Node.js service
4. Set environment variables

## 📝 Notes

- All protected routes require `Authorization: Bearer <token>` header
- Admin routes require user role to be 'admin'
- Passwords are automatically hashed before saving
- JWT tokens expire in 30 days

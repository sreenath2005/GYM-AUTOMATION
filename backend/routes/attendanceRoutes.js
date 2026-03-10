const express = require('express');
const router = express.Router();
const {
  markAttendance,
  getUserAttendance,
  getAllAttendance,
  getAttendanceStats,
} = require('../controllers/attendanceController');
const { protect } = require('../middleware/authMiddleware');
const { authorize } = require('../middleware/roleMiddleware');

router.post('/', protect, markAttendance);
router.get('/stats/:userId?', protect, getAttendanceStats);
router.get('/user/:userId', protect, getUserAttendance);
router.get('/', protect, authorize('admin'), getAllAttendance);

module.exports = router;

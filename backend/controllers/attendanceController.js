const Attendance = require('../models/Attendance');
const User = require('../models/User');

// @desc    Mark attendance
// @route   POST /api/attendance
// @access  Private
exports.markAttendance = async (req, res) => {
  try {
    const { userId, date, status } = req.body;
    const attendanceUserId = userId || req.user.id;

    // Check if user is admin or marking their own attendance
    if (req.user.role !== 'admin' && attendanceUserId !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to mark attendance for this user',
      });
    }

    const attendanceDate = date ? new Date(date) : new Date();
    attendanceDate.setHours(0, 0, 0, 0);

    // Check if attendance already marked for this date
    const existingAttendance = await Attendance.findOne({
      userId: attendanceUserId,
      date: attendanceDate,
    });

    if (existingAttendance) {
      // Update existing attendance
      existingAttendance.status = status || 'present';
      const updatedAttendance = await existingAttendance.save();

      return res.status(200).json({
        success: true,
        data: updatedAttendance,
      });
    }

    // Create new attendance
    const attendance = await Attendance.create({
      userId: attendanceUserId,
      date: attendanceDate,
      status: status || 'present',
    });

    res.status(201).json({
      success: true,
      data: attendance,
    });
  } catch (error) {
    if (error.code === 11000) {
      return res.status(400).json({
        success: false,
        message: 'Attendance already marked for this date',
      });
    }
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get attendance for a user
// @route   GET /api/attendance/user/:userId
// @access  Private
exports.getUserAttendance = async (req, res) => {
  try {
    const { userId } = req.params;
    const { startDate, endDate } = req.query;

    // Check if user is admin or viewing their own attendance
    if (req.user.role !== 'admin' && userId !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to view this attendance',
      });
    }

    let query = { userId };

    if (startDate && endDate) {
      const start = new Date(startDate);
      start.setHours(0, 0, 0, 0);
      const end = new Date(endDate);
      end.setHours(23, 59, 59, 999);
      query.date = { $gte: start, $lte: end };
    }

    const attendance = await Attendance.find(query)
      .populate('userId', 'name email')
      .sort({ date: -1 });

    res.status(200).json({
      success: true,
      count: attendance.length,
      data: attendance,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get all attendance (admin only)
// @route   GET /api/attendance
// @access  Private/Admin
exports.getAllAttendance = async (req, res) => {
  try {
    const { date } = req.query;
    let query = {};

    if (date) {
      const attendanceDate = new Date(date);
      attendanceDate.setHours(0, 0, 0, 0);
      const nextDay = new Date(attendanceDate);
      nextDay.setDate(nextDay.getDate() + 1);
      query.date = { $gte: attendanceDate, $lt: nextDay };
    }

    const attendance = await Attendance.find(query)
      .populate('userId', 'name email phone membershipType')
      .sort({ date: -1 });

    res.status(200).json({
      success: true,
      count: attendance.length,
      data: attendance,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get attendance stats
// @route   GET /api/attendance/stats/:userId
// @access  Private
exports.getAttendanceStats = async (req, res) => {
  try {
    const { userId } = req.params;
    const viewUserId = userId || req.user.id;

    // Check if user is admin or viewing their own stats
    if (req.user.role !== 'admin' && viewUserId !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to view this stats',
      });
    }

    // Get current month stats
    const currentMonth = new Date();
    currentMonth.setDate(1);
    currentMonth.setHours(0, 0, 0, 0);

    const presentCount = await Attendance.countDocuments({
      userId: viewUserId,
      date: { $gte: currentMonth },
      status: 'present',
    });

    const totalDays = new Date().getDate(); // Days passed in current month
    const attendancePercentage = totalDays > 0 ? ((presentCount / totalDays) * 100).toFixed(2) : 0;

    // Check today's attendance
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const todayAttendance = await Attendance.findOne({
      userId: viewUserId,
      date: { $gte: today, $lt: tomorrow },
    });

    res.status(200).json({
      success: true,
      data: {
        presentCount,
        totalDays,
        attendancePercentage: parseFloat(attendancePercentage),
        todayStatus: todayAttendance ? todayAttendance.status : 'not_marked',
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

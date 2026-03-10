const express = require('express');
const router = express.Router();
const {
  getUsers,
  getUser,
  createUser,
  updateUser,
  deleteUser,
  getDashboardStats,
} = require('../controllers/userController');
const { protect } = require('../middleware/authMiddleware');
const { authorize } = require('../middleware/roleMiddleware');

router.get('/stats/dashboard', protect, authorize('admin'), getDashboardStats);
router.route('/').get(protect, authorize('admin'), getUsers).post(protect, authorize('admin'), createUser);
router.route('/:id').get(protect, getUser).put(protect, updateUser).delete(protect, authorize('admin'), deleteUser);

module.exports = router;

const express = require('express');
const router = express.Router();
const {
  getWorkouts,
  getWorkout,
  createWorkout,
  updateWorkout,
  deleteWorkout,
  seedWorkouts,
} = require('../controllers/workoutController');
const { protect } = require('../middleware/authMiddleware');
const { authorize } = require('../middleware/roleMiddleware');

router.post('/seed', protect, authorize('admin'), seedWorkouts);
router.get('/', protect, getWorkouts);
router.get('/:id', protect, getWorkout);
router.post('/', protect, authorize('admin'), createWorkout);
router.put('/:id', protect, authorize('admin'), updateWorkout);
router.delete('/:id', protect, authorize('admin'), deleteWorkout);

module.exports = router;

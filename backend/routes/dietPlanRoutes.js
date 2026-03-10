const express = require('express');
const router = express.Router();
const {
  getDietPlan,
  updateDietPlan,
} = require('../controllers/dietPlanController');
const { protect } = require('../middleware/authMiddleware');

router.get('/:userId?', protect, getDietPlan);
router.put('/:userId?', protect, updateDietPlan);

module.exports = router;

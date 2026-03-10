const DietPlan = require('../models/DietPlan');

// @desc    Get or create diet plan for user
// @route   GET /api/diet-plans/:userId
// @access  Private
exports.getDietPlan = async (req, res) => {
  try {
    const { userId } = req.params;
    const viewUserId = userId || req.user.id;

    // Check if user is admin or viewing their own diet plan
    if (req.user.role !== 'admin' && viewUserId !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to view this diet plan',
      });
    }

    let dietPlan = await DietPlan.findOne({ userId: viewUserId });

    if (!dietPlan) {
      // Create empty diet plan if doesn't exist
      dietPlan = await DietPlan.create({
        userId: viewUserId,
        planDetails: 'No diet plan assigned yet. Please contact admin.',
      });
    }

    res.status(200).json({
      success: true,
      data: dietPlan,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Create or update diet plan
// @route   PUT /api/diet-plans/:userId
// @access  Private
exports.updateDietPlan = async (req, res) => {
  try {
    const { userId } = req.params;
    const { planDetails } = req.body;
    const updateUserId = userId || req.user.id;

    // Only admin can update diet plans
    if (req.user.role !== 'admin' && updateUserId !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to update this diet plan',
      });
    }

    // Only admin can actually update diet plan content
    if (req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Only admin can update diet plan details',
      });
    }

    let dietPlan = await DietPlan.findOne({ userId: updateUserId });

    if (dietPlan) {
      dietPlan.planDetails = planDetails;
      dietPlan.updatedAt = new Date();
      await dietPlan.save();
    } else {
      dietPlan = await DietPlan.create({
        userId: updateUserId,
        planDetails,
      });
    }

    res.status(200).json({
      success: true,
      data: dietPlan,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

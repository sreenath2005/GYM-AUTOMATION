const mongoose = require('mongoose');

const dietPlanSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true,
  },
  planDetails: {
    type: String,
    required: [true, 'Please add diet plan details'],
  },
  updatedAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('DietPlan', dietPlanSchema);

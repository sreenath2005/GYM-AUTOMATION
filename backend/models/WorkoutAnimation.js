const mongoose = require('mongoose');

const workoutAnimationSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Please add a title'],
    trim: true,
  },
  description: {
    type: String,
    default: '',
  },
  videoUrl: {
    type: String,
    default: '',
  },
  category: {
    type: String,
    required: [true, 'Please add a category'],
    enum: ['Chest', 'Back', 'Shoulders', 'Arms', 'Legs', 'Cardio', 'Abs', 'Full Body'],
  },
  type: {
    type: String,
    enum: ['exercise', 'game', 'challenge'],
    default: 'exercise',
  },
  difficulty: {
    type: String,
    enum: ['Beginner', 'Intermediate', 'Advanced'],
    default: 'Beginner',
  },
  duration: {
    type: String,
    default: '',
  },
  targetReps: {
    type: String,
    default: '',
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('WorkoutAnimation', workoutAnimationSchema);

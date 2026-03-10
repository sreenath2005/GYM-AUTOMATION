const WorkoutAnimation = require('../models/WorkoutAnimation');

// @desc    Get all workout animations
// @route   GET /api/workouts
// @access  Private
exports.getWorkouts = async (req, res) => {
  try {
    const { category } = req.query;
    let query = {};
    if (category) query.category = category;
    const workouts = await WorkoutAnimation.find(query).sort({ category: 1, createdAt: -1 });
    res.status(200).json({ success: true, count: workouts.length, data: workouts });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Get single workout
// @route   GET /api/workouts/:id
// @access  Private
exports.getWorkout = async (req, res) => {
  try {
    const workout = await WorkoutAnimation.findById(req.params.id);
    if (!workout) return res.status(404).json({ success: false, message: 'Workout not found' });
    res.status(200).json({ success: true, data: workout });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Create workout (admin only)
// @route   POST /api/workouts
// @access  Private/Admin
exports.createWorkout = async (req, res) => {
  try {
    const { title, description, videoUrl, category, type, difficulty, duration, targetReps } = req.body;
    const workout = await WorkoutAnimation.create({
      title,
      description,
      videoUrl: videoUrl || '',
      category,
      type: type || 'exercise',
      difficulty: difficulty || 'Beginner',
      duration: duration || '',
      targetReps: targetReps || '',
    });
    res.status(201).json({ success: true, data: workout });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Update workout (admin only)
// @route   PUT /api/workouts/:id
// @access  Private/Admin
exports.updateWorkout = async (req, res) => {
  try {
    const { title, description, videoUrl, category, type, difficulty, duration, targetReps } = req.body;
    const workout = await WorkoutAnimation.findById(req.params.id);
    if (!workout) return res.status(404).json({ success: false, message: 'Workout not found' });
    workout.title = title || workout.title;
    workout.description = description !== undefined ? description : workout.description;
    workout.videoUrl = videoUrl !== undefined ? videoUrl : workout.videoUrl;
    workout.category = category || workout.category;
    workout.type = type || workout.type;
    workout.difficulty = difficulty || workout.difficulty;
    workout.duration = duration !== undefined ? duration : workout.duration;
    workout.targetReps = targetReps !== undefined ? targetReps : workout.targetReps;
    const updated = await workout.save();
    res.status(200).json({ success: true, data: updated });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Delete workout (admin only)
// @route   DELETE /api/workouts/:id
// @access  Private/Admin
exports.deleteWorkout = async (req, res) => {
  try {
    const workout = await WorkoutAnimation.findById(req.params.id);
    if (!workout) return res.status(404).json({ success: false, message: 'Workout not found' });
    await workout.deleteOne();
    res.status(200).json({ success: true, message: 'Workout deleted successfully' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Seed all gym game challenges
// @route   POST /api/workouts/seed
// @access  Private/Admin
exports.seedWorkouts = async (req, res) => {
  try {
    const gymGames = [
      // Chest
      { title: 'Push-Up Competition', description: 'Maximum push-up reps in 1 minute. Compete with other members!', category: 'Chest', type: 'game', difficulty: 'Beginner', duration: '1 min', targetReps: 'Max reps' },
      { title: 'Bench Press Max Weight', description: 'Find your 1-rep max on the bench press. Track and beat your record.', category: 'Chest', type: 'challenge', difficulty: 'Advanced', duration: '20 min', targetReps: '1 RM' },
      { title: 'Medicine Ball Chest Pass Distance', description: 'Throw a medicine ball as far as possible from chest height.', category: 'Chest', type: 'game', difficulty: 'Intermediate', duration: '10 min', targetReps: 'Max distance' },
      { title: 'Clap Push-Up Challenge', description: 'Consecutive clap push-ups — test your explosive chest power.', category: 'Chest', type: 'challenge', difficulty: 'Advanced', duration: '5 min', targetReps: 'Max reps' },
      { title: 'Resistance Band Chest Endurance', description: 'How long can you keep pressing? Chest endurance challenge with resistance bands.', category: 'Chest', type: 'game', difficulty: 'Beginner', duration: '5 min', targetReps: 'Max time' },
      // Back
      { title: 'Pull-Up Challenge', description: 'Maximum pull-up reps without stopping. Classic back strength test.', category: 'Back', type: 'challenge', difficulty: 'Intermediate', duration: '5 min', targetReps: 'Max reps' },
      { title: 'Deadlift Competition', description: 'Find your 1-rep max deadlift. The king of all back exercises.', category: 'Back', type: 'game', difficulty: 'Advanced', duration: '30 min', targetReps: '1 RM' },
      { title: 'Rowing Machine 500m Race', description: 'Race to complete 500m on the rowing machine as fast as possible.', category: 'Back', type: 'game', difficulty: 'Intermediate', duration: '2-3 min', targetReps: '500m' },
      { title: 'Lat Pulldown Strength Test', description: 'How much can you pull? Progressive lat pulldown strength test.', category: 'Back', type: 'challenge', difficulty: 'Intermediate', duration: '15 min', targetReps: 'Max weight' },
      { title: 'Superman Hold Challenge', description: 'Lie face down and hold the Superman position as long as you can.', category: 'Back', type: 'challenge', difficulty: 'Beginner', duration: '5 min', targetReps: 'Max hold time' },
      // Legs
      { title: 'Squat Challenge', description: 'Maximum squat reps in 1 minute. Deep squats only!', category: 'Legs', type: 'game', difficulty: 'Beginner', duration: '1 min', targetReps: 'Max reps' },
      { title: 'Wall Sit Longest Hold', description: 'Sit against the wall at 90 degrees. Who holds the longest wins!', category: 'Legs', type: 'game', difficulty: 'Intermediate', duration: '5 min', targetReps: 'Max time' },
      { title: 'Walking Lunges Race', description: 'Race across the gym floor using walking lunges. Fastest wins!', category: 'Legs', type: 'game', difficulty: 'Beginner', duration: '5 min', targetReps: '20m race' },
      { title: 'Leg Press Weight Challenge', description: 'Stack as much as you can on the leg press for a single rep.', category: 'Legs', type: 'challenge', difficulty: 'Advanced', duration: '20 min', targetReps: '1 RM' },
      { title: 'Box Jump Height Challenge', description: 'Jump onto increasingly higher boxes. Test your explosive leg power.', category: 'Legs', type: 'challenge', difficulty: 'Advanced', duration: '15 min', targetReps: 'Max height' },
      // Arms
      { title: 'Bicep Curl Max Reps', description: 'Max bicep curl reps at a fixed weight. Burn those arms!', category: 'Arms', type: 'challenge', difficulty: 'Beginner', duration: '5 min', targetReps: 'Max reps' },
      { title: 'Tricep Dips Challenge', description: 'Maximum parallel bar dips without stopping. Tricep destroyer!', category: 'Arms', type: 'challenge', difficulty: 'Intermediate', duration: '5 min', targetReps: 'Max reps' },
      { title: 'Arm Wrestling Competition', description: 'Classic arm wrestling tournament. Men\'s & Women\'s categories.', category: 'Arms', type: 'game', difficulty: 'Intermediate', duration: '30 min', targetReps: 'Tournament' },
      { title: 'Battle Rope Arm Endurance', description: 'Keep the battle ropes waving for as long as possible!', category: 'Arms', type: 'game', difficulty: 'Advanced', duration: '5 min', targetReps: 'Max time' },
      { title: 'Dumbbell Static Hold Challenge', description: 'Hold dumbbells at 90° arm angle as long as possible. Grip & endurance test.', category: 'Arms', type: 'challenge', difficulty: 'Beginner', duration: '5 min', targetReps: 'Max hold time' },
      // Shoulders
      { title: 'Shoulder Press Max Weight', description: 'Find your overhead press 1-rep max. The ultimate shoulder test.', category: 'Shoulders', type: 'challenge', difficulty: 'Advanced', duration: '20 min', targetReps: '1 RM' },
      { title: 'Lateral Raise Endurance', description: 'How many lateral raises can you do at a fixed light weight?', category: 'Shoulders', type: 'challenge', difficulty: 'Beginner', duration: '5 min', targetReps: 'Max reps' },
      { title: 'Plate Hold Time Challenge', description: 'Hold a weight plate with arms extended in front. Max time wins!', category: 'Shoulders', type: 'game', difficulty: 'Intermediate', duration: '5 min', targetReps: 'Max time' },
      { title: 'Wall Handstand Hold', description: 'Handstand against the wall — hold as long as you can.', category: 'Shoulders', type: 'challenge', difficulty: 'Advanced', duration: '5 min', targetReps: 'Max hold time' },
      { title: 'Front Raise Competition', description: 'Max front raises with dumbbells at a fixed weight.', category: 'Shoulders', type: 'game', difficulty: 'Beginner', duration: '5 min', targetReps: 'Max reps' },
      // Abs
      { title: 'Plank Longest Hold', description: 'Hold the plank position as long as possible. Core iron challenge!', category: 'Abs', type: 'challenge', difficulty: 'Intermediate', duration: 'Open', targetReps: 'Max time' },
      { title: 'Sit-Up 1-Minute Challenge', description: 'Maximum sit-ups in exactly 1 minute. Full range of motion only!', category: 'Abs', type: 'game', difficulty: 'Beginner', duration: '1 min', targetReps: 'Max reps' },
      { title: 'Russian Twist Speed Round', description: 'Speed Russian twists with a medicine ball — most reps in 30 sec wins!', category: 'Abs', type: 'game', difficulty: 'Intermediate', duration: '30 sec', targetReps: 'Max reps' },
      { title: 'Hanging Leg Raise Competition', description: 'Max hanging leg raises on the pull-up bar. No swinging allowed!', category: 'Abs', type: 'challenge', difficulty: 'Advanced', duration: '5 min', targetReps: 'Max reps' },
      { title: 'Mountain Climbers Challenge', description: 'Max mountain climbers in 1 minute. Speed and form count!', category: 'Abs', type: 'game', difficulty: 'Beginner', duration: '1 min', targetReps: 'Max reps' },
      // Full Body
      { title: 'Burpee 2-Minute Challenge', description: 'Max burpees in 2 minutes. The ultimate full-body torture test!', category: 'Full Body', type: 'challenge', difficulty: 'Advanced', duration: '2 min', targetReps: 'Max reps' },
      { title: 'CrossFit Circuit Race', description: 'Complete: 10 pull-ups, 20 push-ups, 30 squats, 40 sit-ups — fastest time wins!', category: 'Full Body', type: 'game', difficulty: 'Advanced', duration: '15-20 min', targetReps: 'Fastest time' },
      { title: 'Fitness Obstacle Course', description: 'Navigate through gym equipment obstacle challenges. Fun for all levels!', category: 'Full Body', type: 'game', difficulty: 'Intermediate', duration: '20 min', targetReps: 'Fastest time' },
      { title: 'Tug of War', description: 'Team tug of war competition. Pure strength and teamwork event!', category: 'Full Body', type: 'game', difficulty: 'Beginner', duration: '30 min', targetReps: 'Tournament' },
      { title: 'Team Relay Race', description: 'Teams complete relay rounds with different exercises at each station.', category: 'Full Body', type: 'game', difficulty: 'Intermediate', duration: '30 min', targetReps: 'Fastest team' },
    ];

    await WorkoutAnimation.deleteMany({});
    const inserted = await WorkoutAnimation.insertMany(gymGames);
    res.status(201).json({ success: true, count: inserted.length, message: `Seeded ${inserted.length} gym game challenges!` });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// Quick seed script — runs directly without HTTP auth
require('dotenv').config();
const mongoose = require('mongoose');
const WorkoutAnimation = require('./models/WorkoutAnimation');

const gymGames = [
    { title: 'Push-Up Competition', description: 'Maximum push-up reps in 1 minute. Compete with other members!', category: 'Chest', type: 'game', difficulty: 'Beginner', duration: '1 min', targetReps: 'Max reps' },
    { title: 'Bench Press Max Weight', description: 'Find your 1-rep max on the bench press.', category: 'Chest', type: 'challenge', difficulty: 'Advanced', duration: '20 min', targetReps: '1 RM' },
    { title: 'Medicine Ball Chest Pass', description: 'Throw a medicine ball as far as possible from chest height.', category: 'Chest', type: 'game', difficulty: 'Intermediate', duration: '10 min', targetReps: 'Max distance' },
    { title: 'Clap Push-Up Challenge', description: 'Consecutive clap push-ups — test your explosive chest power.', category: 'Chest', type: 'challenge', difficulty: 'Advanced', duration: '5 min', targetReps: 'Max reps' },
    { title: 'Resistance Band Chest Endurance', description: 'How long can you keep pressing with resistance bands?', category: 'Chest', type: 'game', difficulty: 'Beginner', duration: '5 min', targetReps: 'Max time' },
    { title: 'Pull-Up Challenge', description: 'Maximum pull-up reps without stopping.', category: 'Back', type: 'challenge', difficulty: 'Intermediate', duration: '5 min', targetReps: 'Max reps' },
    { title: 'Deadlift Competition', description: 'Find your 1-rep max deadlift.', category: 'Back', type: 'game', difficulty: 'Advanced', duration: '30 min', targetReps: '1 RM' },
    { title: 'Rowing Machine 500m Race', description: 'Race to complete 500m on the rowing machine.', category: 'Back', type: 'game', difficulty: 'Intermediate', duration: '2-3 min', targetReps: '500m' },
    { title: 'Lat Pulldown Strength Test', description: 'Progressive lat pulldown strength test.', category: 'Back', type: 'challenge', difficulty: 'Intermediate', duration: '15 min', targetReps: 'Max weight' },
    { title: 'Superman Hold Challenge', description: 'Hold the Superman position as long as you can.', category: 'Back', type: 'challenge', difficulty: 'Beginner', duration: '5 min', targetReps: 'Max hold time' },
    { title: 'Squat Challenge', description: 'Maximum squat reps in 1 minute. Deep squats only!', category: 'Legs', type: 'game', difficulty: 'Beginner', duration: '1 min', targetReps: 'Max reps' },
    { title: 'Wall Sit Longest Hold', description: 'Sit against the wall at 90 degrees. Who holds the longest wins!', category: 'Legs', type: 'game', difficulty: 'Intermediate', duration: '5 min', targetReps: 'Max time' },
    { title: 'Walking Lunges Race', description: 'Race across the gym floor using walking lunges.', category: 'Legs', type: 'game', difficulty: 'Beginner', duration: '5 min', targetReps: '20m race' },
    { title: 'Leg Press Weight Challenge', description: 'Stack as much as you can on the leg press for a single rep.', category: 'Legs', type: 'challenge', difficulty: 'Advanced', duration: '20 min', targetReps: '1 RM' },
    { title: 'Box Jump Height Challenge', description: 'Jump onto increasingly higher boxes. Explosive leg power test.', category: 'Legs', type: 'challenge', difficulty: 'Advanced', duration: '15 min', targetReps: 'Max height' },
    { title: 'Bicep Curl Max Reps', description: 'Max bicep curl reps at a fixed weight.', category: 'Arms', type: 'challenge', difficulty: 'Beginner', duration: '5 min', targetReps: 'Max reps' },
    { title: 'Tricep Dips Challenge', description: 'Maximum parallel bar dips without stopping.', category: 'Arms', type: 'challenge', difficulty: 'Intermediate', duration: '5 min', targetReps: 'Max reps' },
    { title: 'Arm Wrestling Competition', description: 'Classic arm wrestling tournament.', category: 'Arms', type: 'game', difficulty: 'Intermediate', duration: '30 min', targetReps: 'Tournament' },
    { title: 'Battle Rope Arm Endurance', description: 'Keep the battle ropes waving for as long as possible!', category: 'Arms', type: 'game', difficulty: 'Advanced', duration: '5 min', targetReps: 'Max time' },
    { title: 'Dumbbell Static Hold Challenge', description: 'Hold dumbbells at 90° arm angle as long as possible.', category: 'Arms', type: 'challenge', difficulty: 'Beginner', duration: '5 min', targetReps: 'Max hold time' },
    { title: 'Shoulder Press Max Weight', description: 'Find your overhead press 1-rep max.', category: 'Shoulders', type: 'challenge', difficulty: 'Advanced', duration: '20 min', targetReps: '1 RM' },
    { title: 'Lateral Raise Endurance', description: 'How many lateral raises can you do at a fixed light weight?', category: 'Shoulders', type: 'challenge', difficulty: 'Beginner', duration: '5 min', targetReps: 'Max reps' },
    { title: 'Plate Hold Time Challenge', description: 'Hold a weight plate with arms extended in front. Max time wins!', category: 'Shoulders', type: 'game', difficulty: 'Intermediate', duration: '5 min', targetReps: 'Max time' },
    { title: 'Wall Handstand Hold', description: 'Handstand against the wall — hold as long as you can.', category: 'Shoulders', type: 'challenge', difficulty: 'Advanced', duration: '5 min', targetReps: 'Max hold time' },
    { title: 'Front Raise Competition', description: 'Max front raises with dumbbells at a fixed weight.', category: 'Shoulders', type: 'game', difficulty: 'Beginner', duration: '5 min', targetReps: 'Max reps' },
    { title: 'Plank Longest Hold', description: 'Hold the plank position as long as possible. Core iron challenge!', category: 'Abs', type: 'challenge', difficulty: 'Intermediate', duration: 'Open', targetReps: 'Max time' },
    { title: 'Sit-Up 1-Minute Challenge', description: 'Maximum sit-ups in exactly 1 minute.', category: 'Abs', type: 'game', difficulty: 'Beginner', duration: '1 min', targetReps: 'Max reps' },
    { title: 'Russian Twist Speed Round', description: 'Speed Russian twists with a medicine ball — most reps in 30 sec wins!', category: 'Abs', type: 'game', difficulty: 'Intermediate', duration: '30 sec', targetReps: 'Max reps' },
    { title: 'Hanging Leg Raise Competition', description: 'Max hanging leg raises on the pull-up bar.', category: 'Abs', type: 'challenge', difficulty: 'Advanced', duration: '5 min', targetReps: 'Max reps' },
    { title: 'Mountain Climbers Challenge', description: 'Max mountain climbers in 1 minute. Speed and form count!', category: 'Abs', type: 'game', difficulty: 'Beginner', duration: '1 min', targetReps: 'Max reps' },
    { title: 'Burpee 2-Minute Challenge', description: 'Max burpees in 2 minutes. The ultimate full-body torture test!', category: 'Full Body', type: 'challenge', difficulty: 'Advanced', duration: '2 min', targetReps: 'Max reps' },
    { title: 'CrossFit Circuit Race', description: 'Complete: 10 pull-ups, 20 push-ups, 30 squats, 40 sit-ups — fastest wins!', category: 'Full Body', type: 'game', difficulty: 'Advanced', duration: '15-20 min', targetReps: 'Fastest time' },
    { title: 'Fitness Obstacle Course', description: 'Navigate through gym equipment obstacle challenges.', category: 'Full Body', type: 'game', difficulty: 'Intermediate', duration: '20 min', targetReps: 'Fastest time' },
    { title: 'Tug of War', description: 'Team tug of war competition. Pure strength and teamwork event!', category: 'Full Body', type: 'game', difficulty: 'Beginner', duration: '30 min', targetReps: 'Tournament' },
    { title: 'Team Relay Race', description: 'Teams complete relay rounds with different exercises at each station.', category: 'Full Body', type: 'game', difficulty: 'Intermediate', duration: '30 min', targetReps: 'Fastest team' },
];

async function seed() {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('✅ MongoDB Connected');
    await WorkoutAnimation.deleteMany({});
    const result = await WorkoutAnimation.insertMany(gymGames);
    console.log(`🎉 Seeded ${result.length} gym game challenges!`);
    await mongoose.disconnect();
}

seed().catch(e => { console.error('❌', e.message); process.exit(1); });

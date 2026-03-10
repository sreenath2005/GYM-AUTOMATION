require('dotenv').config();
const mongoose = require('mongoose');
const User = require('./models/User');

const ADMIN = {
    name: 'Gym Owner',
    email: 'gymowner@gym.com',
    phone: '9999999999',
    password: 'GymOwner@123',
    role: 'admin',
};

async function createAdmin() {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('✅ MongoDB Connected');

    const existing = await User.findOne({ email: ADMIN.email });
    if (existing) {
        console.log('⚠️  Admin account already exists. No changes made.');
        await mongoose.disconnect();
        return;
    }

    await User.create(ADMIN);
    console.log('\n🎉 Gym Owner account created successfully!');
    console.log('──────────────────────────────────');
    console.log(`  Email    : ${ADMIN.email}`);
    console.log(`  Password : ${ADMIN.password}`);
    console.log(`  Role     : ${ADMIN.role}`);
    console.log('──────────────────────────────────\n');

    await mongoose.disconnect();
}

createAdmin().catch((err) => {
    console.error('❌ Error:', err.message);
    process.exit(1);
});

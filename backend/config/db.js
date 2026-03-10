const mongoose = require('mongoose');
const dns = require('dns');

// Force Google DNS to bypass system DNS that blocks MongoDB Atlas SRV records
dns.setServers(['8.8.8.8', '8.8.4.4', '1.1.1.1']);

let isConnecting = false;
let reconnectTimeout = null;

const connectDB = async (retries = 5, delay = 5000) => {
  // Prevent multiple simultaneous connection attempts
  if (isConnecting) {
    return;
  }

  // Check if MONGO_URI exists
  if (!process.env.MONGO_URI) {
    console.error('MONGO_URI is not defined in .env file');
    console.error('Server will continue running but database operations will fail.');
    return;
  }

  // Check if already connected
  if (mongoose.connection.readyState === 1) {
    console.log('MongoDB already connected');
    return;
  }

  isConnecting = true;

  for (let i = 0; i < retries; i++) {
    try {
      const conn = await mongoose.connect(process.env.MONGO_URI, {
        serverSelectionTimeoutMS: 10000, // Timeout after 10s instead of 30s
        socketTimeoutMS: 45000, // Close sockets after 45s of inactivity
      });

      console.log(`MongoDB Connected: ${conn.connection.host}`);
      isConnecting = false;
      return;
    } catch (error) {
      console.error(`MongoDB Connection Error (Attempt ${i + 1}/${retries}): ${error.message}`);

      if (i === retries - 1) {
        console.error('\n=== MongoDB Connection Failed ===');
        console.error('Please check:');
        console.error('1. Your internet connection');
        console.error('2. MongoDB Atlas IP whitelist (should allow all IPs: 0.0.0.0/0)');
        console.error('3. MongoDB Atlas cluster is running (not paused)');
        console.error('4. Connection string is correct in .env file');
        console.error('\nServer will continue running but database operations will fail.');
        console.error('The server will retry connection automatically.\n');
        isConnecting = false;
        // Don't exit - let the server start and retry in background
        return;
      }

      console.log(`Retrying in ${delay / 1000} seconds...`);
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }

  isConnecting = false;
};

// Handle connection events
mongoose.connection.on('error', (err) => {
  console.error('MongoDB connection error:', err.message);
});

mongoose.connection.on('disconnected', () => {
  // Only reconnect if not already connecting and we have a valid MONGO_URI
  if (!isConnecting && process.env.MONGO_URI && mongoose.connection.readyState === 0) {
    // Clear any existing timeout
    if (reconnectTimeout) {
      clearTimeout(reconnectTimeout);
    }
    console.log('MongoDB disconnected. Will attempt to reconnect in 5 seconds...');
    reconnectTimeout = setTimeout(() => {
      connectDB(3, 5000);
    }, 5000);
  }
});

mongoose.connection.on('reconnected', () => {
  console.log('MongoDB reconnected successfully');
  if (reconnectTimeout) {
    clearTimeout(reconnectTimeout);
    reconnectTimeout = null;
  }
});

module.exports = connectDB;

const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const connectDB = require('./config/db');
const userRoutes = require('./routes/userRoutes');


// Initialize dotenv for environment variables
dotenv.config();


// Connect to the database
connectDB();


// Initialize Express app
const app = express();


// CORS Configuration - Allow requests from specific origins (e.g., ngrok URL)
const corsOptions = {
  origin: '*', // Allow all origins
  methods: 'GET,POST',
  allowedHeaders: 'Content-Type',
};


app.use(cors(corsOptions)); // Use the CORS middleware with the options
app.use(express.json()); // For parsing application/json


// Routes
app.use('/api/users', userRoutes); // User routes (signup, signin)


// Root Route
app.get('/', (req, res) => {
  res.send('API is running...');
});


// Start the server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});







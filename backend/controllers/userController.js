const User = require('../models/User');
const bcrypt = require('bcryptjs');


// Sign Up
const signUp = async (req, res) => {
  const { email, password } = req.body;
  console.log('Received Sign-Up Request:', req.body); // Log the received data

  try {
    // Check if the user already exists
    const userExists = await User.findOne({ email });
    if (userExists) {
      console.log('User already exists:', email);  // Log if user exists
      return res.status(400).json({ message: 'User already exists' });
    }


    // Hash the password
    const hashedPassword = await bcrypt.hash(password, 10);


    // Create new user
    const newUser = new User({
      email,
      password: hashedPassword,
    });


    // Save the new user
    await newUser.save();
    console.log('User created successfully:', newUser); // Log user creation
    res.status(201).json({ message: 'User created successfully' });


  } catch (error) {
    console.error('Error during sign-up:', error); // Log errors
    res.status(500).json({ message: 'Server error' });
  }
};


// Sign In
const signIn = async (req, res) => {
  const { email, password } = req.body;


  // Log the received data
  console.log('Received Sign-In Request:', req.body);


  try {
    // Find the user by email
    const user = await User.findOne({ email });
    if (!user) {
      console.log('User not found for email:', email); // Log if user is not found
      return res.status(400).json({ message: 'Invalid credentials' });
    }


    // Check if the password matches
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      console.log('Password mismatch for email:', email); // Log if passwords don't match
      return res.status(400).json({ message: 'Invalid credentials' });
    }


    // Generate JWT token
    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: '1h' });
    console.log('User signed in successfully:', user.email); // Log successful sign-in


    // Send token in response
    res.status(200).json({ token });

  } catch (error) {
    console.error('Error during sign-in:', error); // Log any error that occurs during sign-in
    res.status(500).json({ message: 'Server error' });
  }
};


module.exports = { signUp, signIn };
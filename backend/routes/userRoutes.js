// /routes/userRoutes.js
const express = require('express');
const { signUp, signIn } = require('../controllers/userController');


const router = express.Router();


router.post('/signup', signUp);
router.post('/signin', signIn);


module.exports = router;







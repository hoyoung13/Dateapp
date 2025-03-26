
const express = require('express');
const router = express.Router();

const { createCourse,getCoursesByUser } = require('../controllers/courseController');

router.post('/courses', createCourse);
router.get('/user_courses/:user_id', getCoursesByUser);

module.exports = router;

const express = require('express');
const { registerUser, loginUser } = require('../controllers/authController'); // ✅ 컨트롤러 불러오기
const router = express.Router();

// ✅ 회원가입 API
router.post("/signup", registerUser);

// ✅ 로그인 API
router.post('/login', loginUser);

module.exports = router;

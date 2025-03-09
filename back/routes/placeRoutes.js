// back/routes/placeRoutes.js
const express = require('express');
const router = express.Router();
const { createPlace } = require('../controllers/placeController');

// POST /places -> 장소 정보 등록 API
router.post("/", createPlace);

module.exports = router;

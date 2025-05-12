// back/routes/placeRoutes.js
const express = require('express');
const router = express.Router();
const { createPlace,getPlaces,getPlaceById,getFilteredPlaces } = require('../controllers/placeController');

// POST /places -> 장소 정보 등록 API
router.post("/", createPlace);
// GET /places -> 등록된 장소 정보 불러오기 API
router.get("/", getPlaces);
router.get('/:id', getPlaceById);

router.get('/place', getFilteredPlaces);

module.exports = router;

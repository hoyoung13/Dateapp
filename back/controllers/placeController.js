// back/controllers/placeController.js
const pool = require('../config/db');

const createPlace = async (req, res) => {
  try {
    const {
      user_id,
      place_name,
      description,
      address,
      phone,
      main_category,
      sub_category,
      hashtags,
      images,
      operating_hours,
      price_info,
    } = req.body;

    const query = `
      INSERT INTO place_info 
        (user_id, place_name, description, address, phone, main_category, sub_category, hashtags, images, operating_hours, price_info)
      VALUES 
        ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
      RETURNING *
    `;

    const values = [
      user_id,
      place_name,
      description,
      address,
      phone,
      main_category,
      sub_category,
      hashtags,         // 예: ["#카페", "#데이트"]
      images,           // 예: ["https://example.com/image1.jpg", "https://example.com/image2.jpg"]
      operating_hours,  // JSON 객체: {"월": {"start": "09:00", "end": "18:00"}, ...}
      price_info,       // JSON 객체나 null
    ];

    const result = await pool.query(query, values);

    res.status(201).json({ message: "Place created", place: result.rows[0] });
  } catch (error) {
    console.error("Error creating place:", error);
    res.status(500).json({ error: "Server error" });
  }
};

module.exports = { createPlace };

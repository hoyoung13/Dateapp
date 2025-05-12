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
const getPlaces = async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM place_info"); // 모든 장소 정보 조회
    res.status(200).json(result.rows);
  } catch (error) {
    console.error("Error fetching places:", error);
    res.status(500).json({ error: "Server error" });
  }
};

const getPlaceById = async (req, res) => {
  try {
    const { id } = req.params; // URL 파라미터로 장소의 id 받기
    const result = await pool.query("SELECT * FROM place_info WHERE id = $1", [id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Place not found" });
    }
    res.status(200).json(result.rows[0]);
  } catch (error) {
    console.error("Error fetching place:", error);
    res.status(500).json({ error: "Server error" });
  }
};
async function getFilteredPlaces(req, res) {
  try {
    // 쿼리 파라미터 읽기
    const { city, district, neighborhood, category } = req.query;

    // 동적 WHERE 절 조립 준비
    const conditions = [];
    const values = [];

    // main_category 필터 (category 파라미터가 있을 때만)
    if (category) {
      values.push(category);
      conditions.push(`main_category = $${values.length}`);
    }

    // 도시(시/도) 필터
    if (city) {
      values.push(`%${city}%`);
      conditions.push(`address LIKE $${values.length}`);
    }
    // 구/군 필터
    if (district) {
      values.push(`%${district}%`);
      conditions.push(`address LIKE $${values.length}`);
    }
    // 동/읍/면 필터
    if (neighborhood) {
      values.push(`%${neighborhood}%`);
      conditions.push(`address LIKE $${values.length}`);
    }

    // where절이 하나도 없으면 빈 문자열
    const whereClause = conditions.length
      ? `WHERE ${conditions.join(' AND ')}`
      : '';

    const query = `
      SELECT *
      FROM place_info
      ${whereClause}
      ORDER BY id
    `;
    const { rows } = await pool.query(query, values);
    res.json(rows);
  } catch (err) {
    console.error('getFilteredPlaces error:', err);
    res.status(500).json({ error: 'Failed to load places' });
  }
}

module.exports = { createPlace, getPlaces,getPlaceById,getFilteredPlaces };

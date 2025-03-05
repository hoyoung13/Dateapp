const pool = require("../db");

// 사용자 검색 (닉네임 + 이메일)
const searchUser = async (req, res) => {
    const { nickname, email } = req.query;

    try {
        const result = await pool.query(
            "SELECT id, nickname, email FROM users WHERE nickname = $1 AND email = $2",
            [nickname, email]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: "사용자를 찾을 수 없습니다." });
        }

        res.status(200).json({ user: result.rows[0] });
    } catch (error) {
        console.error("❌ 사용자 검색 오류:", error);
        res.status(500).json({ error: "서버 오류 발생" });
    }
};
// ✅ 커플 정보 가져오기 (user_id 또는 partner_id 검색)
const getCoupleInfo = async (req, res) => {
    const { userId } = req.params;

    try {
        const result = await pool.query(
            "SELECT * FROM couples WHERE user_id = $1 OR partner_id = $1",
            [userId]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: "등록된 커플이 없습니다." });
        }

        res.status(200).json({ couple: result.rows[0] });
    } catch (error) {
        console.error("❌ 커플 정보 가져오기 오류:", error);
        res.status(500).json({ error: "서버 오류 발생" });
    }
};

module.exports = { searchUser,getCoupleInfo };

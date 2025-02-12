    const bcrypt = require('bcryptjs');
    const jwt = require('jsonwebtoken');
    const pool = require('../config/db');

    // ✅ 회원가입 로직
    const registerUser = async (req, res) => {
        try {
            console.log("📩 회원가입 요청 받음:", req.body);
            const { nickname, email, password, name, birth_date } = req.body;

            // 이메일 중복 확인
            const userCheck = await pool.query("SELECT * FROM users WHERE email = $1", [email]);
            if (userCheck.rows.length > 0) {
                return res.status(400).json({ error: "이미 존재하는 이메일입니다." });
            }

            // 비밀번호 해싱
            const hashedPassword = await bcrypt.hash(password, 10);

            // 유저 정보 저장
            const newUser = await pool.query(
                "INSERT INTO users (nickname, email, password, name, birth_date) VALUES ($1, $2, $3, $4, $5) RETURNING *",
                [nickname, email, hashedPassword, name, birth_date]
            );

            res.status(201).json({ message: "✅ 회원가입 성공!", user: newUser.rows[0] });
        } catch (err) {
            console.error(err.message);
            res.status(500).json({ error: "❌ 서버 오류 발생" });
        }
    };

    // ✅ 로그인 로직
    const loginUser = async (req, res) => {
        try {
            const { email, password } = req.body;
            const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);

            if (result.rows.length === 0) {
                return res.status(400).json({ error: "❌ 이메일이 존재하지 않습니다." });
            }

            const user = result.rows[0];
            const isMatch = await bcrypt.compare(password, user.password);

            if (!isMatch) {
                return res.status(400).json({ error: "❌ 비밀번호가 틀렸습니다." });
            }

            const token = jwt.sign(
                { userId: user.id, email: user.email },
                process.env.JWT_SECRET || "your_secret_key",
                { expiresIn: "1h" } // 1시간 동안 유효
            );

            res.json({ message: "✅ 로그인 성공!", token, user: { id: user.id, nickname: user.nickname, email: user.email } });
        } catch (error) {
            console.error(error.message);
            res.status(500).json({ error: "❌ 서버 오류 발생" });
        }
    };

    module.exports = { registerUser, loginUser };

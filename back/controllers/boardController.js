const db = require("../config/db");

// 모든 게시글 조회
exports.getAllPosts = async (req, res) => {
  try {
    const query = `
      SELECT posts.*, boards.name AS board_name
      FROM posts
      LEFT JOIN boards ON posts.board_id = boards.id  -- ✅ LEFT JOIN 사용
      ORDER BY posts.created_at DESC;
    `;
    const { rows } = await db.query(query);  // ✅ `const { rows }` 사용

    console.log("📌 DB 응답 데이터:", rows);

    res.status(200).json(rows);  // ✅ 응답을 한 번만 보냄
  } catch (error) {
    console.error("❌ Error fetching posts:", error.message);
    if (!res.headersSent) {
      res.status(500).json({ error: "서버 오류 발생" });
    }
  }
};



// 특정 게시판 글 조회
exports.getPostsByBoard = async (req, res) => {
  const { boardId } = req.params;
  try {
    const query = `
      SELECT posts.*, boards.name AS board_name
      FROM posts
      JOIN boards ON posts.board_id = boards.id
      WHERE posts.board_id = ?
      ORDER BY posts.created_at DESC;
    `;
    const [rows] = await db.query(query, [boardId]);
    res.json(rows);
  } catch (error) {
    console.error("❌ Error fetching board posts:", error);
    res.status(500).json({ error: "서버 오류 발생" });
  }
};

// 게시글 작성
exports.createPost = async (req, res) => {
  const { user_id, board_id, title, content } = req.body;
  try {
    const query = `
      INSERT INTO posts (user_id, board_id, title, content)
      VALUES ($1, $2, $3, $4)
    `;
    await db.query(query, [user_id, board_id, title, content]);
    res.status(201).json({ message: "게시글 작성 완료" });
  } catch (error) {
    console.error("❌ Error creating post:", error);
    res.status(500).json({ error: "서버 오류 발생" });
  }
};
// 게시글 수정
exports.updatePost = async (req, res) => {
    const { postId } = req.params;
    const { title, content } = req.body;
  
    try {
      const query = `
        UPDATE posts
        SET title = ?, content = ?, updated_at = CURRENT_TIMESTAMP
        WHERE id = ?;
      `;
      const [result] = await db.query(query, [title, content, postId]);
  
      if (result.affectedRows === 0) {
        return res.status(404).json({ error: "게시글을 찾을 수 없음" });
      }
  
      res.json({ message: "게시글 수정 완료" });
    } catch (error) {
      console.error("❌ Error updating post:", error);
      res.status(500).json({ error: "서버 오류 발생" });
    }
  };
// 게시글 삭제
exports.deletePost = async (req, res) => {
  const { postId } = req.params;
  try {
    const query = `DELETE FROM posts WHERE id = ?`;
    await db.query(query, [postId]);
    res.json({ message: "게시글 삭제 완료" });
  } catch (error) {
    console.error("❌ Error deleting post:", error);
    res.status(500).json({ error: "서버 오류 발생" });
  }
};

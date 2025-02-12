    const express = require("express");
    const router = express.Router();
    const boardController = require("../controllers/boardController");
    console.log(boardController);

    // 모든 게시글 가져오기
    router.get("/", boardController.getAllPosts);

    // 특정 게시판 글 가져오기
    router.get("/:boardId", boardController.getPostsByBoard);

    // 게시글 작성
    router.post("/", boardController.createPost);

    // 게시글 삭제
    router.delete("/:postId", boardController.deletePost);

    // 게시글 수정 (PUT 요청)
    router.put("/:postId", boardController.updatePost);

    module.exports = router;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WritePostPage extends StatefulWidget {
  const WritePostPage({super.key});

  @override
  _WritePostPageState createState() => _WritePostPageState();
}

class _WritePostPageState extends State<WritePostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String? _selectedBoardType;
  final List<String> _boardTypes = ["자유 게시판", "질문 게시판", "추천 게시판"];

  Future<void> _submitPost() async {
    if (_titleController.text.isEmpty ||
        _contentController.text.isEmpty ||
        _selectedBoardType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("제목, 내용, 게시판을 선택하세요.")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("http://172.30.1.17:5000/boards"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": _titleController.text,
          "content": _contentController.text,
          "board_type": _selectedBoardType,
          "user_id": 1, // 🔹 로그인한 사용자 ID (추후 로그인 연동 필요)
        }),
      );

      if (response.statusCode == 201) {
        Navigator.pop(context, true); // ✅ 작성 후 이전 페이지로 이동
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ 게시글 작성 실패")),
        );
      }
    } catch (e) {
      print("❌ 게시글 작성 오류: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("게시글 작성"),
        backgroundColor: Colors.cyan[100],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ 게시판 선택 드롭다운
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "게시판 선택"),
              value: _selectedBoardType,
              items: _boardTypes.map((board) {
                return DropdownMenuItem(value: board, child: Text(board));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBoardType = value;
                });
              },
            ),
            const SizedBox(height: 10),

            // ✅ 제목 입력
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "제목"),
            ),
            const SizedBox(height: 10),

            // ✅ 내용 입력
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: "내용"),
              maxLines: 5,
            ),
            const SizedBox(height: 20),

            // ✅ 게시글 작성 버튼
            ElevatedButton(
              onPressed: _submitPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan[200],
              ),
              child: const Text("게시글 작성"),
            ),
          ],
        ),
      ),
    );
  }
}

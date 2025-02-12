import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'user_provider.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  Future<void> _signup() async {
    try {
      final response = await http.post(
        Uri.parse("http://172.30.1.17:5000/auth/signup"), // ✅ 서버 주소 맞는지 확인
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nickname": _nicknameController.text,
          "email": _emailController.text,
          "password": _passwordController.text,
          "name": _nameController.text,
          "birth_date": _birthDateController.text, // "YYYY-MM-DD" 형식
        }),
      );

      print("📥 서버 응답 상태 코드: ${response.statusCode}");
      print("📥 서버 응답 본문: ${response.body}");

      // ✅ 응답이 JSON 형식인지 확인
      try {
        final responseData = jsonDecode(response.body);
        if (response.statusCode == 201) {
          print("✅ 회원가입 성공: ${responseData["user"]}");
          Provider.of<UserProvider>(context, listen: false)
              .setUserData(responseData["user"]);
          Navigator.pushReplacementNamed(context, "/login");
        } else {
          print("❌ 회원가입 실패: ${responseData["error"]}");
        }
      } catch (e) {
        print("⚠️ 서버가 JSON이 아닌 데이터를 반환했습니다. 응답 본문 확인: ${response.body}");
      }
    } catch (e) {
      print("❌ 회원가입 요청 중 오류 발생: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  '회원가입',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 닉네임 입력
              TextField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  labelText: "닉네임",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // 이메일 입력
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "이메일",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // 비밀번호 입력
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "비밀번호",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // 이름 입력
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "이름",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // 생년월일 입력
              TextField(
                controller: _birthDateController,
                decoration: InputDecoration(
                  labelText: "생년월일 (YYYY-MM-DD)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 회원가입 버튼
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF80E9FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "회원가입",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

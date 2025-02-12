import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    try {
      final response = await http.post(
        Uri.parse("http://172.30.1.17:5000/auth/login"), // 🔹 서버 주소 확인
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _emailController.text,
          "password": _passwordController.text,
        }),
      );

      print("📥 서버 응답 상태 코드: ${response.statusCode}");
      print("📥 서버 응답 본문: ${response.body}");

      // ✅ 응답이 JSON 형식인지 확인
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print("✅ 로그인 성공: ${responseData["user"]}");
        // ✅ UserProvider에 로그인된 유저 정보 저장
        Provider.of<UserProvider>(context, listen: false)
            .setUserData(responseData["user"]);

        // 홈 화면으로 이동
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        print("❌ 로그인 실패: ${responseData["error"]}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("로그인 실패: ${responseData["error"]}")),
        );
      }
    } catch (e) {
      print("❌ 로그인 요청 중 오류 발생: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 422,
          height: 840,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 상단 앱 아이콘 자리
              const SizedBox(
                height: 100,
                child: Center(
                  child: Text(
                    "DATE IT",
                    style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold, // 🔹 Bold 적용
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 이메일 입력 필드
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 39),
                child: SizedBox(
                  height: 54,
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: "이메일",
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          width: 1,
                          color: Colors.black.withOpacity(0.15),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          width: 1,
                          color: Colors.blue,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 비밀번호 입력 필드
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 39),
                child: SizedBox(
                  height: 54,
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "비밀번호",
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          width: 1,
                          color: Colors.black.withOpacity(0.15),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          width: 1,
                          color: Colors.blue,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 🔹 일반 로그인 버튼 (이메일 & 비밀번호)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 39),
                child: SizedBox(
                  height: 54,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF80E9FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _login, // 🔹 로그인 요청 실행
                    child: const Text(
                      '로그인',
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 🔹 ✅ 카카오 로그인 버튼 ✅
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 39),
                child: SizedBox(
                  height: 54,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        bool isInstalled = await isKakaoTalkInstalled();

                        OAuthToken token;
                        if (isInstalled) {
                          token = await UserApi.instance.loginWithKakaoTalk();
                        } else {
                          token =
                              await UserApi.instance.loginWithKakaoAccount();
                        }

                        print('카카오 로그인 성공: ${token.accessToken}');
                        // 🔹 유저 정보 가져오기
                        User user = await UserApi.instance.me();
                        String userName =
                            user.kakaoAccount?.profile?.nickname ?? "사용자";

                        print("✅ 카카오 사용자 이름: $userName");

                        // ✅ UserProvider에 저장 (만약 Provider를 사용하고 있다면)
                        Provider.of<UserProvider>(context, listen: false)
                            .setUserData({
                          "nickname": userName,
                          "email": user.kakaoAccount?.email ?? "",
                        });
                        Navigator.pushReplacementNamed(context, '/home');
                      } catch (e) {
                        print('카카오 로그인 실패: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("카카오 로그인 실패: $e")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '카카오 로그인',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 회원가입 & 비밀번호 찾기 버튼
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 39),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: const Text(
                            '회원가입',
                            style: TextStyle(
                              fontSize: 24,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: TextButton(
                          onPressed: () {
                            // 비밀번호 찾기 기능 추가 예정
                          },
                          child: const Text(
                            '비밀번호 찾기',
                            style: TextStyle(
                              fontSize: 24,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

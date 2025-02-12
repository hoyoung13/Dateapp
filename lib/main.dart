import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'home.dart'; // ✅ HomePage 불러오기
import 'login.dart'; // ✅ LoginPage 불러오기
import 'signup.dart'; // ✅ SignupPage 불러오기 (필수)
import 'my.dart';
import 'food.dart';
import 'board.dart';
import 'user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env"); // ✅ 정확한 경로로 설정
  KakaoSdk.init(nativeAppKey: "2335e028a51784148baef28bac903d8c");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
  printKeyHash();
}

void printKeyHash() async {
  String keyHash = await KakaoSdk.origin;
  print("🔑 현재 앱에서 사용하는 키 해시: $keyHash");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print("MyApp build called");
    return MaterialApp(
      title: 'Date App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: Colors.grey.shade100),
      initialRoute: '/login', // ✅ 로그인 페이지가 첫 화면
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/signup': (context) => const SignupPage(),
        '/my': (context) => const MyPage(),
        '/food': (context) => const FoodPage(),
        '/board': (context) => const BoardPage(),
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'price.dart'; // ✅ 가격정보 입력 페이지 import

class PlacePage extends StatelessWidget {
  const PlacePage({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController placeController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB9FDF9), // ✅ 상단 바 색상 조정
        title: const Text(
          '장소 제안',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0, // ✅ 그림자 제거
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '등록하고자 하는 장소의 이름을 입력하세요',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: placeController,
              decoration: InputDecoration(
                hintText: "장소 이름 입력",
                filled: true,
                fillColor: const Color(0xFFD9D9D9), // ✅ 기존 배경색 유지
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
            ),
            const SizedBox(height: 30),

            // ✅ "다음 단계로" 버튼 → 가격정보 입력 페이지로 이동
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB9FDF9), // ✅ 버튼 색상 동일하게
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () {
                // ✅ 가격정보 입력 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PriceInfoPage(placeName: placeController.text),
                  ),
                );
              },
              child: const Center(
                child: Text(
                  "다음 단계로",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

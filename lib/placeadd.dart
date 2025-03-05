import 'package:flutter/material.dart';

class PlaceAdditionalInfoPage extends StatefulWidget {
  const PlaceAdditionalInfoPage({super.key});

  @override
  _PlaceAdditionalInfoPageState createState() =>
      _PlaceAdditionalInfoPageState();
}

class _PlaceAdditionalInfoPageState extends State<PlaceAdditionalInfoPage> {
  List<String> imageList = []; // ✅ 업로드된 이미지 리스트
  TextEditingController descriptionController =
      TextEditingController(); // ✅ 소개글 입력 컨트롤러
  TextEditingController hashtagController =
      TextEditingController(); // ✅ 해시태그 입력 컨트롤러
  Map<String, bool> selectedDays = {
    "월": false,
    "화": false,
    "수": false,
    "목": false,
    "금": false,
    "토": false,
    "일": false,
  };

  Map<String, String> openingHours = {
    "월": "09:00 ~ 21:00",
    "화": "09:00 ~ 21:00",
    "수": "09:00 ~ 21:00",
    "목": "09:00 ~ 21:00",
    "금": "09:00 ~ 21:00",
    "토": "09:00 ~ 21:00",
    "일": "휴무",
  };

  void _toggleDaySelection(String day) {
    setState(() {
      selectedDays[day] = !selectedDays[day]!; // ✅ 선택/해제 토글
    });
  }

  Future<void> _selectTime(
      BuildContext context, String day, bool isStartTime) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        String formattedTime =
            "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
        if (isStartTime) {
          openingHours[day] =
              "$formattedTime ~ ${openingHours[day]!.split(" ~ ")[1]}";
        } else {
          openingHours[day] =
              "${openingHours[day]!.split(" ~ ")[0]} ~ $formattedTime";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB9FDF9),
        title: const Text(
          '장소 정보 입력',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const Text(
              "장소의 추가 정보를 입력해주세요",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // ✅ 장소 이미지 추가
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("장소 이미지", style: TextStyle(fontSize: 14)),
                TextButton(
                  onPressed: () {}, // 이미지 추가 기능 추가 가능
                  child: const Text("추가", style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: List.generate(
                4, // 예제: 4개의 이미지 슬롯
                (index) => Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(child: Icon(Icons.image, size: 30)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ✅ 장소 소개글 입력
            const Text("장소 소개글", style: TextStyle(fontSize: 14)),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "장소를 소개해주세요.",
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ✅ 해시태그 추가
            TextField(
              controller: hashtagController,
              decoration: InputDecoration(
                hintText: "해시태그 추가",
                filled: true,
                fillColor: Colors.grey[300],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ✅ 영업시간 설정
            const Text("영업시간", style: TextStyle(fontSize: 14)),
            const SizedBox(height: 10),
            Column(
              children: selectedDays.entries.map((entry) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ✅ 요일 선택 버튼
                    GestureDetector(
                      onTap: () => _toggleDaySelection(entry.key),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: entry.value ? Colors.cyan : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black),
                        ),
                        child: Text(entry.key,
                            style: TextStyle(
                                fontSize: 14,
                                color:
                                    entry.value ? Colors.white : Colors.black)),
                      ),
                    ),

                    // ✅ 시작 시간 선택
                    GestureDetector(
                      onTap: () => _selectTime(context, entry.key, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          openingHours[entry.key]!.split(" ~ ")[0],
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    const Text("~"), // ✅ 사이에 "~" 표시

                    // ✅ 종료 시간 선택
                    GestureDetector(
                      onTap: () => _selectTime(context, entry.key, false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          openingHours[entry.key]!.split(" ~ ")[1],
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ✅ 장소 제안 버튼
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB9FDF9),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () {
                // ✅ 장소 정보 저장 및 제출 기능 추가 가능
              },
              child: const Center(
                child: Text(
                  "장소 제안",
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

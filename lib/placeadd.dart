import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:time_picker_spinner/time_picker_spinner.dart';

class PlaceAdditionalInfoPage extends StatefulWidget {
  final String placeName;

  const PlaceAdditionalInfoPage({super.key, required this.placeName});

  @override
  _PlaceAdditionalInfoPageState createState() =>
      _PlaceAdditionalInfoPageState();
}

class _PlaceAdditionalInfoPageState extends State<PlaceAdditionalInfoPage> {
  // 장소 소개, 해시태그, 전화번호 입력 컨트롤러
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController hashtagController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // 추가된 해시태그 리스트
  List<String> hashtags = [];

  // 이미지 리스트 (파일 경로 또는 URL)
  List<String> imageList = [];

  // 요일별 영업 여부 (true → 영업, false → 휴무)
  Map<String, bool> selectedDays = {
    "월": false,
    "화": false,
    "수": false,
    "목": false,
    "금": false,
    "토": false,
    "일": false,
  };

  // 요일별 시작/종료 시간 (시, 분)
  Map<String, int> startHour = {
    "월": 9,
    "화": 9,
    "수": 9,
    "목": 9,
    "금": 9,
    "토": 9,
    "일": 9,
  };
  Map<String, int> startMinute = {
    "월": 0,
    "화": 0,
    "수": 0,
    "목": 0,
    "금": 0,
    "토": 0,
    "일": 0,
  };
  Map<String, int> endHour = {
    "월": 18,
    "화": 18,
    "수": 18,
    "목": 18,
    "금": 18,
    "토": 18,
    "일": 18,
  };
  Map<String, int> endMinute = {
    "월": 0,
    "화": 0,
    "수": 0,
    "목": 0,
    "금": 0,
    "토": 0,
    "일": 0,
  };

  /// 요일 선택/해제 (휴무 ↔ 영업)
  void _toggleDaySelection(String day) {
    setState(() {
      selectedDays[day] = !selectedDays[day]!;
    });
  }

  /// Spinner TimePicker 열기 (시간 선택)
  void _showSpinnerTimePicker(BuildContext context, String day, bool isStart) {
    DateTime tempDateTime = DateTime(
      2023,
      1,
      1,
      isStart ? startHour[day]! : endHour[day]!,
      isStart ? startMinute[day]! : endMinute[day]!,
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("시간 설정"),
          content: SizedBox(
            height: 200,
            child: TimePickerSpinner(
              is24HourMode: true, // 24시간제
              normalTextStyle:
                  const TextStyle(fontSize: 18, color: Colors.grey),
              highlightedTextStyle:
                  const TextStyle(fontSize: 24, color: Colors.black),
              spacing: 40,
              itemHeight: 40,
              isForce2Digits: true,
              time: tempDateTime,
              onTimeChange: (newTime) {
                tempDateTime = newTime;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (isStart) {
                    startHour[day] = tempDateTime.hour;
                    startMinute[day] = tempDateTime.minute;
                  } else {
                    endHour[day] = tempDateTime.hour;
                    endMinute[day] = tempDateTime.minute;
                  }
                });
                Navigator.pop(ctx);
              },
              child: const Text("확인"),
            ),
          ],
        );
      },
    );
  }

  /// 해시태그 추가 버튼 동작
  void _addHashtag() {
    String text = hashtagController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        if (!text.startsWith('#')) {
          text = "#$text";
        }
        hashtags.add(text);
        hashtagController.clear();
      });
    }
  }

  /// 이미지 선택 (image_picker 사용)
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageList.add(pickedFile.path);
      });
    }
  }

  /// 이미지 위젯 (파일 경로이면 FileImage, 아니면 NetworkImage)
  Widget _buildImageWidget(String imagePath) {
    ImageProvider imageProvider;
    if (imagePath.startsWith('http')) {
      imageProvider = NetworkImage(imagePath);
    } else {
      imageProvider = FileImage(File(imagePath));
    }
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("장소 정보 입력", style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFB9FDF9),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            // 안내 문구
            Text(
              "'${widget.placeName.replaceAll(RegExp(r'<[^>]*>'), '')}'의 추가 정보를 입력해주세요",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // 이미지 섹션: 등록된 이미지들 + 오른쪽에 추가 placeholder
            Wrap(
              spacing: 10,
              children: [
                ...imageList.map((image) => _buildImageWidget(image)),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(child: Icon(Icons.add, size: 30)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 장소 소개글 입력
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

            // 장소 전화번호 입력
            const Text("장소 전화번호", style: TextStyle(fontSize: 14)),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "전화번호 입력",
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 해시태그 입력 + 추가 버튼
            const Text("해시태그", style: TextStyle(fontSize: 14)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: hashtagController,
                    decoration: InputDecoration(
                      hintText: "해시태그 입력",
                      filled: true,
                      fillColor: Colors.grey[300],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _addHashtag,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: hashtags
                  .map((tag) => Chip(
                        label: Text(tag),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),

            // 영업시간 설정 (요일별)
            const Text("영업시간", style: TextStyle(fontSize: 14)),
            const SizedBox(height: 10),
            Column(
              children: selectedDays.entries.map((entry) {
                final day = entry.key;
                final isSelected = entry.value;
                return Column(
                  children: [
                    // Row: 요일은 왼쪽 정렬, 시간 정보는 Expanded로 가운데 정렬
                    Row(
                      children: [
                        // 요일 버튼 (왼쪽 정렬)
                        GestureDetector(
                          onTap: () => _toggleDaySelection(day),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.cyan : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.black),
                            ),
                            child: Text(
                              day,
                              style: TextStyle(
                                fontSize: 14,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        // Expanded 영역에 시간 정보 중앙 정렬
                        Expanded(
                          child: Center(
                            child: isSelected
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap: () => _showSpinnerTimePicker(
                                            context, day, true),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            "${startHour[day]!.toString().padLeft(2, '0')}:${startMinute[day]!.toString().padLeft(2, '0')}",
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      const Text("~",
                                          style: TextStyle(fontSize: 16)),
                                      const SizedBox(width: 5),
                                      GestureDetector(
                                        onTap: () => _showSpinnerTimePicker(
                                            context, day, false),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            "${endHour[day]!.toString().padLeft(2, '0')}:${endMinute[day]!.toString().padLeft(2, '0')}",
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : const Text("휴무"),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // "장소 제안" 버튼
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB9FDF9),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () {
                // 예시: 각 요일의 시간 상태 출력
                for (var day in selectedDays.keys) {
                  if (selectedDays[day]!) {
                    debugPrint(
                        "$day: ${startHour[day]!.toString().padLeft(2, '0')}:${startMinute[day]!.toString().padLeft(2, '0')} ~ ${endHour[day]!.toString().padLeft(2, '0')}:${endMinute[day]!.toString().padLeft(2, '0')}");
                  } else {
                    debugPrint("$day: 휴무");
                  }
                }
                // TODO: 추가 정보 저장 로직 구현 (DB 연동 등)
              },
              child: const Text("장소 제안", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}

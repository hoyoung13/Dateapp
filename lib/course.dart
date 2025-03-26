import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'user_provider.dart';
import 'zzimlist.dart';
import 'selectplace.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'course2.dart';
import 'schedule_item.dart'; // 여기서만 ScheduleItem이 정의됨

class CourseCreationPage extends StatefulWidget {
  const CourseCreationPage({Key? key}) : super(key: key);

  @override
  _CourseCreationPageState createState() => _CourseCreationPageState();
}

class _CourseCreationPageState extends State<CourseCreationPage> {
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _courseDescController = TextEditingController();
  final TextEditingController _hashtagController = TextEditingController();

  DateTime? _selectedDate;
  List<String> hashtags = [];

  // 일정 목록(장소 정보)
  List<ScheduleItem> schedules = [
    ScheduleItem(),
  ];

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userId = userProvider.userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text("데이트 코스 설정하기"),
        backgroundColor: Colors.cyan[100],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // (1) 코스 이름 입력
            const Text(
              "이름 설정",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _courseNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "예) 주말 데이트 코스",
              ),
            ),
            const SizedBox(height: 16),
            // (2) 코스 설명 입력
            const Text(
              "코스 설명",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _courseDescController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "예) 전체적인 코스 설명을 적어주세요",
              ),
            ),
            const SizedBox(height: 16),
            // (3) 해시태그 입력 및 추가
            const Text(
              "해시태그",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _hashtagController,
                    decoration: InputDecoration(
                      hintText: "해시태그 입력",
                      filled: true,
                      fillColor: Colors.grey[300],
                      border: const OutlineInputBorder(
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
            if (hashtags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: hashtags.map((tag) {
                  return Chip(
                    label: Text("#$tag"),
                    deleteIcon: const Icon(Icons.close),
                    onDeleted: () => _removeHashtag(tag),
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),
            // (4) 날짜 설정 (미설정 가능)
            const Text(
              "날짜 설정 (미설정 가능)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _pickDate,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan[100]),
                  child: Text(
                    _selectedDate == null
                        ? "날짜 선택"
                        : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(width: 12),
                if (_selectedDate != null)
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        _selectedDate = null;
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // (5) 일정들 (장소 선택 박스 및 선택된 장소 카드)
            for (int i = 0; i < schedules.length; i++) ...[
              Text(
                "${i + 1}번째 일정",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: InkWell(
                        onTap: () async {
                          if (userId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('로그인 정보가 없습니다.')),
                            );
                            return;
                          }
                          final selectedCollection =
                              await showDialog<Map<String, dynamic>>(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) =>
                                ZzimListDialog(userId: userId),
                          );
                          if (selectedCollection != null) {
                            final selectedPlace =
                                await Navigator.push<Map<String, dynamic>>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SelectplacePage(
                                    collection: selectedCollection),
                              ),
                            );
                            print("선택된 장소 데이터: $selectedPlace");
                            if (selectedPlace != null) {
                              setState(() {
                                schedules[i].placeName =
                                    selectedPlace['place_name'];
                                schedules[i].placeAddress =
                                    selectedPlace['address'];
                                schedules[i].placeImage =
                                    selectedPlace['image'];
                              });
                            }
                          }
                        },
                        child: Center(
                          child: Text(
                            schedules[i].placeName == null ? "장소 선택" : "장소 변경",
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () {
                      if (schedules.length <= 1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("최소 한 개의 일정이 필요합니다.")),
                        );
                      } else {
                        setState(() {
                          schedules.removeAt(i);
                        });
                      }
                    },
                  ),
                ],
              ),
              if (schedules[i].placeName != null)
                _buildSelectedPlaceCard(schedules[i]),
            ],
            // (6) 일정 추가하기 버튼
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _addSchedule,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.cyan),
                  foregroundColor: Colors.cyan,
                ),
                icon: const Icon(Icons.add),
                label: const Text("일정 추가하기"),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CourseCreationStep2Page(
                        courseName: _courseNameController.text,
                        courseDescription: _courseDescController.text,
                        schedules: schedules,
                      ),
                    ),
                  );
                },
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.cyan[100]),
                child: const Text(
                  "다음 단계로",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedPlaceCard(ScheduleItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.placeImage != null)
              item.placeImage!.startsWith('http')
                  ? Image.network(
                      item.placeImage!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      File(item.placeImage!),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
            else
              Container(
                color: Colors.grey.shade300,
                height: 180,
                width: double.infinity,
                alignment: Alignment.center,
                child: const Text("이미지 없음"),
              ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.placeName ?? "장소 이름 없음",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.placeAddress ?? "주소 정보 없음",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (selected != null) {
      setState(() {
        _selectedDate = selected;
      });
    }
  }

  void _addHashtag() {
    final text = _hashtagController.text.trim();
    if (text.isNotEmpty && !hashtags.contains(text)) {
      setState(() {
        hashtags.add(text);
      });
    }
    _hashtagController.clear();
  }

  void _removeHashtag(String tag) {
    setState(() {
      hashtags.remove(tag);
    });
  }

  void _addSchedule() {
    setState(() {
      schedules.add(ScheduleItem());
    });
  }
}

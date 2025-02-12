import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  @override
  _FoodPageState createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  String? selectedCity;
  String? selectedDistrict;
  String? selectedNeighborhood;
  String? selectedRecommendation; // 🔹 선택된 추천 방식
  Map<String, dynamic> regionData = {}; // 🔹 지역 데이터 저장
  final List<String> recommendationMethods = ['MBTI', '성향', '찜순', '평점순'];
  int totalPages = 5; // 🔹 전체 페이지 수
  int currentPage = 1; // 🔹 현재 선택된 페이지

  @override
  void initState() {
    super.initState();
    _loadRegions(); // ✅ JSON 데이터 불러오기
  }

  Future<void> _loadRegions() async {
    String data = await rootBundle.loadString('assets/regions.json');
    setState(() {
      regionData = json.decode(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ 배경을 흰색으로 변경
      appBar: AppBar(
        backgroundColor: Colors.cyan[100],
        title: const Text('맛집 추천'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                // 🔹 지역 선택 & 추천 방식 선택 드롭다운 메뉴
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _showRegionSelectionDialog();
                      },
                      child: Text(
                        selectedCity ?? '지역 선택',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    _buildRecommendationDropdown(),
                  ],
                ),
                const SizedBox(height: 10),
                const Text("(선택된 방식)으로 추천되는 맛집",
                    style: TextStyle(fontSize: 16)),
              ],
            ),
          ),

          // 🔹 추천 맛집 표시 (2x3 Grid) + 스크롤 가능
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // ✅ 2열
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: 6, // ✅ 더미 데이터 6개
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return _buildFoodCard();
                    },
                  ),

                  // 🔹 페이지네이션 버튼 (맨 아래 유지)
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      totalPages,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              currentPage = index + 1;
                            });
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: currentPage == index + 1
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          child: Text("${index + 1}"),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20), // 아래 여백 추가
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 추천 방식 선택 드롭다운
  Widget _buildRecommendationDropdown() {
    return DropdownButton<String>(
      hint: const Text("추천방식 선택"),
      value: selectedRecommendation,
      items: recommendationMethods.map((String method) {
        return DropdownMenuItem<String>(
          value: method,
          child: Text(method),
        );
      }).toList(),
      onChanged: (String? value) {
        setState(() {
          selectedRecommendation = value;
        });
      },
    );
  }

  // ✅ 지역 선택 다이얼로그
  void _showRegionSelectionDialog() {
    String? tempCity;
    String? tempDistrict;
    String? tempNeighborhood;
    List<String> tempDistricts = [];
    List<String> tempNeighborhoods = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("지역 선택"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    hint: const Text("시/도 선택"),
                    value: tempCity,
                    items: regionData.keys.map((String city) {
                      return DropdownMenuItem<String>(
                        value: city,
                        child: Text(city),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      if (value != null) {
                        setDialogState(() {
                          tempCity = value;
                          tempDistricts = regionData[value]!.keys.toList();
                          tempDistrict = null;
                          tempNeighborhood = null;
                          tempNeighborhoods = [];
                        });
                      }
                    },
                  ),
                  DropdownButton<String>(
                    hint: const Text("구/군 선택"),
                    value: tempDistrict,
                    items: tempDistricts.map((String district) {
                      return DropdownMenuItem<String>(
                        value: district,
                        child: Text(district),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      if (value != null) {
                        setDialogState(() {
                          tempDistrict = value;
                          tempNeighborhoods = regionData[tempCity]![value]!;
                          tempNeighborhood = null;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedCity = tempCity;
                      selectedDistrict = tempDistrict;
                      selectedNeighborhood = tempNeighborhood;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text("확인"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ✅ 추천 맛집 카드 UI
  Widget _buildFoodCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade300, blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: const Center(
                  child: Text("사진", style: TextStyle(fontSize: 16))),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("이름",
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text("추천수: 00  평점: 0.0", style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

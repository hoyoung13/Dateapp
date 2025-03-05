import 'package:flutter/material.dart';
import 'placeadd.dart';

class PriceInfoPage extends StatefulWidget {
  final String placeName;

  const PriceInfoPage({super.key, required this.placeName});

  @override
  _PriceInfoPageState createState() => _PriceInfoPageState();
}

class _PriceInfoPageState extends State<PriceInfoPage> {
  bool _showPriceInputs = false; // 가격 정보 입력 UI 표시 여부
  List<Map<String, String>> _priceList = []; // 가격 정보 리스트
  TextEditingController itemController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  void _togglePriceInputs(bool show) {
    setState(() {
      _showPriceInputs = show;
    });
  }

  void _addPriceInfo() {
    if (itemController.text.isNotEmpty && priceController.text.isNotEmpty) {
      setState(() {
        _priceList.add({
          "item": itemController.text,
          "price": priceController.text,
        });
        itemController.clear();
        priceController.clear();
      });
    }
  }

  void _removePriceInfo(int index) {
    setState(() {
      if (_priceList.isNotEmpty) {
        _priceList.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB9FDF9),
        title: const Text(
          '가격정보 입력',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "선택한 장소의 가격정보가 있나요?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // ✅ "가격정보 등록" 버튼
            GestureDetector(
              onTap: () => _togglePriceInputs(true),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: _showPriceInputs ? Colors.pink[100] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    "예, 가격 정보를 등록하겠습니다.",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ✅ "가격정보 없음" 버튼
            GestureDetector(
              onTap: () => _togglePriceInputs(false),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: !_showPriceInputs ? Colors.pink[50] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    "아니요, 가격 정보가 없거나 필요하지 않습니다.",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ✅ 가격 정보 입력 UI (선택 시만 표시)
            if (_showPriceInputs) ...[
              const Text(
                "가격표 사진을 등록해주세요.",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  // ✅ 이미지 업로드 기능 추가 가능
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.add, size: 40, color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "가격 정보를 추가해주세요.",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // ✅ 가격 정보 입력 필드
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: itemController,
                      decoration: InputDecoration(
                        hintText: "상품명 입력",
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "가격 입력",
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.pink),
                    onPressed: _addPriceInfo,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ✅ 가격 정보 리스트 (비어 있으면 표시 안 함)
              if (_priceList.isNotEmpty)
                Column(
                  children: List.generate(
                    _priceList.length,
                    (index) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${_priceList[index]["item"]} - ${_priceList[index]["price"]}원",
                            style: const TextStyle(fontSize: 14),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removePriceInfo(index),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],

            // ✅ "다음 단계로" 버튼 (항상 활성화)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink[100],
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PlaceAdditionalInfoPage(),
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

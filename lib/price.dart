import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'placeadd.dart';

class PriceInfoPage extends StatefulWidget {
  final Map<String, dynamic>
      placeData; // 'place_name', 'address', 'main_category', 'sub_category' 등

  const PriceInfoPage({super.key, required this.placeData});

  @override
  _PriceInfoPageState createState() => _PriceInfoPageState();
}

class _PriceInfoPageState extends State<PriceInfoPage> {
  bool _showPriceInputs = false;
  List<Map<String, String>> _priceList = [];
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
      _priceList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB9FDF9),
        title: Text("'${widget.placeData['place_name']}'의 가격정보"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const Text("가격 정보를 입력해주세요.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            // 버튼들을 Column으로 세로로 표시
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () => _togglePriceInputs(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _showPriceInputs ? Colors.cyan[100] : Colors.grey[300],
                  ),
                  child: const Text("예, 가격 정보를 등록합니다."),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _togglePriceInputs(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        !_showPriceInputs ? Colors.cyan[50] : Colors.grey[300],
                  ),
                  child: const Text("아니요, 가격 정보가 없습니다."),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_showPriceInputs) ...[
              const Text(
                "가격표 사진을 등록해주세요.",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  // 이미지 업로드 기능 추가 가능
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
              if (_priceList.isNotEmpty)
                Column(
                  children: _priceList.map((price) {
                    return ListTile(
                      title: Text("${price["item"]} - ${price["price"]}원"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            _removePriceInfo(_priceList.indexOf(price)),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 20),
            ],
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.pink[100]),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PlaceAdditionalInfoPage(
                      placeData: widget.placeData,
                      priceList: _priceList,
                    ),
                  ),
                );
              },
              child: const Center(
                child: Text("다음 단계로",
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

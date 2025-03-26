import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class PlaceInPageUIOnly extends StatefulWidget {
  // 다른 화면에서 'place_name', 'images', 'description', 'operating_hours', 'phone', 'address', 'main_category', 'sub_category', 'hashtags' 등 UI에 필요한 데이터를 넘긴다고 가정
  final Map<String, dynamic> payload;

  const PlaceInPageUIOnly({super.key, required this.payload});

  @override
  State<PlaceInPageUIOnly> createState() => _PlaceInPageUIOnlyState();
}

class _PlaceInPageUIOnlyState extends State<PlaceInPageUIOnly>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 지도에 표시할 좌표 (NLatLng). 초기엔 null
  NLatLng? _mapLatLng;

  @override
  void initState() {
    super.initState();
    // 탭: 가격정보 / 장소정보 / 리뷰
    _tabController = TabController(length: 3, vsync: this);
    _fetchCoordinates(); // 주소로부터 좌표 얻기
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 주소를 기반으로 네이버 지오코딩 API를 호출하여 좌표를 얻는 함수
  Future<void> _fetchCoordinates() async {
    final address = widget.payload['address'] as String? ?? '';
    if (address.isEmpty) return;

    final clientId = dotenv.env['NAVER_MAP_CLIENT_ID'];
    final clientSecret = dotenv.env['NAVER_MAP_CLIENT_SECRET'];
    if (clientId == null || clientSecret == null) {
      debugPrint("❌ .env에 NAVER_MAP_CLIENT_ID / NAVER_MAP_CLIENT_SECRET 설정 필요");
      return;
    }

    final url = "https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode"
        "?query=${Uri.encodeComponent(address)}";
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "X-NCP-APIGW-API-KEY-ID": clientId,
          "X-NCP-APIGW-API-KEY": clientSecret,
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final addresses = data['addresses'] as List;
        if (addresses.isNotEmpty) {
          final lat = double.parse(addresses[0]['y']);
          final lng = double.parse(addresses[0]['x']);
          setState(() {
            _mapLatLng = NLatLng(lat, lng);
          });
        }
      } else {
        debugPrint("❌ 지오코딩 실패: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ 지오코딩 오류: $e");
    }
  }

  /// 지도 위젯 (네이버 지도 API 사용, 테두리/둥근 모서리 적용)
  Widget _buildMapView(String address) {
    if (_mapLatLng == null) {
      return SizedBox(
        height: 200,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16), // 좌우 여백
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // 모서리 둥글게
        border: Border.all(
          color: Colors.grey, // 테두리 색상
          width: 2, // 테두리 두께
        ),
      ),
      child: SizedBox(
        height: 200,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12), // 내부 지도 모서리에 맞춤
          child: NaverMap(
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: _mapLatLng!,
                zoom: 15,
              ),
            ),
            onMapReady: (NaverMapController controller) async {
              // 마커 생성 및 추가
              final marker = NMarker(
                id: 'myMarker',
                position: _mapLatLng!,
                caption: NOverlayCaption(text: "주소: $address"),
              );
              await controller.addOverlay(marker);
            },
          ),
        ),
      ),
    );
  }

  // 대표 이미지 위젯 (images 리스트 중 첫 번째만 표시, 없으면 "대표 이미지 없음")
  Widget _buildTopImage() {
    final images = widget.payload['images'] as List<dynamic>?;
    if (images != null && images.isNotEmpty) {
      final firstImage = images.first;
      return Container(
        width: double.infinity,
        height: 150,
        color: Colors.grey[300],
        child: Image.file(
          File(firstImage.toString()),
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        height: 150,
        color: Colors.grey[300],
        child: const Center(
          child: Text("대표 이미지 없음", style: TextStyle(fontSize: 16)),
        ),
      );
    }
  }

  // 가격정보 탭 (UI 예시)
  Widget _buildPriceTab() {
    return const Center(
      child: Text("가격정보 탭 예시 (기능 없음)", style: TextStyle(fontSize: 16)),
    );
  }

  // 장소정보 탭 (UI 및 지도 기능 포함)
  Widget _buildPlaceInfoTab() {
    // payload에서 UI 표시용 데이터 가져오기
    final placeName = widget.payload['place_name'] ?? "장소 이름";
    final description = widget.payload['description'] ?? "장소 소개글 없음";
    final operatingHours =
        widget.payload['operating_hours'] as Map<String, dynamic>?;
    final phone = widget.payload['phone'] ?? "연락처 없음";
    final address = widget.payload['address'] ?? "주소 없음";
    final mainCategory = widget.payload['main_category'] ?? "메인카테고리";
    final subCategory = widget.payload['sub_category'] ?? "세부카테고리";
    final category = "$mainCategory / $subCategory";
    final hashtags = widget.payload['hashtags'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(placeName,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(category,
              style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 8),
          hashtags.isNotEmpty
              ? Wrap(
                  spacing: 8,
                  children: hashtags
                      .map((tag) => Chip(label: Text(tag.toString())))
                      .toList(),
                )
              : Container(),
          const SizedBox(height: 16),
          Text(description, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 16),
          const Text("영업시간",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          if (operatingHours == null)
            const Text("영업시간 정보 없음", style: TextStyle(fontSize: 14))
          else
            ...operatingHours.entries.map((entry) {
              final day = entry.key;
              final dayVal = entry.value;
              if (dayVal is Map) {
                final start = dayVal["start"] ?? "??:??";
                final end = dayVal["end"] ?? "??:??";
                return Text("$day: $start ~ $end",
                    style: const TextStyle(fontSize: 14));
              } else if (dayVal is String && dayVal == "휴무") {
                return Text("$day: 휴무", style: const TextStyle(fontSize: 14));
              } else {
                return Text("$day: 알 수 없음",
                    style: const TextStyle(fontSize: 14));
              }
            }),
          const SizedBox(height: 16),
          const Text("연락처",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(phone, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 16),
          const Text("주소",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(address,
              style: const TextStyle(fontSize: 14, color: Colors.black54)),
          const SizedBox(height: 10),
          _buildMapView(address), // 실제 네이버 지도 위젯
        ],
      ),
    );
  }

  // 리뷰 탭 (UI 예시)
  Widget _buildReviewTab() {
    return const Center(
      child: Text("리뷰 탭 예시 (기능 없음)", style: TextStyle(fontSize: 16)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // payload에서 제목으로 사용할 place_name
    final placeName = widget.payload['place_name'] ?? "장소 이름";

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        // 상단바 (수정/등록 버튼 제거)
        body: Column(
          children: [
            Container(
              height: MediaQuery.of(context).padding.top,
              color: const Color(0xFFB9FDF9),
            ),
            Container(
              color: const Color(0xFFB9FDF9),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Center(
                child: Text(
                  placeName,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  _buildTopImage(),
                  Container(
                    color: Colors.cyan[50],
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.black54,
                      indicatorColor: Colors.red,
                      tabs: const [
                        Tab(text: "가격정보"),
                        Tab(text: "장소정보"),
                        Tab(text: "리뷰"),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildPriceTab(),
                        _buildPlaceInfoTab(),
                        _buildReviewTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

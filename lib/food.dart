import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'foodplace.dart';
import 'dart:io';
import 'constants.dart';
import 'package:provider/provider.dart';
import 'constants.dart';
import 'user_provider.dart';

/// FavoriteIcon 위젯: 하트 아이콘을 토글하는 상태
import 'package:flutter/material.dart';

/// 즐겨찾기(하트) 버튼을 누르면 바텀시트가 열리는 위젯
class FavoriteIcon extends StatelessWidget {
  final Map<String, dynamic> place; // 어떤 장소인지 전달

  const FavoriteIcon({Key? key, required this.place}) : super(key: key);

  void _showCollectionSelectSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 키보드 대응
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (BuildContext context) {
        return CollectionSelectSheet(place: place);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.favorite_border, color: Colors.grey),
      onPressed: () {
        _showCollectionSelectSheet(context);
      },
    );
  }
}

/// 콜렉션 선택 바텀시트 – 실제 서버에서 콜렉션 목록을 불러올 수 있도록 추후 API 호출로 대체 가능
class CollectionSelectSheet extends StatefulWidget {
  final Map<String, dynamic> place; // 어떤 장소를 콜렉션에 추가할지

  const CollectionSelectSheet({Key? key, required this.place})
      : super(key: key);

  @override
  _CollectionSelectSheetState createState() => _CollectionSelectSheetState();
}

class _CollectionSelectSheetState extends State<CollectionSelectSheet> {
  Future<List<dynamic>>? _collectionsFuture;
  String? selectedCollection; // 선택한 콜렉션의 id

  @override
  void initState() {
    super.initState();

    // userProvider에서 userId를 가져와서 서버에서 콜렉션 목록 불러오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.userId;
      if (userId != null) {
        setState(() {
          _collectionsFuture = fetchCollections(userId);
        });
      }
    });
  }

  Future<List<dynamic>> fetchCollections(int userId) async {
    final url = Uri.parse('$BASE_URL/zzim/collections/$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["collections"] as List<dynamic>;
      } else {
        print(
            'Failed to fetch collections: ${response.statusCode} ${response.body}');
        return [];
      }
    } catch (error) {
      print('Error fetching collections: $error');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 상단 구분선
            Container(
              height: 6,
              width: 40,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const Text(
              "콜렉션에 추가",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // "새 콜렉션 만들기" 버튼 (테두리만 있는 버튼, 내부 채우지 않음)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.cyan,
                  side: const BorderSide(color: Colors.cyan),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // TODO: "새 콜렉션 만들기" 기능 구현
                },
                child: const Text("새 콜렉션 만들기"),
              ),
            ),
            const SizedBox(height: 16),
            // 콜렉션 목록 표시 (여기서는 FutureBuilder로 불러옴)
            FutureBuilder<List<dynamic>>(
              future: _collectionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("오류 발생: ${snapshot.error}"));
                } else {
                  final collections = snapshot.data ?? [];
                  if (collections.isEmpty) {
                    return const Text("등록된 콜렉션이 없습니다.");
                  }
                  return Column(
                    children: [
                      for (var coll in collections) _buildCollectionRow(coll),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            // 저장 버튼 (전체 가로)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  if (selectedCollection == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('콜렉션을 선택해주세요.')),
                    );
                    return;
                  }
                  // selectedCollection은 문자열 형태의 collection id
                  int collectionId = int.parse(selectedCollection!);
                  // widget.place에서 place id 추출 (필드명이 'id'라고 가정)
                  int placeId = widget.place['id'];
                  // API 호출 함수 (추후 addPlaceToCollection 함수와 연동)
                  bool success =
                      await addPlaceToCollection(collectionId, placeId);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('장소가 콜렉션에 추가되었습니다.')),
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('장소 추가에 실패했습니다.')),
                    );
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Text("저장", style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // 각 콜렉션 항목 UI
  Widget _buildCollectionRow(dynamic collection) {
    final String collName = collection['collection_name'] ?? '제목 없음';
    final String collId = collection['id'].toString();
    return InkWell(
      onTap: () {
        setState(() {
          selectedCollection = collId;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(collName,
                  style: const TextStyle(fontSize: 14, color: Colors.black)),
            ),
            if (selectedCollection == collId)
              const Icon(Icons.check, color: Colors.cyan),
          ],
        ),
      ),
    );
  }
}

/// API 요청 함수: collection_places에 장소 추가
Future<bool> addPlaceToCollection(int collectionId, int placeId) async {
  final url = Uri.parse('$BASE_URL/zzim/collection_places');
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'collection_id': collectionId,
        'place_id': placeId,
      }),
    );
    if (response.statusCode == 201) {
      print('Place added to collection successfully: ${response.body}');
      return true;
    } else {
      print(
          'Failed to add place to collection: ${response.statusCode} ${response.body}');
      return false;
    }
  } catch (e) {
    print('Error adding place to collection: $e');
    return false;
  }
}

class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  @override
  _FoodPageState createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  String selectedMainCategory = '먹기';
  String? selectedCity;
  String? selectedDistrict;
  String? selectedNeighborhood;
  String? selectedRecommendation; // 선택된 추천 방식
  bool isLoading = false; // ← 로딩 플래그 추가

  Map<String, dynamic> regionData = {}; // 지역 데이터 저장
  final List<String> recommendationMethods = ['MBTI', '성향', '찜순', '평점순'];
  int totalPages = 5; // 전체 페이지 수 (필요시)
  int currentPage = 1; // 현재 선택된 페이지

  // DB에서 등록된 장소 데이터를 저장할 리스트
  List<Map<String, dynamic>> registeredPlaces = [];

  @override
  void initState() {
    super.initState();
    _loadRegions(); // JSON 데이터 불러오기
    _fetchRegisteredPlaces(); // 등록된 장소 불러오기
  }

  // 지역 JSON 파일 로드
  Future<void> _loadRegions() async {
    String data = await rootBundle.loadString('assets/regions.json');
    setState(() {
      regionData = json.decode(data);
    });
  }

  // DB에서 장소 데이터를 불러오고, "먹기" 카테고리만 필터링
  Future<void> _fetchRegisteredPlaces() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(Uri.parse("$BASE_URL/places"));
      if (response.statusCode == 200) {
        final List<dynamic> raw = json.decode(response.body);

        // --- 디버그: 첫 5개 아이템의 키와 'address' 필드 찍어 보기
        if (raw.isNotEmpty) {
          print("=== place[0] keys: ${(raw[0] as Map).keys.toList()}");
          raw.take(5).forEach((p) => print("address: ${p['address']}"));
        }

        // 기존 필터링 로직…
        final filtered = raw
            .where((place) {
              final p = place as Map<String, dynamic>;

              // 1) 카테고리 체크
              if (p['main_category'] != '먹기') return false;

              // 2) city 키가 없다면 p['address'] 문자열로 대체
              final addr = (p['address'] ?? '') as String;
              if (selectedCity != null && !addr.contains(selectedCity!))
                return false;

              // 3) 필요하다면 district/neighborhood 도 마찬가지로 처리
              if (selectedDistrict != null && !addr.contains(selectedDistrict!))
                return false;
              if (selectedNeighborhood != null &&
                  !addr.contains(selectedNeighborhood!)) return false;

              return true;
            })
            .cast<Map<String, dynamic>>()
            .toList();

        setState(() {
          registeredPlaces = filtered;
        });
      } else {
        print("등록된 장소 불러오기 실패: ${response.statusCode}");
      }
    } catch (e) {
      print("등록된 장소 불러오기 오류: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.cyan[100],
        title: const Text('맛집 추천'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // 지역 및 추천 방식 선택 영역
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: _showRegionSelectionDialog,
                      child: Text(
                        selectedCity != null
                            ? [
                                selectedCity,
                                if (selectedDistrict != null) selectedDistrict,
                                if (selectedNeighborhood != null)
                                  selectedNeighborhood,
                              ].join(' ')
                            : '지역 선택',
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
                const Text(
                  "(선택된 방식)으로 추천되는 맛집",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          // 등록된 맛집(먹기 카테고리) 표시 GridView
          Expanded(
            child: () {
              if (isLoading) {
                // 1) 요청 중
                return const Center(child: CircularProgressIndicator());
              } else if (registeredPlaces.isEmpty) {
                // 2) 로딩 완료 후 데이터 없음
                return const Center(child: Text("해당 조건에 맞는 장소가 없습니다."));
              } else {
                // 3) 데이터 있음
                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: registeredPlaces.length,
                  itemBuilder: (c, idx) =>
                      _buildFoodCard(registeredPlaces[idx]),
                );
              }
            }(),
          ),
          // 페이지네이션 버튼 (필요시)
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
                      // 페이지 변경 시 _fetchRegisteredPlaces() 재호출 가능
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor:
                        currentPage == index + 1 ? Colors.blue : Colors.grey,
                  ),
                  child: Text("${index + 1}"),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 추천 방식 선택 드롭다운 UI
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

  // 지역 선택 다이얼로그 UI
  void _showRegionSelectionDialog() {
    String? tempCity = selectedCity;
    String? tempDistrict = selectedDistrict;
    String? tempNeighborhood = selectedNeighborhood;
    List<String> tempDistricts =
        tempCity != null ? List<String>.from(regionData[tempCity]!.keys) : [];
    List<String> tempNeighborhoods = (tempCity != null && tempDistrict != null)
        ? List<String>.from(regionData[tempCity]![tempDistrict]!)
        : [];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text("지역 선택"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 시/도 선택
                  DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text("시/도 선택"),
                    value: tempCity,
                    items: regionData.keys.map((city) {
                      return DropdownMenuItem(
                        value: city,
                        child: Text(city),
                      );
                    }).toList(),
                    onChanged: (city) {
                      setDialogState(() {
                        tempCity = city;
                        tempDistrict = null;
                        tempNeighborhood = null;
                        tempDistricts = city != null
                            ? List<String>.from(regionData[city]!.keys)
                            : [];
                        tempNeighborhoods = [];
                      });
                      _fetchRegisteredPlaces(); // 재호출
                    },
                  ),
                  const SizedBox(height: 8),

                  // 구/군 선택
                  DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text("구/군 선택"),
                    value: tempDistrict,
                    items: tempDistricts.map((district) {
                      return DropdownMenuItem(
                        value: district,
                        child: Text(district),
                      );
                    }).toList(),
                    onChanged: (district) {
                      setDialogState(() {
                        tempDistrict = district;
                        tempNeighborhood = null;
                        tempNeighborhoods =
                            (tempCity != null && district != null)
                                ? List<String>.from(
                                    regionData[tempCity]![district]!)
                                : [];
                      });
                      _fetchRegisteredPlaces(); // 재호출
                    },
                  ),
                  const SizedBox(height: 8),

                  // 동/읍/면 선택
                  DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text("동/읍/면 선택"),
                    value: tempNeighborhood,
                    items: tempNeighborhoods.map((nbh) {
                      return DropdownMenuItem(
                        value: nbh,
                        child: Text(nbh),
                      );
                    }).toList(),
                    onChanged: (nbh) {
                      setDialogState(() {
                        tempNeighborhood = nbh;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text("확인"),
                  onPressed: () {
                    setState(() {
                      selectedCity = tempCity;
                      selectedDistrict = tempDistrict;
                      selectedNeighborhood = tempNeighborhood;
                    });
                    _fetchRegisteredPlaces();

                    Navigator.pop(ctx);
                    _fetchRegisteredPlaces();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // FoodCard 위젯: 등록된 장소 데이터를 표시 (이미지와 장소 이름, 우측에 하트 아이콘)
  // FoodPage.dart 내 _buildFoodCard 함수
  // FoodCard 위젯: 등록된 장소 데이터를 표시 (이미지와 장소 이름, 우측에 FavoriteIcon)
  Widget _buildFoodCard(Map<String, dynamic> place) {
    String imageUrl = "";
    if (place['images'] != null &&
        place['images'] is List &&
        place['images'].isNotEmpty) {
      imageUrl = place['images'][0].toString();
    }
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaceInPageUIOnly(payload: place),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 영역
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(10)),
                ),
                child: imageUrl.isNotEmpty
                    ? (imageUrl.startsWith("http")
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                        : Image.file(
                            File(imageUrl),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ))
                    : const Center(
                        child: Text("이미지 없음", style: TextStyle(fontSize: 16)),
                      ),
              ),
            ),
            // 장소 이름 및 정보, 우측에 FavoriteIcon
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place['place_name'] ?? "장소 이름",
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const Text("추천수: 00  평점: 0.0",
                            style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  // FavoriteIcon에 해당 장소 데이터를 전달
                  FavoriteIcon(place: place),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

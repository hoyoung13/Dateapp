import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'my.dart';
import 'food.dart';
import 'cafe.dart';
import 'play.dart';
import 'see.dart';
import 'walk.dart';
import 'board.dart';
import 'navermap.dart';
import 'zzim.dart';
import 'course.dart';

void main() {
  runApp(const HomePage());
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // 🔹 현재 선택된 탭 인덱스

  // 🔹 페이지 목록
  final List<Widget> _pages = [
    const HomeContent(),
    const Center(child: Text('💬 커뮤니티 화면')),
    const ZzimPage(),
    const Center(child: Text('🎉 EVENT 화면')),
    const MyPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan[100], // 🔹 상단바 색상 설정
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'DATE IT',
              style: TextStyle(
                fontSize: 20, // 글자 크기
                fontWeight: FontWeight.bold, // Bold
                fontStyle: FontStyle.italic, // Italic
              ),
            ), // 🔹 앱 이름
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {}, // 🔹 검색 버튼
                ),
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {}, // 🔹 메뉴 버튼
                ),
              ],
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex], // 🔹 선택된 페이지 표시

      // 🔹 하단 네비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 4) {
            Navigator.of(context)
                .pushReplacement(_noAnimationRoute(const MyPage()));
          } else if (index == 1) {
            Navigator.of(context)
                .pushReplacement(_noAnimationRoute(const BoardPage()));
          } else if (index == 2) {
            Navigator.of(context)
                .pushReplacement(_noAnimationRoute(const ZzimPage()));
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'HOME'),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: '커뮤니티'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: '찜 목록'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'EVENT'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'MY'),
        ],
      ),
    );
  }
}

Route _noAnimationRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return child; // 애니메이션 효과 제거
    },
  );
}

// 📌 홈 화면 콘텐츠 (HOME 탭)
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String? selectedCity; // 🔹 선택된 시/도
  String? selectedDistrict; // 🔹 선택된 구/군
  String? selectedNeighborhood; // 🔹 선택된 동
  Map<String, dynamic> regionData = {}; // 🔹 지역 데이터 저장할 변수
  int _currentBannerIndex = 0; // 🔹 현재 배너 이미지 인덱스
  final PageController _bannerController = PageController(); // 🔹 배너 슬라이더 컨트롤러

  @override
  void initState() {
    super.initState();
    _loadRegions(); // ✅ 앱 실행 시 JSON 데이터 불러오기
  }

  // 🔹 배너 이미지 리스트
  final List<String> _bannerImages = [
    'img/banner1.png',
    'img/banner2.png',
    'img/banner3.png',
    'img/banner4.png',
    'img/banner5.png',
    'img/banner6.png',
    'img/banner7.png',
  ];
  // ✅ JSON 파일에서 지역 데이터 불러오기
  Future<void> _loadRegions() async {
    String data =
        await rootBundle.loadString('assets/regions.json'); // 🔹 JSON 파일 읽기
    setState(() {
      regionData = json.decode(data); // 🔹 JSON 파싱 후 저장
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _bannerImage(), // 🔹 배너 이미지 추가
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceAround, // ✅ 간격 조정 (공간 활용)
                  children: [
                    _categoryButton('맛집', 'assets/icons/food.png', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FoodPage()),
                      );
                    }),
                    _categoryButton('카페', 'assets/icons/cafe.png', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CafePage()),
                      );
                    }),
                    _categoryButton('장소', 'assets/icons/place.png', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const WalkPage()),
                      );
                    }),
                    _categoryButton('놀거리', 'assets/icons/play.png', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PlayPage()),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceAround, // ✅ 간격 조정 (공간 활용)
                  children: [
                    _categoryButton('코스 제작', 'assets/icons/course.png', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CourseCreationPage()),
                      );
                    }),
                    _categoryButton('AI 코스', 'assets/icons/ai.png', () {}),
                    _categoryButton(
                        '사용자 코스', 'assets/icons/user_course.png', () {}),
                    _categoryButton(
                        '축제 행사', 'assets/icons/festival.png', () {}),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 🔹 회색 구분선 추가
          Container(
            width: double.infinity,
            height: 8,
            color: Colors.grey.shade300, // 회색 배경
          ),

          const SizedBox(height: 10),

          // 🔹 "지역 선택" 버튼 (랭킹 위로 이동)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: GestureDetector(
              onTap: () {
                _showRegionSelectionDialog();
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  selectedCity ?? '지역 선택',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),

          // 🔹 랭킹 리스트
          _rankingSection(_getRankingTitle("데이트 장소 랭킹"),
              ['img/img5.jpg', 'img/img4.jpg', 'img/img9.jpg']),
          _rankingSection(_getRankingTitle("데이트 맛집 랭킹"),
              ['img/img1.jpg', 'img/img2.jpg', 'img/img3.jpg']),
          _rankingSection(_getRankingTitle("데이트 카페 랭킹"),
              ['img/img6.jpg', 'img/img7.jpg', 'img/img8.jpg']),
        ],
      ),
    );
  }

// ✅ 새로운 버튼 스타일 (이미지 + 텍스트, 가로 늘림)
  Widget _categoryButton(String text, String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Image.asset(
            imagePath,
            width: 65, // ✅ 기존보다 가로를 넓힘
            height: 55, // ✅ 기존보다 세로를 살짝 줄임
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 3), // ✅ 텍스트와 이미지 간격 줄이기
          Text(
            text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

// ✅ 배너 이미지 슬라이더 (좌우 스크롤 가능)
  Widget _bannerImage() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: _bannerImages.length,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index; // 🔹 현재 페이지 인덱스 업데이트
              });
            },
            itemBuilder: (context, index) {
              return Image.asset(
                _bannerImages[index],
                fit: BoxFit.cover,
                width: double.infinity,
              );
            },
          ),
        ),

        // 🔹 배너 이미지 개수 표시 (1/7 형식)
        Positioned(
          bottom: 10,
          right: 15,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "${_currentBannerIndex + 1}/${_bannerImages.length}",
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  // ✅ 랭킹 제목 설정 함수
  String _getRankingTitle(String baseTitle) {
    if (selectedCity == null) {
      return "이번주 $baseTitle";
    }
    return "이번주 ${selectedCity ?? ''} ${selectedDistrict ?? ''} ${selectedNeighborhood ?? ''} $baseTitle";
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
}

// ✅ 카테고리 버튼
Widget _categoryRow(List<String> categories) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: categories.map((text) => _categoryText(text)).toList(),
  );
}

Widget _categoryText(String text) {
  return Expanded(
    child: Center(
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),
  );
}

// ✅ 랭킹 섹션
Widget _rankingSection(String title, List<String> imagePaths) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton(onPressed: () {}, child: const Text('더보기')),
          ],
        ),
      ),
      SizedBox(
        height: 120,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: imagePaths.map((path) => _imageCard(path)).toList(),
        ),
      ),
    ],
  );
}

// ✅ 배너 이미지
Widget _bannerImage() {
  return Container(
    width: double.infinity,
    height: 150,
    decoration: const BoxDecoration(
      image: DecorationImage(
        image: AssetImage('img/banner1.png'),
        fit: BoxFit.cover,
      ),
    ),
  );
}

// ✅ 이미지 카드
Widget _imageCard(String imagePath) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(imagePath, width: 150, height: 100, fit: BoxFit.cover),
    ),
  );
}

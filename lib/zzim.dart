import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'constants.dart';
import 'home.dart';
import 'my.dart';
import 'board.dart';
import 'user_provider.dart';
import 'zzimdetail.dart';
import 'coursedetail.dart';
import 'schedule_item.dart';
import 'dart:io';

class ZzimPage extends StatefulWidget {
  const ZzimPage({Key? key}) : super(key: key);

  @override
  State<ZzimPage> createState() => _ZzimPageState();
}

class _ZzimPageState extends State<ZzimPage> {
  int _selectedIndex = 2;

  /// "장소" 탭(true) / "코스" 탭(false) 구분
  bool isPlaceSelected = true;

  /// 장소(콜렉션) 목록 Future
  Future<List<dynamic>>? _collectionsFuture;

  /// 코스 목록 Future
  Future<List<dynamic>>? _coursesFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.userId;
      if (userId != null) {
        // 장소(콜렉션) 목록
        setState(() {
          _collectionsFuture = fetchCollections(userId);
        });
        // 코스 목록
        setState(() {
          _coursesFuture = fetchCourses(userId);
        });
      }
    });
  }

  /// 장소(콜렉션) 목록 불러오기
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

  /// 코스 목록 불러오기 (백엔드에 맞게 수정 필요)
  Future<List<dynamic>> fetchCourses(int userId) async {
    final url = Uri.parse('$BASE_URL/course/user_courses/$userId');
    // ↑ 예: GET /course/user_courses/:userId 형태로 백엔드 구현했다고 가정
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["courses"] as List<dynamic>; // 백엔드 응답 구조에 맞게 수정
      } else {
        print(
            'Failed to fetch courses: ${response.statusCode} ${response.body}');
        return [];
      }
    } catch (error) {
      print('Error fetching courses: $error');
      return [];
    }
  }

  /// 콜렉션 생성 (기존)
  Future<void> createCollection(int userId, String collectionName,
      String description, bool isPublic) async {
    final url = Uri.parse('$BASE_URL/zzim/collections');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'collection_name': collectionName,
          'description': description,
          'thumbnail': null,
          'is_public': isPublic,
        }),
      );
      if (response.statusCode == 201) {
        print('Collection created successfully: ${response.body}');
        // 다시 목록 갱신
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        if (userProvider.userId != null) {
          setState(() {
            _collectionsFuture = fetchCollections(userProvider.userId!);
          });
        }
      } else {
        print('Failed to create collection: ${response.body}');
      }
    } catch (error) {
      print('Error creating collection: $error');
    }
  }

  /// "콜렉션 추가" 다이얼로그
  void _showCollectionDialog() {
    String collectionName = '';
    String collectionDescription = '';
    bool isPublic = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 상단 제목 및 닫기 버튼
                      Stack(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                '콜렉션 이름을 입력해주세요',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: InkWell(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(Icons.close),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 콜렉션 이름
                      TextField(
                        maxLength: 20,
                        decoration: const InputDecoration(
                          labelText: '콜렉션 이름',
                          hintText: '예) 나만의 데이트 장소',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setDialogState(() {
                            collectionName = value;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      // 콜렉션 설명
                      TextField(
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: '(선택) 콜렉션 설명',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setDialogState(() {
                            collectionDescription = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // 공개 / 비공개
                      Row(
                        children: [
                          Radio<bool>(
                            activeColor: Colors.cyan,
                            value: true,
                            groupValue: isPublic,
                            onChanged: (bool? value) {
                              setDialogState(() {
                                isPublic = value ?? true;
                              });
                            },
                          ),
                          const Text('공개'),
                          const SizedBox(width: 20),
                          Radio<bool>(
                            activeColor: Colors.cyan,
                            value: false,
                            groupValue: isPublic,
                            onChanged: (bool? value) {
                              setDialogState(() {
                                isPublic = value ?? false;
                              });
                            },
                          ),
                          const Text('비공개'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        onPressed: () async {
                          final userProvider =
                              Provider.of<UserProvider>(context, listen: false);
                          final currentUserId = userProvider.userId;
                          if (currentUserId == null) {
                            print("사용자 정보가 없습니다.");
                            return;
                          }
                          await createCollection(
                            currentUserId,
                            collectionName,
                            collectionDescription,
                            isPublic,
                          );
                          Navigator.pop(context);
                        },
                        child: const Text(
                          '저장',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 코스 목록을 표시할 카드 UI 예시
  Widget _buildCourseCard(dynamic course) {
    final String courseName = course['course_name'] ?? '코스 이름 없음';
    final List<String> withWho =
        (course['with_who'] as List?)?.cast<String>() ?? [];
    final List<String> purpose =
        (course['purpose'] as List?)?.cast<String>() ?? [];
    final List<String> hashtags =
        (course['hashtags'] as List?)?.cast<String>() ?? [];
    final List<dynamic> schedules = course['schedules'] ?? [];

    return GestureDetector(
        onTap: () {
          final courseName = course['course_name'] ?? '코스 이름 없음';
          final courseDesc = course['course_description'] ?? '';
          final withWho = (course['with_who'] as List?)?.cast<String>() ?? [];
          final purpose = (course['purpose'] as List?)?.cast<String>() ?? [];
          final hashtags = (course['hashtags'] as List?)?.cast<String>() ?? [];
          final schedulesRaw = course['schedules'] as List<dynamic>? ?? [];
          // List<ScheduleItem> 로 변환 (ScheduleItem.fromJson()이 정의되어 있다고 가정)
          final scheduleItems = schedulesRaw.map((e) {
            return ScheduleItem.fromJson(e as Map<String, dynamic>);
          }).toList();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CourseDetailPage(
                courseName: courseName,
                courseDescription: courseDesc,
                withWho: withWho,
                purpose: purpose,
                hashtags: hashtags,
                schedules: scheduleItems,
              ),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 코스 이름
              Text(
                courseName,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              // 누구랑 / 무엇을
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ...withWho.map((w) => _buildChip(w, Colors.pink.shade50)),
                  ...purpose.map((p) => _buildChip(p, Colors.yellow.shade50)),
                ],
              ),
              const SizedBox(height: 4),
              // 해시태그
              if (hashtags.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: hashtags.map((tag) {
                    return _buildChip('#$tag', Colors.green.shade50);
                  }).toList(),
                ),
              const SizedBox(height: 8),
              // 장소들 (schedules) - 가로 스크롤
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: schedules.length,
                  itemBuilder: (context, index) {
                    final sch = schedules[index];
                    final String placeName = sch['place_name'] ?? '장소';
                    final String? placeImage = sch['place_image'];
                    Widget imageWidget;
                    if (placeImage != null && placeImage.isNotEmpty) {
                      if (placeImage.startsWith('http')) {
                        // 네트워크 이미지
                        imageWidget = Image.network(
                          placeImage,
                          fit: BoxFit.cover,
                          width: 80,
                        );
                      } else if (placeImage.startsWith('/data/') ||
                          placeImage.startsWith('file://')) {
                        // 로컬 파일 경로
                        imageWidget = Image.file(
                          File(placeImage),
                          fit: BoxFit.cover,
                          width: 80,
                        );
                      } else {
                        // 그 외 상대 경로인 경우 BASE_URL을 붙여서 네트워크 이미지로 처리
                        final fullImageUrl = '$BASE_URL$placeImage';
                        imageWidget = Image.network(
                          fullImageUrl,
                          fit: BoxFit.cover,
                          width: 80,
                        );
                      }
                    } else {
                      imageWidget = Container(
                        width: 80,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.image_not_supported),
                      );
                    }

                    return Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: imageWidget,
                          ),
                          // 장소 이름
                          Text(
                            placeName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              // 공유 / 편집 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      // TODO: 공유 로직 구현
                    },
                    child: const Text("공유"),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: 편집 로직 (코스 수정 페이지 이동 등)
                    },
                    child: const Text("편집"),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  Widget _buildChip(String label, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  /// bottomNavigationBar에서 다른 페이지로 이동 시 애니메이션 제거
  Route _noAnimationRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(seconds: 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFC0FDF9),
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        titleSpacing: 0,
        title: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Text(
            '찜 목록',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // "장소 / 코스" 탭
          Container(
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        isPlaceSelected = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isPlaceSelected
                                ? Colors.cyan
                                : Colors.transparent,
                            width: 2.0,
                          ),
                        ),
                      ),
                      child: Text(
                        '장소',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: isPlaceSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        isPlaceSelected = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: !isPlaceSelected
                                ? Colors.cyan
                                : Colors.transparent,
                            width: 2.0,
                          ),
                        ),
                      ),
                      child: Text(
                        '코스',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: !isPlaceSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // "콜렉션 추가하기" 버튼 (장소 탭일 때만 표시)
          if (isPlaceSelected)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.cyan),
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.white,
              ),
              padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 12),
              margin: const EdgeInsets.symmetric(horizontal: 35, vertical: 8),
              child: TextButton(
                onPressed: _showCollectionDialog,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                ),
                child: const Text("콜렉션 추가하기"),
              ),
            ),

          Container(height: 1, color: Colors.grey.shade300),

          // 탭 분기
          Expanded(
              child: isPlaceSelected
                  ? _buildPlaceTab() // 장소(콜렉션) 목록
                  : _buildCourseTab() // 코스 목록
              ),
        ],
      ),
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
          } else if (index == 0) {
            Navigator.of(context)
                .pushReplacement(_noAnimationRoute(const HomePage()));
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

  /// 장소(콜렉션) 목록 표시 위젯
  Widget _buildPlaceTab() {
    return FutureBuilder<List<dynamic>>(
      future: _collectionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("오류 발생: ${snapshot.error}"));
        } else {
          final collections = snapshot.data ?? [];
          if (collections.isEmpty) {
            return const Center(child: Text("저장된 콜렉션이 없습니다."));
          }
          return ListView.builder(
            itemCount: collections.length,
            itemBuilder: (context, index) {
              final collection = collections[index];
              return ListTile(
                leading: (collection['thumbnail'] != null &&
                        (collection['thumbnail'] as String).isNotEmpty)
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(collection['thumbnail']),
                      )
                    : const CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.collections, color: Colors.white),
                      ),
                title: Text(collection['collection_name'] ?? ''),
                subtitle: Text(
                  collection['is_public'] == true ? '공개' : '비공개',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    // 애니메이션 없이 이동하려면 _noAnimationRoute를 써도 되고,
                    // 일반적으로는 MaterialPageRoute를 사용합니다.
                    MaterialPageRoute(
                      builder: (_) =>
                          CollectionDetailPage(collection: collection),
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }

  /// 코스 목록 표시 위젯
  Widget _buildCourseTab() {
    return FutureBuilder<List<dynamic>>(
      future: _coursesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("오류 발생: ${snapshot.error}"));
        } else {
          final courses = snapshot.data ?? [];
          if (courses.isEmpty) {
            return const Center(child: Text("등록된 코스가 없습니다."));
          }
          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return _buildCourseCard(course); // 위에서 만든 코스 카드
            },
          );
        }
      },
    );
  }
}

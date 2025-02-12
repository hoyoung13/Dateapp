import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'write_post.dart';
import 'home.dart';
import 'my.dart';

class BoardPage extends StatefulWidget {
  const BoardPage({super.key});

  @override
  _BoardPageState createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  int _selectedTabIndex = 0; // ✅ 선택된 탭 인덱스
  int _selectedIndex = 1; // ✅ 기본 선택값 (커뮤니티)

  final List<String> _tabTitles = ["모든 게시판", "질문 게시판", "추천 게시판", "자유 게시판"];
  List<Map<String, dynamic>> _posts = []; // ✅ 게시글 데이터 저장할 리스트

  final List<Widget> _pages = [
    const HomeContent(),
    const Center(child: Text('💬 커뮤니티 화면')),
    const Center(child: Text('❤️ 찜 목록 화면')),
    const Center(child: Text('🎉 EVENT 화면')),
    const MyPage(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchPosts(); // ✅ 초기화할 때 데이터 가져오기
  }

  // ✅ 게시글 데이터 가져오는 함수
  Future<void> _fetchPosts() async {
    try {
      String boardType = _tabTitles[_selectedTabIndex]; // 선택된 게시판
      final response = await http
          .get(Uri.parse("http://172.30.1.17:5000/boards?type=$boardType"));

      if (response.statusCode == 200) {
        setState(() {
          _posts = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        });
      } else {
        print("❌ 게시글 불러오기 실패");
      }
    } catch (e) {
      print("❌ 서버 요청 오류: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.cyan[100],
        title: const Text('게시판'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WritePostPage()),
              );

              if (result == true) {
                _fetchPosts(); // ✅ 새 글 작성 후 게시글 목록 갱신
              }
            },
          ),
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // ✅ 게시판 탭
          Container(
            color: Colors.cyan[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                _tabTitles.length,
                (index) => GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTabIndex = index;
                    });
                    _fetchPosts(); // ✅ 탭 변경 시 데이터 다시 불러오기
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                    child: Text(
                      _tabTitles[index],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: _selectedTabIndex == index
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _selectedTabIndex == index
                            ? Colors.blue
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ✅ 게시글 리스트
          Expanded(
            child: _posts.isEmpty
                ? const Center(child: CircularProgressIndicator()) // ✅ 로딩 표시
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      return _buildPostCard(_posts[index]);
                    },
                  ),
          ),
        ],
      ),
      // ✅ 🔹 하단 네비게이션 바 추가 (home.dart에서 가져옴)
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index != _selectedIndex) {
            if (index == 1) {
              // 커뮤니티 이동 시 BoardPage로 네비게이션
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const BoardPage()),
              );
            } else if (index == 0) {
              // 홈으로 이동 시 HomePage 로 네비게이션
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            } else {
              setState(() {
                _selectedIndex = index;
              });
            }
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

  // ✅ 게시글 카드 UI (수정 & 삭제 버튼 추가)
  Widget _buildPostCard(Map<String, dynamic> post) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/postDetail',
            arguments: post['id']); // ✅ 게시글 상세페이지로 이동
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ 상단 (프로필 이미지, 닉네임, 날짜)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.grey,
                      radius: 15,
                      child: Icon(Icons.person, color: Colors.white, size: 15),
                    ),
                    const SizedBox(width: 8),
                    Text(post["nickname"] ?? "닉네임",
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
                Text(post["created_at"] ?? "날짜",
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),

            const SizedBox(height: 8),

            // ✅ 게시글 내용
            Row(
              children: [
                Text(post["board_name"] ?? "게시판",
                    style: const TextStyle(fontSize: 12, color: Colors.red)),
                const SizedBox(width: 8),
                Text(post["title"] ?? "게시글 제목",
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              post["content"] ?? "게시글 내용",
              style: const TextStyle(fontSize: 13, color: Colors.black),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            // ✅ 하단 (조회수, 좋아요, 싫어요, 댓글, 수정, 삭제)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text("조회수: ${post["views"] ?? 0}",
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(width: 15),
                    Icon(Icons.thumb_up, size: 14, color: Colors.grey),
                    const SizedBox(width: 3),
                    Text("좋아요: ${post["likes"] ?? 0}",
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(width: 15),
                    Icon(Icons.thumb_down, size: 14, color: Colors.grey),
                    const SizedBox(width: 3),
                    Text("싫어요: ${post["dislikes"] ?? 0}",
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),

                // ✅ 수정 & 삭제 버튼
                Row(
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.edit, size: 16, color: Colors.blue),
                      onPressed: () {
                        Navigator.pushNamed(context, '/editPost',
                            arguments: post);
                      },
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.delete, size: 16, color: Colors.red),
                      onPressed: () {
                        _deletePost(post["id"]);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ 게시글 삭제 함수
  Future<void> _deletePost(int postId) async {
    try {
      final response = await http
          .delete(Uri.parse("http://172.30.1.17:5000/boards/$postId"));

      if (response.statusCode == 200) {
        setState(() {
          _posts.removeWhere((post) => post["id"] == postId);
        });
      } else {
        print("❌ 삭제 실패");
      }
    } catch (e) {
      print("❌ 삭제 요청 오류: $e");
    }
  }
}

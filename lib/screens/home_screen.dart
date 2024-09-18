import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'package:socialmediaplatform/screens/add_post.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:socialmediaplatform/screens/search_screen.dart';
import 'package:socialmediaplatform/widgets/post_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    // Replace with your pages for Home, Add, and Profile
    HomePage(),
    AddPostPage(),
    ProfileScreen(),
    Search(),
  ];
  final List<IconData> iconlist = [
    Icons.add,
    Icons.person,
    Icons.home,
    Icons.search,
    // Icons.favorite
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white54,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Row(
          children: [
            Text("ShareMe"),
            SizedBox(width: 8),

          ],
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar:  CurvedNavigationBar(
        backgroundColor: Colors.black,
        buttonBackgroundColor: Colors.teal,
        color: Colors.teal,
        animationCurve: Curves.fastOutSlowIn,
        items: <Widget>[
          Icon(Icons.home,size: 30),
          Icon(Icons.add,size: 30),
          Icon(Icons.person, size: 30),
          Icon(Icons.search,size: 30,)
        ],
        height: 50,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      // body: Container(color: Colors.blueAccent),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: 16),
        Postlist(),
      ],
    );

  }
}

class Postlist extends StatefulWidget {
  const Postlist({Key? key}) : super(key: key);

  @override
  State<Postlist> createState() => _PostlistState();
}

class _PostlistState extends State<Postlist> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> followingUserIds = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getFollowingUsers();
  }

  // Fetching the list of users the current user is following
  Future<void> _getFollowingUsers() async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      QuerySnapshot followingSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('following')
          .get();

      setState(() {
        followingUserIds =
            followingSnapshot.docs.map((doc) => doc.id).toList();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (followingUserIds.isEmpty) {
      return Center(
        child: Text(
          'You are not following anyone',
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('posts')
          .where('userId', whereIn: followingUserIds) // Filter posts by the user's following list
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final posts = snapshot.data!.docs;
        return posts.isEmpty
            ? Center(
          child: Text(
            'No posts available',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ) : ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final postSnapShot = posts[index];
              final post = postSnapShot.data() as Map<String, dynamic>;
              final imageUrl = post['imageUrl'] ?? '';
              final description = post['description'] ?? ''; // Use 'description' instead of 'title'
              final postedDate = post['createdAt'] as String?;
              final dateFormatted = postedDate != null
                  ? _formatDate(postedDate)
                  : 'Unknown Date';
              final postid = postSnapShot.id;
              final userName = post['userName'] ?? 'all';

              return PostCard(
                postId: postid,
                userName: userName,
                postedDate: dateFormatted,
                imageUrl: imageUrl,
                description: description,
              );
            },
          );
      },
    );
  }

  // Helper method to format the date (assumes createdAt is a timestamp string)
  String _formatDate(String timestamp) {
    final DateTime date = DateTime.parse(timestamp);
    return '${date.day}/${date.month}/${date.year}';
  }
}

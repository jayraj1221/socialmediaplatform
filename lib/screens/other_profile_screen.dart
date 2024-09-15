import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:socialmediaplatform/screens/other_profile_postlist.dart';
class OtherProfileScreen extends StatefulWidget {
  final String userId;
  const OtherProfileScreen({required this.userId});

  @override
  _OtherProfileScreenState createState() => _OtherProfileScreenState();
}

class _OtherProfileScreenState extends State<OtherProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    checkIfFollowing();
  }

  Future<void> checkIfFollowing() async {
    final currentUserId = _auth.currentUser!.uid;
    final docSnapshot = await _firestore
        .collection('users')
        .doc(widget.userId)
        .collection('followers')
        .doc(currentUserId)
        .get();

    setState(() {
      isFollowing = docSnapshot.exists;
    });
  }

  Future<void> toggleFollow() async {
    final currentUserId = _auth.currentUser!.uid;

    if (isFollowing) {
      // Unfollow
      await _firestore
          .collection('users')
          .doc(widget.userId)
          .collection('followers')
          .doc(currentUserId)
          .delete();

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(widget.userId)
          .delete();
    } else {
      // Follow
      await _firestore
          .collection('users')
          .doc(widget.userId)
          .collection('followers')
          .doc(currentUserId)
          .set({});

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(widget.userId)
          .set({});
    }

    setState(() {
      isFollowing = !isFollowing;
    });
  }

  Future<int> getPostCount() async {
    final querySnapshot = await _firestore
        .collection('posts')
        .where('userId', isEqualTo: widget.userId)
        .get();
    return querySnapshot.docs.length;
  }

  Future<int> getFollowerCount() async {
    final querySnapshot = await _firestore
        .collection('users')
        .doc(widget.userId)
        .collection('followers')
        .get();
    return querySnapshot.docs.length;
  }

  Future<int> getFollowingCount() async {
    final querySnapshot = await _firestore
        .collection('users')
        .doc(widget.userId)
        .collection('following')
        .get();
    return querySnapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Row(
          children: [
            Text("ShareMe"),
            SizedBox(width: 8),

          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('users').doc(widget.userId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final userData = snapshot.data!;
          final username = userData['username'] ?? 'No Username';
          final bio = userData['bio'] ?? 'No bio available';
          final profileImageUrl = userData['profileImageUrl'] ?? 'assets/images/profile.png';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.black45],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 50,
                      left: 20,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: profileImageUrl.startsWith('http')
                            ? NetworkImage(profileImageUrl)
                            : AssetImage(profileImageUrl) as ImageProvider,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        bio,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 20),
                      // Follow/Unfollow button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: toggleFollow,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isFollowing ? Colors.white : Colors.teal,
                              side:BorderSide(
                                color: isFollowing ? Colors.teal : Colors.transparent,
                                width:1.2
                              )
                            ),
                            child: Text(
                              isFollowing ? 'Unfollow' : 'Follow',
                              style: TextStyle(color: isFollowing ? Colors.teal : Colors.white),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          FutureBuilder<int>(
                            future: getPostCount(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return _buildStatColumn('Posts', '0');
                              } else if (snapshot.hasError) {
                                return _buildStatColumn('Posts', '0');
                              }
                              return _buildStatColumn('Posts', (snapshot.data ?? 0).toString());
                            },
                          ),
                          FutureBuilder<int>(
                            future: getFollowerCount(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return _buildStatColumn('Followers', '0');
                              } else if (snapshot.hasError) {
                                return _buildStatColumn('Followers', '0');
                              }
                              return _buildStatColumn('Followers', (snapshot.data ?? 0).toString());
                            },
                          ),
                          FutureBuilder<int>(
                            future: getFollowingCount(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return _buildStatColumn('Following', '0');
                              } else if (snapshot.hasError) {
                                return _buildStatColumn('Following', '0');
                              }
                              return _buildStatColumn('Following', (snapshot.data ?? 0).toString());
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Posts',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.view_headline),
                            color: Colors.black,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>  OtherUserProfileScreenList(username:username,userId: widget.userId,),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      StreamBuilder<QuerySnapshot>(
                        stream: _firestore
                            .collection('posts')
                            .where('userId', isEqualTo: widget.userId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }
                          final posts = snapshot.data!.docs;
                          return posts.isEmpty
                              ? Center(
                            child: Text(
                              'No posts from this user',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          )
                              : GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: posts.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 2,
                              mainAxisSpacing: 2,
                            ),
                            itemBuilder: (context, index) {
                              final post = posts[index].data() as Map<String, dynamic>;
                              final imageUrl = post['imageUrl'] ?? '';
                              return Container(
                                color: Colors.grey[300],
                                child: InstaImageViewer(
                                  child: Image(image: Image.network(imageUrl).image),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Column _buildStatColumn(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }
}

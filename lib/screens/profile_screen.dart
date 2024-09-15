import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialmediaplatform/screens/edit_profile.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:socialmediaplatform/screens/user_posts_screen.dart';
class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}
class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('users').doc(_auth.currentUser?.uid).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          Future<int> getPostCount() async {
            final querySnapshot = await _firestore
                .collection('posts')
                .where('userId', isEqualTo: _auth.currentUser?.uid)
                .get();
            return querySnapshot.docs.length;
          }
          Future<int> getFollowerCount() async {
            final querySnapshot = await _firestore
                .collection('users')
                .doc(_auth.currentUser?.uid)
                .collection('followers')
                .get();
            return querySnapshot.docs.length;
          }
          Future<int> getFollowingCount() async {
            final querySnapshot = await _firestore
                .collection('users')
                .doc(_auth.currentUser?.uid)
                .collection('following')
                .get();
            return querySnapshot.docs.length;
          }
          final userData = snapshot.data!;
          final username = userData['username'] ?? 'No Username';
          final bio = userData['bio'] ?? 'No bio available';
          final profileImageUrl = userData['profileImageUrl'] ?? 'assets/images/profile.png';
          final firstName = userData['firstName'] ?? '';
          final lastName = userData['lastName'] ?? '';
           // Placeholder for actual following count

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
                    Positioned(
                      top: 60,
                      right: 20,
                      child: IconButton(
                        icon: Icon(Icons.power_settings_new_outlined, color: Colors.black),
                        onPressed:() async  {
                          // Call the logout method
                          await logout(context);
                    },
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
                          fontSize: 20,
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
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProfileScreen(
                                      userId: _auth.currentUser?.uid ?? '',
                                      initialUsername: username,
                                      initialBio: bio,
                                      profileImageUrl: profileImageUrl,
                                      initialFirstName: firstName,
                                      initialLastName: lastName,
                                    ),
                                  ),
                                ).then((value) {
                                  if(value==true)
                                    {
                                      setState(() {});
                                    }
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text('Edit Profile',selectionColor: Colors.black,),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.teal),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Share Profile',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
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
                                  builder: (context) => ProfileScreenList(username:username),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      StreamBuilder<QuerySnapshot>(
                        stream: _firestore
                            .collection('posts')
                            .where('userId', isEqualTo: _auth.currentUser?.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }

                          final posts = snapshot.data!.docs;
                          return posts.isEmpty
                              ? Center(
                            child: Text(
                              'No post from the user',
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
                                    child:Image(image: Image.network(imageUrl).image
                                    )
                                )
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
  Future<void> logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context,'/');
    } catch (e) {
      print('Error logging out: $e');
    }
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

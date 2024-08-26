import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialmediaplatform/screens/edit_profile.dart';

class ProfileScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('users').doc(_auth.currentUser?.uid).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data!;
          final username = userData['username'] ?? 'No Username';
          final bio = userData['bio'] ?? 'No bio available';
          final profileImageUrl = userData['profileImageUrl'] ?? 'assets/images/profile.png';
          final firstName = userData['firstName'] ?? '';
          final lastName = userData['lastName'] ?? '';
          final postCount = '0';
          final followerCount =  '0';
          final followingCount =  '0';
          final posts =  [];

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
                          colors: [Colors.blueAccent, Colors.purpleAccent],
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
                        icon: Icon(Icons.settings, color: Colors.white),
                        onPressed: () {},
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatColumn('Posts', postCount),
                          _buildStatColumn('Followers', followerCount),
                          _buildStatColumn('Following', followingCount),
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
                                ).then((_) {
                                  // Refresh the profile screen after editing
                                  // You can use setState or another method to refresh
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text('Edit Profile'),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.blueAccent),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Share Profile',
                                style: TextStyle(color: Colors.blueAccent),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Posts',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10),
                      posts.isEmpty
                          ? Center(
                        child: Text(
                          'No post from the user',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
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
                          return Container(
                            color: Colors.grey[300],
                            child: Image.network(
                              posts[index],
                              fit: BoxFit.cover,
                            ),
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

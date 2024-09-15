import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialmediaplatform/widgets/post_card.dart';
import 'package:intl/intl.dart';

class ProfileScreenList extends StatelessWidget {
  final String username;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  ProfileScreenList({required this.username});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        backgroundColor: Colors.teal,
        title: Row(
          children: [
            Text("Posts by you"),
            SizedBox(width: 8),

          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
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
              'No posts available',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          )
              : ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final postSnapShot = posts[index];
              final post = postSnapShot.data() as Map<String, dynamic>;
              final imageUrl = post['imageUrl'] ?? '';
              final description = post['title'] ?? '';
              final postedDate = post['createdAt'] as String?;
              final dateFormated = postedDate != null
                  ? _formatDate(postedDate)
                  : 'Unknown Date';
              final postid = postSnapShot.id;
              return PostCard(
                postId: postid,
                userName: username,
                postedDate: dateFormated,
                imageUrl: imageUrl,
                description: description,
              );
            },
          );
        },
      ),
    );
  }
}
String _formatDate(String isoDate) {
  try {
    final dateTime = DateTime.parse(isoDate); // Parse ISO 8601 string
    return DateFormat.yMMMd().format(dateTime); // Format the date
  } catch (e) {
    return 'Invalid Date'; // Handle parsing error
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialmediaplatform/widgets/post_card.dart';
import 'package:intl/intl.dart';

class OtherUserProfileScreenList extends StatelessWidget {
  final String userId; // This is the ID of the user whose posts you want to display
  final String username;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  OtherUserProfileScreenList({required this.userId, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Row(
          children: [
            Text("Posts by $username"),
            SizedBox(width: 8),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('posts')
            .where('userId', isEqualTo: userId) // Filter posts by the specified user's ID
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
              final dateFormatted = postedDate != null
                  ? _formatDate(postedDate)
                  : 'Unknown Date';
              final postid = postSnapShot.id;

              return PostCard(
                postId: postid,
                userName: username, // The username of the post's owner
                postedDate: dateFormatted,
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

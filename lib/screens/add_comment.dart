import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddCommentScreen extends StatefulWidget {
  final String postId;

  AddCommentScreen({required this.postId});

  @override
  _AddCommentScreenState createState() => _AddCommentScreenState();
}

class _AddCommentScreenState extends State<AddCommentScreen> {
  final TextEditingController _commentController = TextEditingController();
  User? currentUser;
  String? userName;
  String userImageUrl='';
  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _fetchUserName();
  }

  // Method to get the current authenticated user
  void _getCurrentUser() {
    setState(() {
      currentUser = FirebaseAuth.instance.currentUser;
    });
  }
  Future<void> _fetchUserName() async {
    if (currentUser == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .get();

    if (userDoc.exists) {
      setState(() {
        userName = userDoc.data()!['username'] ?? 'me';
        userImageUrl = userDoc.data()!['profileImageUrl'] ?? 'hii';
      });
    }
  }
  // Method to add a comment to Firestore
  Future<void> _addComment() async {
    if (_commentController.text.isEmpty || currentUser == null) return;

    final commentsRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments');

    await commentsRef.add({
      'userId': currentUser!.uid,
      'userName': userName ?? 'here',
      'comment': _commentController.text,
      'timestamp': FieldValue.serverTimestamp(),
      'userImageUrl':userImageUrl,
    });

    // Clear the comment input field
    _commentController.clear();
  }

  // Method to display the list of comments
  Widget _buildCommentsList() {
    final commentsRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .orderBy('timestamp', descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: commentsRef.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final comments = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final commentData = comments[index].data() as Map<String, dynamic>;
            final commentText = commentData['comment'] ?? '';

            final userName = commentData['userName'] ?? 'Unknown';
            final timestamp = commentData['timestamp']?.toDate().toString() ?? 'Unknown';

            return ListTile(
              leading: CircleAvatar(
                  backgroundImage: userImageUrl.isNotEmpty
                      ? NetworkImage(userImageUrl) // Display profile image
                      : null,
                  backgroundColor: Colors.grey, // Placeholder color if no image
                  child: userImageUrl.isEmpty
                      ? Text(userName[0].toUpperCase()) // Display first letter if no image
                      : null
              ),
              title: Text(userName),
              subtitle: Text(commentText),
              trailing: Text(timestamp),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Comment'),
      ),
      body: Column(
        children: [
          Expanded(child: _buildCommentsList()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      labelText: 'Add a comment...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _addComment, // Add comment to Firestore
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

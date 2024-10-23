import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddCommentScreen extends StatefulWidget {
  final String postId;
  final bool isOwnpost;

  AddCommentScreen({required this.postId, required this.isOwnpost});

  @override
  _AddCommentScreenState createState() => _AddCommentScreenState();
}

class _AddCommentScreenState extends State<AddCommentScreen> {
  final TextEditingController _commentController = TextEditingController();
  User? currentUser;
  String? userName;
  String userImageUrl = '';

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _fetchUserName();
  }

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
      'userImageUrl': userImageUrl,
    });

    _commentController.clear();
  }

  // New method to show a confirmation dialog before deletion
  Future<void> _showDeleteConfirmationDialog(String commentId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Comment'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this comment?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              style: ButtonStyle(foregroundColor:MaterialStateProperty.all<Color>(Colors.teal)),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Delete'),
              style: ButtonStyle(foregroundColor: MaterialStateProperty.all<Color>(Colors.teal)),
              onPressed: () {
                _deleteComment(commentId);
                Navigator.of(context).pop(); // Close the dialog and delete
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteComment(String commentId) async {
    final commentsRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments');

    await commentsRef.doc(commentId).delete();
  }

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
            final commentDoc = comments[index];
            final commentData = commentDoc.data() as Map<String, dynamic>;
            final commentText = commentData['comment'] ?? '';
            final userName = commentData['userName'] ?? 'Unknown';
            final userId = commentData['userId']; // User ID of the comment
            final timestamp = commentData['timestamp']?.toDate().toString() ?? 'Unknown';
            final commentId = commentDoc.id;

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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.isOwnpost || currentUser!.uid == userId) // Allow delete if own post or comment
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        // Show confirmation dialog before deleting
                        _showDeleteConfirmationDialog(commentId);
                      },
                    ),
                ],
              ),
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
                  color: Colors.teal,
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

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialmediaplatform/screens/add_comment.dart';
import 'package:socialmediaplatform/screens/edit_post.dart';
class PostCard extends StatefulWidget {
  final String userName;
  final String postedDate;
  final String imageUrl;
  final String description;
  final String postId;
  final bool isLikedInitially;
  final bool isEditable; // New attribute

  PostCard({
    required this.userName,
    required this.postedDate,
    required this.imageUrl,
    required this.description,
    required this.postId,
    this.isLikedInitially = false,
    this.isEditable = false, // Default to false
  });

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
  }

  Future<void> _checkIfLiked() async {
    final likesRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('likes')
        .doc(FirebaseAuth.instance.currentUser?.uid);

    final doc = await likesRef.get();

    setState(() {
      isLiked = doc.exists; // If the document exists, the post is liked
    });
  }

  // Function to toggle like status and update the database
  Future<void> _deletePost() async {
    try {
      // Delete post from Firestore
      final postRef = FirebaseFirestore.instance.collection('posts').doc(widget.postId);
      await postRef.delete();

      // Optionally show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post deleted successfully!')),
      );

      // Optionally navigate back after deletion
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete the post: $e')),
      );
    }
  }
  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    final postRef = FirebaseFirestore.instance.collection('posts').doc(widget.postId);
    final likesRef = postRef.collection('likes').doc(FirebaseAuth.instance.currentUser?.uid);

    if (isLiked) {
      // Add a new document to the 'likes' sub-collection with the user's ID
      likesRef.set({
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      // Remove the document from the 'likes' sub-collection
      likesRef.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              color: Colors.black.withOpacity(0.25),
              offset: Offset(0, 2),
              spreadRadius: 2,
            ),
          ],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Profile Picture and User Info
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(
                      'https://picsum.photos/seed/119/600', // Placeholder for profile picture
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.userName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          widget.postedDate,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.isEditable)
                    IconButton(
                      icon: Icon(Icons.more_vert),
                      onPressed: () {
                        // Handle edit or delete actions
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => _buildBottomSheet(),
                        );
                      },
                    ),
                ],
              ),
            ),

            // Post Content: Image
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                widget.imageUrl,
                width: double.infinity,
                height: 400,
                fit: BoxFit.cover,
              ),
            ),

            // Post Description
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                widget.description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),

            // Post Actions: Like and Comment
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.black,
                    ),
                    iconSize: 32,
                    onPressed: toggleLike,
                  ),
                  SizedBox(width: 12),
                  IconButton(
                    icon: Icon(Icons.comment_rounded),
                    color: Colors.black,
                    iconSize: 32,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddCommentScreen(postId: widget.postId,isOwnpost: widget.isEditable,),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to build the bottom sheet for edit/delete options
  Widget _buildBottomSheet() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(Icons.edit),
          title: Text('Edit Post'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditPostScreen(
                  postId: widget.postId,
                  currentDescription: widget.description,
                  currentImageUrl: widget.imageUrl,
                ),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.delete),
          title: Text('Delete Post'),
          onTap: () {
            // Handle deleting
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Delete Post'),
                content: Text('Are you sure you want to delete this post?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text('Cancel'),
                    style: ButtonStyle(
                      foregroundColor:MaterialStateProperty.all<Color>(Colors.teal),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop(); // Close the dialog
                      await _deletePost(); // Call the delete function
                    },
                    child: Text('Delete'),
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.teal),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

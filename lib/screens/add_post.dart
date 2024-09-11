import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddPostPage extends StatefulWidget {
  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  File? _imageFile;
  final picker = ImagePicker();
  bool _isLoading = false;

  // Get the current user ID
  String? get _currentUserId {
    final User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  // Pick image from gallery or camera
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Function to upload image to Firebase Storage
  Future<String?> _uploadImage(File imageFile) async {
    try {
      String fileName = 'posts/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageReference =
      FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageReference.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Add post data to Firestore
  Future<void> _addPost() async {
    String title = _titleController.text.trim();
    String content = _contentController.text.trim();
    if (title.isEmpty || content.isEmpty || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and select an image')),
      );
      return;
    }

    // Get current user ID
    final String? userId = _currentUserId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload image
      String? imageUrl = await _uploadImage(_imageFile!);

      // Create post object
      Map<String, dynamic> post = {
        'title': title,
        'content': content,
        'imageUrl': imageUrl,
        'createdAt': DateTime.now().toIso8601String(),
        'userId': userId, // Set the current user ID
      };

      // Add post to Firestore
      await FirebaseFirestore.instance.collection('posts').add(post);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post added successfully')),
      );

      // Clear fields
      _titleController.clear();
      _contentController.clear();
      setState(() {
        _imageFile = null;
      });
    } catch (e) {
      print('Error adding post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding post')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Post'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Post title input
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Post Title'),
            ),
            SizedBox(height: 16),

            // Post content input
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Post Content'),
              maxLines: 5,
            ),
            SizedBox(height: 16),

            // Image picker
            _imageFile == null
                ? TextButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            )
                : Column(
              children: [
                Image.file(
                  _imageFile!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                TextButton(
                  onPressed: _pickImage,
                  child: Text('Change Image'),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Submit button
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _addPost,
              child: Text('Add Post'),
            ),
          ],
        ),
      ),
    );
  }
}

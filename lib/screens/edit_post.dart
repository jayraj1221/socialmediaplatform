import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
class EditPostScreen extends StatefulWidget {
  final String postId;
  final String currentDescription;
  final String currentImageUrl;

  EditPostScreen({
    required this.postId,
    required this.currentDescription,
    required this.currentImageUrl,
  });

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _descriptionController.text = widget.currentDescription;
    _imageUrl = widget.currentImageUrl;
  }

  Future<void> _updatePost() async {
    setState(() {
      _isLoading = true;
    });

    final postRef = FirebaseFirestore.instance.collection('posts').doc(widget.postId);

    try {
      // Update the post description and image URL in Firestore
      await postRef.update({
        'title': _descriptionController.text,
        'imageUrl': _imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update the post: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Convert XFile to File
        File file = File(image.path);

        // Upload image to Firebase Storage
        String fileName = image.name;
        Reference storageRef = FirebaseStorage.instance.ref().child('postImages/$fileName');
        UploadTask uploadTask = storageRef.putFile(file);

        TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
        String downloadUrl = await snapshot.ref.getDownloadURL();

        setState(() {
          _imageUrl = downloadUrl;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Post'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _isLoading ? null : _updatePost,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Preview and Change Button
              if (_imageUrl != null)
                Center(
                  child: Image.network(
                    _imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              SizedBox(height: 10),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _pickImage,
                  icon: Icon(Icons.image),
                  label: Text('Change Image'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: BorderSide(
                      color:Colors.teal,
                      width: 2.0,
                    )
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Description Field
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),

              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _updatePost,
                child: Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 40),
                  side: BorderSide(
                    color: Colors.black,
                    width: 2.0

                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

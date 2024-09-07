import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialmediaplatform/models/user_model.dart';

class Comment{
  final String id;
  final String userId;
  final String postId;
  final String description;
  Comment(
  {
    required this.id,
    required this.userId,
    required this.postId,
    required this.description,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'postId': postId,
      'description': description,
    };
  }
}

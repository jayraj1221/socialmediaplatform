import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String content;
  final String imageUrl;
  final DateTime timestamp;
  final List<String> likes;
  final List<String> comments;

  Post({
    required this.id,
    required this.userId,
    required this.content,
    required this.imageUrl,
    required this.timestamp,
    this.likes = const [],
    this.comments = const [],
  });

  // Convert a Post object into a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'content': content,
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(),
      'likes': likes,
      'comments': comments,
    };
  }

  // Convert a Firestore DocumentSnapshot into a Post object
  factory Post.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      userId: data['userId'] ?? '',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      timestamp: DateTime.parse(data['timestamp'] ?? DateTime.now().toIso8601String()),
      likes: List<String>.from(data['likes'] ?? []),
      comments: List<String>.from(data['comments'] ?? []),
    );
  }
  Future<void> createPost(Post post) async {
    await FirebaseFirestore.instance.collection('posts').doc(post.id).set(post.toMap());
  }
  Future<Post> getPost(String postId) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('posts').doc(postId).get();
    return Post.fromDocument(doc);
  }
  Future<void> updatePost(String postId, Map<String, dynamic> updates) async {
    await FirebaseFirestore.instance.collection('posts').doc(postId).update(updates);
  }
  Future<void> deletePost(String postId) async {
    await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
  }


}

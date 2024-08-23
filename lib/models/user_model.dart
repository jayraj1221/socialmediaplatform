import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String profileImageUrl;
  final String bio;
  List<String> followers;
  List<String> following;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.profileImageUrl,
    required this.bio,
    this.followers = const [],
    this.following = const [],
  });

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to follow another user
  Future<void> follow(User userToFollow) async {
    if (!following.contains(userToFollow.id)) {
      following.add(userToFollow.id);
      userToFollow.followers.add(id);

      // Update Firestore
      await _firestore.collection('users').doc(id).update({
        'following': FieldValue.arrayUnion([userToFollow.id]),
      });
      await _firestore.collection('users').doc(userToFollow.id).update({
        'followers': FieldValue.arrayUnion([id]),
      });
    }
  }

  // Method to unfollow another user
  Future<void> unfollow(User userToUnfollow) async {
    if (following.contains(userToUnfollow.id)) {
      following.remove(userToUnfollow.id);
      userToUnfollow.followers.remove(id);

      // Update Firestore
      await _firestore.collection('users').doc(id).update({
        'following': FieldValue.arrayRemove([userToUnfollow.id]),
      });
      await _firestore.collection('users').doc(userToUnfollow.id).update({
        'followers': FieldValue.arrayRemove([id]),
      });
    }
  }

  // Method to check if the current user is following another user
  bool isFollowing(User user) {
    return following.contains(user.id);
  }

  // Method to get the number of followers
  int get followersCount => followers.length;

  // Method to get the number of following
  int get followingCount => following.length;

  // Convert User to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'followers': followers,
      'following': following,
    };
  }

  // Create User from Firestore document
  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc.id,
      username: doc['username'],
      email: doc['email'],
      profileImageUrl: doc['profileImageUrl'],
      bio: doc['bio'],
      followers: List<String>.from(doc['followers']),
      following: List<String>.from(doc['following']),
    );
  }

  // Save User to Firestore
  Future<void> save() async {
    await _firestore.collection('users').doc(id).set(toMap());
  }

  // Fetch a user by ID
  static Future<User?> getById(String id) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(id).get();
    if (doc.exists) {
      return User.fromDocument(doc);
    }
    return null;
  }
}

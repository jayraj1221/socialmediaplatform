import 'package:cloud_firestore/cloud_firestore.dart';

class user {
  final String id;
  final String username;
  final String email;
  final String profileImageUrl;
  final String bio;
  final String firstName;
  final String lastName;
  final String password;
  List<String> followers;
  List<String> following;

  user({
    required this.id,
    required this.username,
    required this.email,
    required this.profileImageUrl,
    required this.bio,
    required this.firstName,
    required this.lastName,
    required this.password,
    this.followers = const [],
    this.following = const [],
  });

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to follow another user
  Future<void> follow(user userToFollow) async {
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
  Future<void> unfollow(user userToUnfollow) async {
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
  bool isFollowing(user user) {
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
      'firstName':firstName,
      'lastName':lastName,
      'password':password,
      'followers': followers,
      'following': following,

    };
  }

  // Create User from Firestore document
  factory user.fromDocument(DocumentSnapshot doc) {
    return user(
      id: doc.id,
      username: doc['username'],
      email: doc['email'],
      profileImageUrl: doc['profileImageUrl'],
      bio: doc['bio'],
      firstName: doc['firstName'],
      lastName: doc['lastName'],
      password: doc['password'],
      followers: List<String>.from(doc['followers']),
      following: List<String>.from(doc['following']),
    );
  }

  // Save User to Firestore
  Future<void> save() async {
    await _firestore.collection('users').doc(id).set(toMap());
  }

  // Fetch a user by ID
  static Future<user?> getById(String id) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(id).get();
    if (doc.exists) {
      return user.fromDocument(doc);
    }
    return null;
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialmediaplatform/screens/other_profile_screen.dart';
class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> allUsers = []; // Store fetched users
  List<DocumentSnapshot> filteredUsers = []; // Store filtered users
  String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? ''; // Current logged-in user ID

  @override
  void initState() {
    super.initState();
  }

  // Fetch users from Firestore based on search query
  Future<void> _fetchUsers(String query) async {
    if (query.isNotEmpty) {
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .get();

      setState(() {
        filteredUsers = usersSnapshot.docs; // Get the filtered list of document snapshots
      });
    } else {
      setState(() {
        filteredUsers = []; // If the query is empty, clear the list
      });
    }
  }

  // Check if the current user follows the searched user
  Future<bool> _isFollowing(String userId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('following')
        .doc(userId)
        .get();
    return doc.exists; // If the document exists, the current user is following this user
  }

  // Follow the user and add to the user's followers list
  Future <void> setUserFollowing(String UserId) async
  {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(UserId)
        .collection('followers')
        .doc(currentUserId)
        .set({});
  }
  Future<void> _followUser(String userId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('following')
        .doc(userId)
        .set({});
    setUserFollowing(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _fetchUsers(value); // Fetch users as the search query changes
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.teal,width:1.3), // Border color when not focused
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.black, width: 2.0), // Border color when focused
                ),
              ),
            ),

          ),
          Expanded(
            child: filteredUsers.isEmpty
                ? const Center(child: Text('No users found.')) // Show when no users found
                : ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                final userId = user.id; // User ID from Firestore
                final userData = user.data() as Map<String, dynamic>; // Access user data
                final username = userData['username']; // Username from Firestore
                final imageurl = userData['profileImageUrl'];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal,
                      radius: 25,
                      child:  ClipOval(
                        child: imageurl != null && imageurl.isNotEmpty
                            ? Image.network(
                                imageurl,
                                fit: BoxFit.cover, // Ensure the image covers the entire area
                                width: 50, // Set the width and height of the image
                                height: 50,
                             )
                            : Icon(Icons.person, color: Colors.black, size: 30,), // Default icon
                      ),
                    ),
                    title: Text(username),
                    trailing: FutureBuilder<bool>(
                      future: _isFollowing(userId), // Check if followed
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator(); // Show loading while checking follow status
                        }
                        final isFollowing = snapshot.data ?? false;

                        return isFollowing
                            ? const Text('Following') // Already following
                            : ElevatedButton(
                          onPressed: () async {
                            await _followUser(userId); // Follow the user
                            setState(() {}); // Rebuild UI to show "Following"
                          },
                          child: const Text('Follow',style: TextStyle(color: Colors.black),),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                          ),
                        );
                      },
                    ),
                    onTap: () {
                      // Handle onTap event
                      // For example, navigate to user profile or show user details
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OtherProfileScreen(userId: userId),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Placeholder for UserProfilePage
class UserProfilePage extends StatelessWidget {
  final String userId;
  const UserProfilePage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: Center(child: Text('Profile of user ID: $userId')),
    );
  }
}

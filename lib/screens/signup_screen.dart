import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialmediaplatform/models/user_model.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> _isUsernameUnique(String username) async {
    final result = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    return result.docs.isEmpty;
  }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      final String username = _usernameController.text.trim();
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      // Check if the username is unique
      bool isUnique = await _isUsernameUnique(username);
      if (!isUnique) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Username is already taken.')),
        );
        return;
      }

      try {
        // Create a new user with email and password
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final String userId = userCredential.user!.uid;

        // Create the User object
        user newUser = user(
          id: userId,
          username: username,
          email: email,
          profileImageUrl: '',
          bio: '',
          firstName: '',
          lastName: '',
          password: password, // Storing password in plain text is not recommended
          followers: [],
          following: [],
        );

        // Save the user to Firestore
        await _firestore.collection('users').doc(userId).set(newUser.toMap());

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User signed up successfully!')),
        );

        // Clear the input fields
        _usernameController.clear();
        _emailController.clear();
        _passwordController.clear();

        // Navigate to login or home screen if needed
        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        // Handle signup errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup failed: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _signup, // Call the signup function on button press
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

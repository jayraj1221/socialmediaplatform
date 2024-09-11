import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'package:socialmediaplatform/screens/add_post.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    // Replace with your pages for Home, Add, and Profile
    HomePage(),
    AddPostPage(),
    ProfileScreen(),
    Search(),
  ];
  final List<IconData> iconlist = [
    Icons.add,
    Icons.person,
    Icons.home,
    Icons.search,
    // Icons.favorite
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Row(
          children: [
            Text("Demo"),
            SizedBox(width: 8),
            Text(
              "DemoSub",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar:  CurvedNavigationBar(
        backgroundColor: Colors.black,
        buttonBackgroundColor: Colors.teal,
        color: Colors.teal,
        animationCurve: Curves.fastOutSlowIn,
        items: <Widget>[
          Icon(Icons.home,size: 30),
          Icon(Icons.add,size: 30),
          Icon(Icons.person, size: 30),
          Icon(Icons.search,size: 30,)
        ],
        height: 50,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      // body: Container(color: Colors.blueAccent),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        // Stories Section
        // StoryWidget(imageUrl: 'https://picsum.photos/seed/878/600', label: "label")
        StoriesRow(),
        SizedBox(height: 16),
        // Post Section
        // CustomContainerWidget(),
        PostCard(),
        SizedBox(height: 16),
        PostCard(), // Repeat PostCard for additional posts
      ],
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Profile Page'),
    );
  }
}
class Search extends StatelessWidget {
  const Search({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("HELLO"),
    );
  }
}

class StoryWidget extends StatelessWidget {
  final String imageUrl;
  final String label;

  StoryWidget({required this.imageUrl, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 4), // Spacing between image and text
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

class StoriesRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              StoryWidget(
                imageUrl: 'https://picsum.photos/seed/878/600',
                label: 'Hello World',
              ),
              StoryWidget(
                imageUrl: 'https://picsum.photos/seed/878/600',
                label: 'Story 2',
              ),
              StoryWidget(
                imageUrl: 'https://picsum.photos/seed/878/600',
                label: 'Story 3',
              ),
              StoryWidget(
                imageUrl: 'https://picsum.photos/seed/878/600',
                label: 'Story 4',
              ),
              StoryWidget(
                imageUrl: 'https://picsum.photos/seed/878/600',
                label: 'Story 5',
              ),
              // Add more StoryWidgets as needed
            ],
          ),
        ),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
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
                      'https://picsum.photos/seed/119/600',
                    ),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User Name',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Posted on 7th June',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Post Content: Image
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                'https://picsum.photos/seed/892/600',
                width: double.infinity,
                height: 400,
                fit: BoxFit.contain,
              ),
            ),

            // Post Actions: Like and Comment
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(Icons.favorite_border),
                    color: Colors.black,
                    iconSize: 32,
                    onPressed: () {},
                  ),
                  SizedBox(width: 12),
                  IconButton(
                    icon: Icon(Icons.comment_rounded),
                    color: Colors.black,
                    iconSize: 32,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


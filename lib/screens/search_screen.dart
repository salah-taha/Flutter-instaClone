import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:insta_app/models/user_data.dart';
import 'package:insta_app/models/user_model.dart';
import 'package:insta_app/screens/profile_screen.dart';
import 'package:insta_app/services/database_service.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();

  Future<QuerySnapshot> _users;

  String searchedName;

  _buildUserTile(User user) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundImage: user.profileImageUrl.isEmpty
            ? AssetImage('asset/images/user_placeholder.png')
            : CachedNetworkImageProvider(user.profileImageUrl),
      ),
      title: Text(user.name),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProfileScreen(
            userId: user.id,
            currentUserId: Provider.of<UserData>(context).currentUserId,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 15),
              border: InputBorder.none,
              hintText: 'Search',
              prefixIcon: Icon(
                Icons.search,
                size: 30,
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => _searchController.clear());
                  setState(() {
                    _users = null;
                  });
                  return null;
                },
              ),
              filled: true,
            ),
            onSubmitted: (input) {
              if (input.isNotEmpty) {
                setState(() {
                  searchedName = input;
                  _users = DatabaseService.searchUsers(input);
                });
              }
            },
          ),
        ),
        body: _users == null
            ? Center(
                child: Text('Search for a user'),
              )
            : FutureBuilder<QuerySnapshot>(
                future: _users,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data.documents.length < 1) {
                    return Center(
                      child: Text('No Users Found, Try again'),
                    );
                  }
                  return ListView.builder(
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (BuildContext context, int index) {
                        User user =
                            User.fromDoc(snapshot.data.documents[index]);
                        if (user.name[0] == searchedName[0]) {
                          return _buildUserTile(user);
                        } else {
                          return null;
                        }
                      });
                },
              ));
  }
}

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta_app/models/user_model.dart';
import 'package:insta_app/services/database_service.dart';
import 'package:insta_app/services/storage_service.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;

  EditProfileScreen({this.user});
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _bio = '';
  File _profileImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _name = widget.user.name;
    _bio = widget.user.bio;
    _profileImage = null;
  }

  _handleImageFromGallery() async {
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      setState(() {
        _profileImage = imageFile;
      });
    }
  }

  _submit() async {
    if (_formKey.currentState.validate() && !_isLoading) {
      _formKey.currentState.save();
    }
    setState(() {
      _isLoading = true;
    });
//  update user database
    String _profileImageUrl = '';

    if (_profileImage == null) {
      _profileImageUrl = widget.user.profileImageUrl;
    } else {
      _profileImageUrl = await StorageService.uploadUserProfileImage(
        widget.user.profileImageUrl,
        _profileImage,
      );
    }

    User user = User(
        id: widget.user.id,
        email: widget.user.email,
        name: _name,
        bio: _bio,
        profileImageUrl: _profileImageUrl);
//  update database
    DatabaseService.updateUser(user);
    Navigator.pop(context);
  }

  _displayProfileImage() {
    if (_profileImage == null) {
      if (widget.user.profileImageUrl.isEmpty) {
        return AssetImage('assets/images/user_placeholder.png');
      } else {
        return CachedNetworkImageProvider(widget.user.profileImageUrl);
      }
    } else {
      return FileImage(_profileImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          children: <Widget>[
            _isLoading
                ? LinearProgressIndicator(
                    backgroundColor: Colors.blue[200],
                    valueColor: AlwaysStoppedAnimation(Colors.blue),
                  )
                : SizedBox.shrink(),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
              child: Form(
                key: _formKey,
                child: Center(
                  child: Column(
//                crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        onTap: _handleImageFromGallery,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey,
                          backgroundImage: _displayProfileImage(),
                        ),
                      ),
                      FlatButton(
                        onPressed: _handleImageFromGallery,
                        child: Text('Change Profile Image'),
                      ),
                      TextFormField(
                        initialValue: _name,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                          icon: Icon(
                            Icons.person,
                            size: 30,
                          ),
                          labelText: 'Name',
                        ),
                        validator: (input) => input.trim().length < 1
                            ? 'Please enter a valid name'
                            : null,
                        onSaved: (input) => _name = input,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      TextFormField(
                        initialValue: _bio,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                          icon: Icon(
                            Icons.book,
                            size: 30,
                          ),
                          labelText: 'Bio',
                        ),
                        validator: (input) => input.trim().length > 150
                            ? 'Bio must be less than 150 letter'
                            : null,
                        onSaved: (input) {
                          if (input != null) {
                            _bio = input;
                          } else {
                            _bio = '';
                          }
                        },
                      ),
                      Container(
                        margin: EdgeInsets.all(40),
                        height: 40,
                        width: 250,
                        child: FlatButton(
                          onPressed: _submit,
                          color: Colors.blue,
                          textColor: Colors.white,
                          child: Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

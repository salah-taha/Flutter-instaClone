import 'package:flutter/material.dart';
import 'package:insta_app/models/post_model.dart';
import 'package:insta_app/models/user_data.dart';
import 'package:insta_app/models/user_model.dart';
import 'package:insta_app/screens/comments_screen.dart';
import 'package:insta_app/screens/edit_profile_screen.dart';
import 'package:insta_app/services/auth_service.dart';
import 'package:insta_app/services/database_service.dart';
import 'package:insta_app/utilities/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:insta_app/widgets/post_view.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  final String currentUserId;

  ProfileScreen({this.userId, this.currentUserId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isFollowing = false;
  int _followersCount = 0;
  int _followingCount = 0;
  List<Post> _posts = [];
  int _displayPosts = 0; //0-grid ,1-column
  bool _isVerified = false;
  User _profileUser;
  @override
  void initState() {
    super.initState();
    _setupIsFollowing();
    _setupFollowers();
    _setupFollowing();
    _setupPosts();
    _setupProfileUser();
    _setupVerify();
  }

  _setupProfileUser() async {
    User profileUser = await DatabaseService.getUserWithId(widget.userId);
    setState(() {
      _profileUser = profileUser;
    });
  }

  _setupVerify() async {
    bool isVerified = await DatabaseService.isVerified(widget.userId);
    setState(() {
      _isVerified = isVerified;
    });
  }

  _setupPosts() async {
    List<Post> posts = await DatabaseService.getUserPosts(widget.userId);
    setState(() {
      _posts = posts;
    });
  }

  _setupIsFollowing() async {
    bool isFollowingUser = await DatabaseService.isFollowingUser(
        currentUserId: widget.currentUserId, profileUserId: widget.userId);
    setState(() {
      _isFollowing = isFollowingUser;
    });
  }

  _setupFollowers() async {
    int userFollowersCount = await DatabaseService.numFollowers(widget.userId);
    setState(() {
      _followersCount = userFollowersCount;
    });
  }

  _setupFollowing() async {
    int userFollowingCount = await DatabaseService.numFollowing(widget.userId);
    setState(() {
      _followingCount = userFollowingCount;
    });
  }

  _followOrUnFollow() {
    if (_isFollowing) {
      _unFollowUser();
    } else {
      _followUser();
    }
  }

  _unFollowUser() {
    DatabaseService.unFollowUser(
        currentUserId: widget.currentUserId, profileUserId: widget.userId);
    setState(() {
      _isFollowing = false;
      _followersCount--;
    });
  }

  _followUser() {
    DatabaseService.followUser(
        currentUserId: widget.currentUserId, profileUserId: widget.userId);
    setState(() {
      _isFollowing = true;
      _followersCount++;
    });
  }

  _displayButton(User user) {
    return user.id == Provider.of<UserData>(context).currentUserId
        ? Container(
            width: 200,
            child: FlatButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(
                    user: user,
                  ),
                ),
              ),
              color: Colors.blue,
              child: Text(
                'Edit Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          )
        : Container(
            width: 200,
            child: FlatButton(
              onPressed: _followOrUnFollow,
              color: _isFollowing ? Colors.grey[200] : Colors.blue,
              child: Text(
                _isFollowing ? 'UnFollow' : 'Follow',
                style: TextStyle(
                  color: _isFollowing ? Colors.black54 : Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          );
  }

  _buildProfileInfo(User user) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(30, 30, 30, 0),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 50.0,
                backgroundColor: Colors.grey,
                backgroundImage: user.profileImageUrl.isEmpty
                    ? AssetImage('assets/images/user_placeholder.png')
                    : CachedNetworkImageProvider(user.profileImageUrl),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Text(
                              _posts.length.toString(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'posts',
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            )
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Text(
                              '$_followersCount',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'followers',
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            )
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Text(
                              '$_followingCount',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'following',
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                    _displayButton(user),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    user.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _isVerified
                      ? Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.blue,
                            child: Center(
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 15,
                              ),
                            ),
                          ),
                        )
                      : SizedBox(),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                user.bio,
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 15,
                ),
              ),
              Divider(
                thickness: 0.2,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ],
    );
  }

  _buildToggleButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          padding: EdgeInsets.all(0),
          onPressed: () => setState(() {
            _displayPosts = 0;
          }),
          icon: Icon(
            Icons.grid_on,
            size: 30,
            color: _displayPosts == 0
                ? Theme.of(context).primaryColor
                : Colors.grey[300],
          ),
        ),
        IconButton(
          padding: EdgeInsets.all(0),
          onPressed: () => setState(() {
            _displayPosts = 1;
          }),
          icon: Icon(
            Icons.list,
            size: 30,
            color: _displayPosts == 1
                ? Theme.of(context).primaryColor
                : Colors.grey[300],
          ),
        ),
      ],
    );
  }

  _buildTilePost(Post post) {
    return GridTile(
        child: GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CommentsScreen(
            post: post,
            likeCount: post.likeCount,
          ),
        ),
      ),
      child: Image(
        image: CachedNetworkImageProvider(post.imageUrl),
        fit: BoxFit.cover,
      ),
    ));
  }

  _buildDisplayPosts() {
    if (_displayPosts == 0) {
      //Grid
      List<GridTile> tiles = [];
      _posts.forEach((post) {
        tiles.add(_buildTilePost(post));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        shrinkWrap: true,
        children: tiles,
        physics: NeverScrollableScrollPhysics(),
      );
    } else {
      //Column
      List<PostView> postView = [];
      _posts.forEach((post) {
        postView.add(PostView(
          currentUserId: widget.currentUserId,
          post: post,
          author: _profileUser,
        ));
      });
      return Column(
        children: postView,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            'salah app',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Billabong',
              fontSize: 35,
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: AuthService.logout,
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: usersRef.document(widget.userId).get(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          User user = User.fromDoc(snapshot.data);
          return ListView(
            children: <Widget>[
              _buildProfileInfo(user),
              _buildToggleButtons(),
              Divider(),
              _buildDisplayPosts(),
            ],
          );
        },
      ),
    );
  }
}

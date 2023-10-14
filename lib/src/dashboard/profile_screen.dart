import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wazzlitt/src/dashboard/feed_image.dart';
import 'package:wazzlitt/user_data/user_data.dart';
import '../app.dart';
import '../../user_data/patrone_data.dart';
import 'conversation_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.userProfile});

  final Patrone userProfile;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Patrone>(
        future: null,
        builder: (context, snapshot) {
          var currentUser = widget.userProfile;
          String? coverPhoto = currentUser.coverPicture;
          String? profilePhoto = currentUser.profilePicture;
          String? firstName = currentUser.firstName;
          String? lastName = currentUser.lastName;
          String? username = currentUser.username;
          String? bio = currentUser.bio;
          DateTime? dob = currentUser.dob;
          List<dynamic>? createdPosts = currentUser.createdPosts;
          List<dynamic>? following = currentUser.following;
          List<dynamic>? followers = currentUser.followers;
          String? gender = currentUser.gender;
          List<dynamic>? interests = currentUser.interests;
          bool? isLit = currentUser.isLit;
          return Container(
            height: height(context),
            width: width(context),
            child: Column(
              children: [
                SizedBox(
                  height: height(context) * 0.5,
                  child: ProfileTab(
                    coverPhoto: coverPhoto,
                    profilePhoto: profilePhoto,
                    firstName: firstName,
                    lastName: lastName,
                    bio: bio,
                    username: username,
                    interests: interests,
                    dob: dob,
                    posts: createdPosts ?? [],
                    userProfile: currentUser.patroneReferenceSet!,
                    following: following ?? [],
                    followers: followers ?? [],
                    isLit: isLit ?? false,
                  ),
                ),
                Expanded(
                    child: LimitedBox(
                        maxWidth: width(context),
                        maxHeight: height(context) * 0.5,
                        child: ActivityTab(
                            userProfile: currentUser.patroneReferenceSet!))),
              ],
            ),
          );
        });
  }
}

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.userProfile,
    required this.coverPhoto,
    required this.profilePhoto,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.bio,
    required this.interests,
    required this.dob,
    required this.posts,
    required this.following,
    required this.followers,
    required this.isLit,
  });

  final DocumentReference userProfile;
  final String? coverPhoto;
  final String? profilePhoto;
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? bio;
  final List? interests;
  final DateTime? dob;
  final List<dynamic> posts;
  final List<dynamic> following;
  final List<dynamic> followers;
  final bool isLit;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  void initState() {
    super.initState();
    isFollowing = (val) {
      return val;
    };
    getLocation = (val) {
      return val;
    };
  }

  late final Future<bool> Function(Future<bool>) isFollowing;
  late final Future<String> Function(Future<String>) getLocation;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        image: widget.profilePhoto != null
                            ? DecorationImage(
                                image: NetworkImage(widget.profilePhoto!),
                                fit: BoxFit.cover)
                            : null,
                        color: Colors.grey[800],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Flexible(
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 300),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                FutureBuilder<List<dynamic>>(
                                    future: Patrone()
                                        .getUserPosts(widget.userProfile),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return Text(
                                            snapshot.data!.length.toString(),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18));
                                      }
                                      return const Text('0',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18));
                                    }),
                                const Text('Posts',
                                    style: TextStyle(fontSize: 14)),
                              ],
                            ),
                            Column(
                              children: [
                                Text(widget.followers.length.toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                                const Text('Followers',
                                    style: TextStyle(fontSize: 14)),
                              ],
                            ),
                            Column(
                              children: [
                                Text(widget.following.length.toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                                const Text('Following',
                                    style: TextStyle(fontSize: 14)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text('${widget.firstName} ${widget.lastName}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(width: 5),
                        Text(widget.isLit ? 'I\'m Lit!' : '',
                            style: TextStyle(
                                color: widget.isLit
                                    ? Colors.amber[800]
                                    : Colors.white)),
                        SizedBox(width: 5),
                        Icon(FontAwesomeIcons.fire,
                            color:
                                widget.isLit ? Colors.amber[800] : Colors.white,
                            size: 18),
                      ],
                    ),
                    // const SizedBox(height: 5),
                    // Text('@$username', style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 10),
                    Text(Patrone().getStarSign(widget.dob ?? DateTime(0, 1, 1)),
                        style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 5),
                    FutureBuilder<String>(
                      future:
                          getLocation(getCurrentLocation(widget.userProfile)),
                      builder: (context, snapshot) {
                        print(snapshot.connectionState);

                        if (snapshot.hasData) {
                          return Text(snapshot.data!,
                              style: const TextStyle(fontSize: 12));
                        }
                        if (snapshot.hasError) {
                          return const Text('An error occured',
                              style: TextStyle(fontSize: 12));
                        }
                        return const Text('Loading...',
                            style: TextStyle(fontSize: 12));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(widget.bio ?? 'User has not set a bio',
                    style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      flex: 10,
                      child: SizedBox(
                        height: 30,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(5)),
                          onPressed: () => widget.userProfile ==
                                  Patrone().currentUserPatroneProfile
                              ? Navigator.pushNamed(
                                  context, 'patrone_registration')
                              : Patrone()
                                  .isFollowingUser(widget.userProfile)
                                  .then((isFollowing) {
                                  isFollowing
                                      ? Patrone()
                                          .unfollowUser(widget.userProfile)
                                      : Patrone()
                                          .followUser(widget.userProfile);
                                }),
                          child: widget.userProfile ==
                                  Patrone().currentUserPatroneProfile
                              ? const Text('Edit Profile',
                                  style: TextStyle(fontSize: 12))
                              : FutureBuilder<bool>(
                                  future: isFollowing(Patrone()
                                      .isFollowingUser(widget.userProfile)),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return Text(
                                          snapshot.data!
                                              ? 'Unfollow'
                                              : 'Follow',
                                          style: const TextStyle(fontSize: 12));
                                    }
                                    return CircularProgressIndicator();
                                  }),
                        ),
                      ),
                    ),
                    const Spacer(),
                    widget.userProfile == Patrone().currentUserPatroneProfile
                        ? const SizedBox()
                        : Expanded(
                            flex: 10,
                            child: SizedBox(
                              height: 30,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(5)),
                                onPressed: () {
                                  firestore
                                      .collection('messages')
                                      .where('participants', arrayContains: [
                                        currentUserProfile,
                                        widget.userProfile.parent.parent
                                      ])
                                      .get()
                                      .then((result) {
                                        if (result.size == 0) {
                                          firestore.collection('messages').add({
                                            'participants': [
                                              currentUserProfile,
                                              widget.userProfile.parent.parent
                                            ],
                                          }).then((messages) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ConversationScreen(
                                                  chats: messages,
                                                ),
                                              ),
                                            );
                                          });
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ConversationScreen(
                                                chats: result.docs[0].reference,
                                              ),
                                            ),
                                          );
                                        }
                                      });
                                },
                                child: const Text('Message',
                                    style: TextStyle(fontSize: 12)),
                              ),
                            ),
                          ),
                    const Spacer(),
                    Expanded(
                      flex: 10,
                      child: SizedBox(
                        height: 30,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(5)),
                          onPressed: () {},
                          child: const Text('Social Links',
                              style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: SizedBox(
                    child: ListView.builder(
                        itemCount: widget.interests?.length ?? 0,
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> interest =
                              widget.interests?[index];
                          return Padding(
                            padding: const EdgeInsets.all(5),
                            child: Chip(label: Text(interest['display'])),
                          );
                        }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ActivityTab extends StatelessWidget {
  ActivityTab({
    super.key,
    required this.userProfile,
  });

  final DocumentReference userProfile;
  List? createdPosts;

  late final Future<List<dynamic>> getPosts =
      Patrone().getUserPosts(userProfile);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: SizedBox(
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(
                  // icon: Icon(Icons.place),
                  text: 'Posts',
                ),
                Tab(
                  // icon: Icon(Icons.favorite),
                  text: 'Likes',
                ),
              ],
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white,
            ),
            Expanded(
              child: SizedBox(
                width: width(context),
                child: TabBarView(
                  children: [
                    FutureBuilder<List<dynamic>>(
                        future: getPosts,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            createdPosts = snapshot.data;
                            return GridView.builder(
                              shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2, childAspectRatio: 1),
                              itemCount: createdPosts?.length ?? 0,
                              itemBuilder: (BuildContext context, int index) {
                                DocumentReference post = createdPosts?[index];
                                return StreamBuilder<DocumentSnapshot>(
                                    stream: post.snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        Map<String,dynamic>? data = snapshot.data!.data() as Map<String, dynamic>?;
                                        return GestureDetector(
                                          onTap: () => showDialog(
                                              context: context,
                                              builder: (context) => Bounce(
                                                    child: AlertDialog(
                                                      contentPadding:
                                                          const EdgeInsets.all(
                                                              0),
                                                      content: SizedBox(
                                                        height:
                                                            height(context) *
                                                                0.5,
                                                        child: Image.network(
                                                            data?['image'] ?? 'https://i.pinimg.com/736x/c4/c7/69/c4c7697549a8c6a1c3f26a743caa75e4.jpg'),
                                                      ),
                                                    ),
                                                  )),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: NetworkImage(
                                                  data?['image'] ?? 'https://i.pinimg.com/736x/c4/c7/69/c4c7697549a8c6a1c3f26a743caa75e4.jpg',
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      } else if (snapshot.hasError) {
                                        return const Center(
                                            child: Text('Something went '
                                                'wrong'));
                                      } else {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      }
                                    });
                              },
                            );
                          }
                          return Center(child: CircularProgressIndicator());
                        }),
                    StreamBuilder<QuerySnapshot>(
                        stream: firestore
                            .collection('feed')
                            .where('likes', arrayContains: userProfile)
                            .snapshots(),
                        builder: (context, likedPosts) {
                          List<QueryDocumentSnapshot<Object?>>? liked =
                              likedPosts.data?.docs;
                          return GridView.builder(
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1,
                            ),
                            itemCount: liked?.length ?? 0,
                            itemBuilder: (BuildContext context, int index) {
                              Map<String, dynamic> like =
                                  liked![index].data() as Map<String, dynamic>;
                              return Container(
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(like['image']))),
                              );
                            },
                          );
                        }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

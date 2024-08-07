import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wazzlitt/src/dashboard/feed_image.dart';
import 'package:wazzlitt/user_data/user_data.dart';

import '../../user_data/patrone_data.dart';
import '../app.dart';
import 'conversation_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.userProfile});

  final Patrone userProfile;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

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
          return Container(
            height: height(context),
            width: width(context),
            decoration: BoxDecoration(),
            child: Column(
              children: [
                TabBar(
                  tabs: const [
                    Tab(text: 'Profile'),
                    Tab(text: 'Activity'),
                  ],
                  controller: _tabController!,
                  indicatorColor: Theme.of(context).colorScheme.primary,
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      FadeIn(
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
                            followers: followers ?? []),
                      ),
                      FadeIn(
                        child: ActivityTab(
                          createdPosts: createdPosts,
                          userProfile: currentUser.patroneReferenceSet!,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}

class ProfileTab extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: width(context),
          child: Stack(
            children: [
              Container(
                width: width(context),
                height: width(context),
                alignment: AlignmentDirectional.bottomCenter,
                decoration: BoxDecoration(
                    color: Colors.grey,
                    image: coverPhoto != null
                        ? DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(profilePhoto!))
                        : null),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  color: Colors.black.withOpacity(0.5),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$firstName $lastName',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            const SizedBox(height: 5),
                            Text(
                                '@$username | ${Patrone().getStarSign(dob ?? DateTime(0, 1, 1))}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white)),
                            const SizedBox(height: 5),
                            FutureBuilder<String>(
                              future: getCurrentLocation(userProfile),
                              builder: (context, snapshot) {
                                print(snapshot.connectionState);

                                if (snapshot.hasData) {
                                  return Text(snapshot.data!,
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.white));
                                }
                                if (snapshot.hasError) {
                                  return const Text('An error occured',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.white));
                                }
                                return const Text('Loading...',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.white));
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      SizedBox(
                        height: 30,
                        width: 120,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(5)),
                          onPressed: () =>
                              userProfile == Patrone().currentUserPatroneProfile
                                  ? Navigator.pushNamed(
                                      context, 'patrone_registration')
                                  : Patrone()
                                      .isFollowingUser(userProfile)
                                      .then((isFollowing) {
                                      isFollowing
                                          ? Patrone().unfollowUser(userProfile)
                                          : Patrone().followUser(userProfile);
                                    }),
                          child: userProfile ==
                                  Patrone().currentUserPatroneProfile
                              ? const Text('Edit Profile',
                                  style: TextStyle(fontSize: 12))
                              : FutureBuilder<bool>(
                                  future:
                                      Patrone().isFollowingUser(userProfile),
                                  builder: (context, snapshot) {
                                    return Text(
                                        snapshot.data! ? 'Unfollow' : 'Follow',
                                        style: const TextStyle(fontSize: 12));
                                  }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(posts.length.toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        const Text('Posts', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    Column(
                      children: [
                        Text(followers.length.toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        const Text('Followers', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    Column(
                      children: [
                        Text(following.length.toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        const Text('Following', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    bio ?? 'No Bio',
                  ),
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: SizedBox(
                    child: ListView.builder(
                        itemCount: interests?.length ?? 0,
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> interest = interests?[index];
                          return Padding(
                            padding: const EdgeInsets.all(5),
                            child: Chip(label: Text(interest['display'])),
                          );
                        }),
                  ),
                ),
                Row(
                  children: [
                    userProfile == Patrone().currentUserPatroneProfile
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
                                        userProfile.parent.parent
                                      ])
                                      .get()
                                      .then((result) {
                                        if (result.size == 0) {
                                          firestore.collection('messages').add({
                                            'participants': [
                                              currentUserProfile,
                                              userProfile.parent.parent
                                            ],
                                          }).then((messages) {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ConversationScreen(
                                                          chats: messages,
                                                        )));
                                          });
                                        } else {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ConversationScreen(
                                                        chats: result
                                                            .docs[0].reference,
                                                      )));
                                        }
                                      });
                                },
                                child: const Text('Message',
                                    style: TextStyle(fontSize: 12)),
                              ),
                            ),
                          ),
                    userProfile == Patrone().currentUserPatroneProfile
                        ? const SizedBox()
                        : const Spacer(),
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ActivityTab extends StatelessWidget {
  const ActivityTab({
    super.key,
    required this.createdPosts,
    required this.userProfile,
  });

  final DocumentReference userProfile;
  final List? createdPosts;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: SizedBox(
        child: Column(
          children: [
            Expanded(
              child: SizedBox(
                width: width(context),
                child: TabBarView(
                  children: [
                    GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, childAspectRatio: 3 / 4),
                      itemCount: createdPosts?.length ?? 0,
                      itemBuilder: (BuildContext context, int index) {
                        DocumentReference post = createdPosts?[index];
                        return StreamBuilder<DocumentSnapshot>(
                            stream: post.snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return GestureDetector(
                                  onTap: () => showDialog(
                                      context: context,
                                      builder: (context) => Bounce(
                                            child: AlertDialog(
                                              contentPadding:
                                                  const EdgeInsets.all(0),
                                              content: SizedBox(
                                                height: height(context) * 0.5,
                                                child: FeedImage(
                                                  snapshot: snapshot.data!,
                                                ),
                                              ),
                                            ),
                                          )),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                          snapshot.data!.get('image'),
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
                    ),
                    StreamBuilder<QuerySnapshot>(
                        stream: firestore
                            .collection('feed')
                            .where('likes', arrayContains: userProfile)
                            .snapshots(),
                        builder: (context, likedPosts) {
                          List<QueryDocumentSnapshot<Object?>>? liked =
                              likedPosts.data?.docs;
                          return GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 2 / 3,
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
            TabBar(
              tabs: const [
                Tab(
                  icon: Icon(Icons.place),
                ),
                Tab(icon: Icon(Icons.favorite)),
              ],
              labelColor: Theme.of(context).colorScheme.secondary,
              unselectedLabelColor:
                  Theme.of(context).colorScheme.secondary.withOpacity(0.375),
            ),
          ],
        ),
      ),
    );
  }
}

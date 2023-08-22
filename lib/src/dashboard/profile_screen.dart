import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wazzlitt/src/dashboard/feed_image.dart';
import 'package:wazzlitt/user_data/payments.dart';
import 'package:wazzlitt/user_data/user_data.dart';
import '../../authorization/authorization.dart';
import '../app.dart';
import 'conversation_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.userProfile});

  final DocumentReference userProfile;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>  with
    SingleTickerProviderStateMixin {

  TabController? _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: widget.userProfile.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Map<String, dynamic> data = snapshot.data!.data() as Map<String,
              dynamic>;
          String? coverPhoto = data['cover_photo'];
          String? profilePhoto = data['profile_picture'];
          String? firstName = data['first_name'];
          String? lastName = data['last_name'];
          String? username = data['username'];
          String? bio = data['bio'];
          Timestamp? dob = data['dob'];
          List<dynamic>? createdPosts = data['created_posts'];
          List<dynamic>? following = data['following'];
          List<dynamic>? followers = data['followers'];
          String? gender = data['gender'];
          List<dynamic>? interests = data['interests'];
          bool? isGangMember = data['is_gang_member'];
          bool? isHivPositive = data['is_hiv_positive'];
          return Column(
            children: [
              TabBar(tabs: const [
                Tab(text: 'Profile'),
            Tab(text: 'Activity'),
              ], controller: _tabController!, indicatorColor: Theme.of
                (context).colorScheme.primary,),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    ProfileTab(coverPhoto: coverPhoto, profilePhoto:
                    profilePhoto, firstName: firstName, lastName: lastName,
                      bio: bio, username: username, interests: interests,
                        isHivPositive: isHivPositive, isGangMember:
                      isGangMember, dob: dob?.toDate(), posts: createdPosts ?? [], userProfile: widget.userProfile, following: following?? [], followers: followers??[]),
                    ActivityTab(createdPosts: createdPosts, userProfile: widget.userProfile,),
                  ],
                ),
              ),
            ],
          );
        }
        else if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      }
    );
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
    required this.isGangMember,
    required this.isHivPositive,
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
  final bool? isGangMember;
  final bool? isHivPositive;
  final DateTime? dob;
  final List<dynamic> posts;
  final List<dynamic> following;
  final List<dynamic> followers;


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            children: [
              Container(
                width: width(context),
                height: 150,
                decoration: BoxDecoration(
                    color: Colors.grey,
                  image: coverPhoto != null ? DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                      coverPhoto!
                    )
                  ) : null
                ),),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child:
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          image: profilePhoto != null ? DecorationImage(
                            image: NetworkImage(profilePhoto!), fit:
                          BoxFit.cover
                          ) : null,
                          // color: Colors.grey[800],
                          shape: BoxShape.circle,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ElevatedButton(
                  child: Text('Pay for Patrone'),
                  onPressed: () => payForPatrone(context),
                ),
                Text('$firstName $lastName',
                    style: const TextStyle(fontWeight: FontWeight
                        .bold)),
                const SizedBox(height: 5),
                Text('@$username', style: const TextStyle(fontSize:
                12)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(posts.length.toString(), style: const TextStyle(fontWeight: FontWeight
                            .bold, fontSize: 18)),
                        const Text('Posts', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                     Column(
                      children: [
                        Text(followers.length.toString(), style: TextStyle(fontWeight: FontWeight
                            .bold, fontSize: 18)),
                        Text('Followers', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    Column(
                      children: [
                        Text(following.length.toString(), style: TextStyle(fontWeight: FontWeight
                            .bold, fontSize: 18)),
                        Text('Following', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.onSurface,),
                    borderRadius: BorderRadius.circular(10),
                  ),
                    child: Text(bio ?? 'No Bio', textAlign: TextAlign.center)),
                const SizedBox(height: 20),
                const Text('Star Sign', style: TextStyle(fontSize: 12)),
                Text(getStarSign(dob!),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const Text('Currently at', style: TextStyle(fontSize: 12)),
                FutureBuilder<String>(
                  future: getCurrentLocation(userProfile),
                  builder: (context, snapshot) {
                    print(snapshot.connectionState);
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text('Loading...',
                          style: TextStyle(fontWeight: FontWeight.bold));
                    }
                    if (snapshot.hasData) {
                     return Text(snapshot.data!,
                          style: const TextStyle(fontWeight: FontWeight.bold));
                    }
                    if (snapshot.hasError) {
                      return const Text('An error occured',
                          style: TextStyle(fontWeight: FontWeight.bold));
                    }
                    return const CircularProgressIndicator();
                  },
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: SizedBox(
                    child: ListView.builder(itemCount: interests?.length ?? 0,
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemBuilder:
                    (context, index) {
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
                    Expanded(
                      flex: 10,
                      child: SizedBox(
                        height: 30,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(5)),
                          onPressed: () => userProfile == currentUserPatroneProfile ? Navigator.pushNamed(context, 'patrone_registration'
                          ) : isFollowingUser(userProfile).then((isFollowing) {
                            isFollowing ? unfollowUser(userProfile) : followUser(userProfile);
                          }),
                          child: userProfile == currentUserPatroneProfile ? Text('Edit Profile',
                              style: TextStyle(fontSize: 12)) : FutureBuilder<bool>(future: isFollowingUser(userProfile),
                              builder: (context, snapshot) {
                            return Text(snapshot.data! ? 'Unfollow' : 'Follow',
                                style: TextStyle(fontSize: 12));
                          }),
                        ),
                      ),
                    ),
                    const Spacer(),
                    userProfile == currentUserPatroneProfile ? SizedBox() : Expanded(
                      flex: 10,
                      child: SizedBox(
                        height: 30,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(5)),
                          onPressed: () {
                            firestore.collection('messages').where('participants', arrayContains: [currentUserProfile, userProfile.parent.parent]).get().then((result) {
                              if (result.size == 0) {
                                firestore.collection('messages').add({
                                  'participants': [currentUserProfile, userProfile.parent.parent],
                                }).then((messages) {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ConversationScreen(chats: messages,)));
                                });
                              } else {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ConversationScreen(chats: result.docs[0].reference,)));
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
    super.key, required this.createdPosts, required this.userProfile,
  });

  final DocumentReference userProfile;
  final List? createdPosts;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
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
                        crossAxisCount: 2, childAspectRatio: 3/4
                      ),
                      itemCount: createdPosts?.length ?? 0,
                      itemBuilder: (BuildContext context, int index) {
                        DocumentReference post = createdPosts?[index];
                        return StreamBuilder<DocumentSnapshot>(
                          stream: post.snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return GestureDetector(
                                onTap: () => showDialog(context: 
                                context, builder: (context) => AlertDialog(
                                  contentPadding: const EdgeInsets.all(0),
                                  content: FeedImage(snapshot: snapshot.data!,),
                                )),
                                child: Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(snapshot.data!.get
                                        ('image'))
                                    ),
                                  ),
                                ),
                              );
                            }
                            else if (snapshot.hasError) {
                              return const Center(child: Text('Something went '
                                  'wrong'));
                            } else {
                              return const Center(child: CircularProgressIndicator());
                            }
                          }
                        );
                      },
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: firestore.collection('feed').where('likes',
                          arrayContains: userProfile).snapshots(),
                      builder: (context, likedPosts) {
                        List<QueryDocumentSnapshot<Object?>>? liked = likedPosts
                            .data?.docs;
                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                                childAspectRatio: 2/3,
                          ),
                          itemCount: liked?.length ?? 0,
                          itemBuilder: (BuildContext context, int index) {
                            Map<String, dynamic> like = liked![index].data() as Map<String, dynamic>;
                            return Container(
                                decoration: BoxDecoration(
                                image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(like['image'])
                            )),
                            );
                          },
                        );
                      }
                    ),
                    GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      itemCount: 9,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          color: Colors.orange,
                          child: Center(
                            child: Text(
                              'Saved $index',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 20),
                            ),
                          ),
                        );
                      },
                    ),

                  ],
                ),
              ),
            ),
            TabBar(
              tabs: const [
                Tab(icon: Icon(Icons.place),),
                Tab(icon: Icon(Icons.favorite)),
                Tab(icon: Icon(Icons.bookmark)),
              ],
              labelColor: Theme.of(context).colorScheme.secondary,
              unselectedLabelColor: Theme.of(context)
                  .colorScheme
                  .secondary
                  .withOpacity(0.375),
            ),
          ],
        ),
      ),
    );
  }
}

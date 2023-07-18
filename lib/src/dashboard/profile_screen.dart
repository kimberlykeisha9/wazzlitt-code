import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wazzlitt/src/dashboard/feed_image.dart';
import 'package:wazzlitt/user_data/user_data.dart';
import '../app.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

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
      stream: currentUserPatroneProfile.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Map<String, dynamic> data = snapshot.data!.data() as Map<String,
              dynamic>;
          print(data);
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
                      isGangMember,),
                    ActivityTab(createdPosts: createdPosts,),
                  ],
                ),
              ),
            ],
          );
        }
        else if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'));
        } else {
          return Center(child: CircularProgressIndicator());
        }
      }
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({
    super.key,
    required this.coverPhoto,
    required this.profilePhoto,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.bio,
    required this.interests,
    required this.isGangMember,
    required this.isHivPositive,
  });

  final String? coverPhoto;
  final String? profilePhoto;
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? bio;
  final List? interests;
  final bool? isGangMember;
  final bool? isHivPositive;


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
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      isGangMember != null ? Chip(label: Text(isGangMember! ?
                          'Gang Member' : 'Not Gang Member')) : SizedBox(),
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
                        child: profilePhoto == null ? const Icon(Icons
                            .account_circle, size: 100) : null,
                      ),
                      isHivPositive != null ? Chip(label: Text(isHivPositive! ?
                      'HIV Postive' : 'HIV Negative')) :
                      SizedBox(),
                    ],
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
                Text('$firstName $lastName',
                    style: const TextStyle(fontWeight: FontWeight
                        .bold)),
                const SizedBox(height: 5),
                Text('@$username', style: TextStyle(fontSize:
                12)),
                const SizedBox(height: 20),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text('0', style: TextStyle(fontWeight: FontWeight
                            .bold, fontSize: 18)),
                        Text('Posts', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    Column(
                      children: [
                        Text('0', style: TextStyle(fontWeight: FontWeight
                            .bold, fontSize: 18)),
                        Text('Followers', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    Column(
                      children: [
                        Text('0', style: TextStyle(fontWeight: FontWeight
                            .bold, fontSize: 18)),
                        Text('Following', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(bio ?? 'No Bio', textAlign: TextAlign.center),
                const SizedBox(height: 20),
                const Text('Star Sign', style: TextStyle(fontSize: 12)),
                const Text('Capricorn',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
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
                          onPressed: () {},
                          child: const Text('Edit Profile',
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
    super.key, required this.createdPosts,
  });

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
                              return Center(child: Text('Something went '
                                  'wrong'));
                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          }
                        );
                      },
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: firestore.collection('feed').where('likes',
                          arrayContains: currentUserProfile).snapshots(),
                      builder: (context, likedPosts) {
                        List<QueryDocumentSnapshot<Object?>>? liked = likedPosts
                            .data?.docs;
                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                          ),
                          itemCount: liked?.length ?? 0,
                          itemBuilder: (BuildContext context, int index) {
                            var like = liked[index];
                            return Container(
                              color: Colors.red,
                              child: Center(
                                child: Text(
                                  'Liked $index',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                              ),
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

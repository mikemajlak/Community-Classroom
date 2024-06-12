//ui for the community screen

import 'package:community_classroom/core/common/error_text.dart';
import 'package:community_classroom/core/common/loader.dart';
import 'package:community_classroom/core/common/post_card.dart';
import 'package:community_classroom/features/auth/controller/auth_controller.dart';
import 'package:community_classroom/features/community/controller/community_controller.dart';
import 'package:community_classroom/models/community_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

//screen to show all details of community
class CommunityScreen extends ConsumerWidget {
  final String name;
  const CommunityScreen({super.key, required this.name});

  //https://localhost:4000/r/communityName where community name is 
  //different for differnt community then we have to create the dynamic route
  //for different community name open differnt community screen

  //method to navigate to mod tools
  void navigateToModTools(BuildContext context) {
    Routemaster.of(context).push('/mod-tools/$name');
  }

  //method to join the community
  void joinCommunity(WidgetRef ref, Community community, BuildContext context) {
    ref
        .read(communityControllerProvider.notifier)
        .joinCommunity(community, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    return Scaffold(
      body: ref.watch(getCommunityByNameProvider(name)).when(
          data: (community) => NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      floating: true,
                      snap: true,
                      expandedHeight: 150,
                      flexibleSpace: Stack(children: [
                        Positioned.fill(
                            child: Image.network(
                          community.banner,
                          fit: BoxFit.cover,
                        ))
                      ]),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                          delegate: SliverChildListDelegate([
                        Align(
                          alignment: Alignment.topLeft,
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(community.avatar),
                            radius: 35,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'r/${community.name}',
                              style: const TextStyle(
                                  fontSize: 19, fontWeight: FontWeight.bold),
                            ),
                          if(!isGuest)
                            community.mods.contains(user.uid)
                                ? //if user is the moderator of the community then show mods tools button
                                OutlinedButton(
                                    onPressed: () =>
                                        navigateToModTools(context),
                                    style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 25),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        )),
                                    child: const Text('Mods Tools'))
                                : OutlinedButton(
                                    //if user is not the moderator then show join or joined button
                                    onPressed: () =>
                                        joinCommunity(ref, community, context),
                                    style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 25),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        )),
                                    child: Text(community.members
                                            .contains(user.uid)
                                        ? 'Joined'
                                        : 'Join')) //when user is the part of community then show joined else join button to join the community
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text('${community.members.length} members'),
                        )
                      ])),
                    )
                  ];
                },
                body: ref.watch(getCommunityPostsProvider(name)).when(
                  data: (posts) {
                    return ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (BuildContext context, int index) {
                          final post = posts[index];
                          return PostCard(post: post);
                        });
                  },
                  error: (Object error, StackTrace stackTrace) {
                    return ErrorText(error: error.toString());
                  },
                  loading: () {
                    return const Loader();
                  },
                ),
              ),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader()),
    );
  }
}

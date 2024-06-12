import 'package:community_classroom/core/common/error_text.dart';
import 'package:community_classroom/core/common/loader.dart';
import 'package:community_classroom/core/common/login_button.dart';
import 'package:community_classroom/features/auth/controller/auth_controller.dart';
import 'package:community_classroom/features/community/controller/community_controller.dart';
import 'package:community_classroom/models/community_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class CommunityListDrawer extends ConsumerWidget {
  const CommunityListDrawer({super.key});

  //navigate to create community page to create new community
  void navigateToCreateCommunity(BuildContext context) {
    Routemaster.of(context).push('/create-community');
  }

  //method to navigate to the community page
  void navigateToCommunity(BuildContext context, Community community) {
    Routemaster.of(context).push('/r/${community.name}'); //dynamic route  
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;


    //list tile for all the communities
    return Drawer(
      child: SafeArea(
          child: Column(
        children: [
          isGuest ? const SignInButton() :
          ListTile(
            title: const Text('Create a community'),
            leading: const Icon(Icons.add),
            onTap: () => navigateToCreateCommunity(context),
          ),
        if(!isGuest)
          ref.watch(userCommunitiesProvider).when(
              data: (communities) => Expanded(
                    child: ListView.builder(
                      //listview builder
                      itemCount: communities.length,
                      itemBuilder: (BuildContext context, int index) {
                        final community = communities[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(community.avatar),
                          ),
                          title: Text(
                              'r/${community.name}'), //we don't use r in community model name as 'r/name' because every when user search for the community he has to type in r
                          onTap: () => navigateToCommunity(context, community),
                        );
                      },
                    ),
                  ),
              error: (error, stackTrace) => ErrorText(error: error.toString()),
              loading: () => const Loader()),
        ],
      )),
    );
  }
}

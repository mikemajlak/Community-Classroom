//homescreen after usres logged in
import "package:community_classroom/core/Constants/constants.dart";
import 'package:community_classroom/features/auth/controller/auth_controller.dart';
import "package:community_classroom/features/home/delegates/search_community_delegate.dart";
import "package:community_classroom/features/home/drawers/community_list_drawer.dart";
import "package:community_classroom/features/home/drawers/profile_drawer.dart";
import "package:community_classroom/theme/pallete.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

//consumer stateful widget for because state of this screen 
//changes when user navigate to feed screen or post screen
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _page = 0;

  //method when user navigates to different page
  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  //method to open drawer when user clicks on the menu icon takes
  // the context of iconbutton widget
  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  //method to open end drawer(profile drawer) when user
  // clicks on end circle of user
  void displayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    final currentTheme = ref.watch(themeNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: false,
        leading: Builder(builder: (context) {
          //wrap with builder to get the context to open
          // the drawer because drawer need the context
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => displayDrawer(context),
          );
        }),
        actions: [
          IconButton(
              onPressed: () => showSearch(
                  context: context, delegate: SearchCommunityDelegate(ref)),
              icon: const Icon(Icons.search)),
          Builder(builder: (context) {
            return IconButton(
              icon: CircleAvatar(
                backgroundImage: NetworkImage(user.profilePic),
              ),
              onPressed: () => displayEndDrawer(context),
            );
          })
        ],
      ),
      body: Constants.tabWidget[_page], //which widget to show either the feed screen or post screen
      drawer: const CommunityListDrawer(), //front drawer for community list
      endDrawer: isGuest ? null : const ProfileDrawer(), //end drawer for profile
      bottomNavigationBar: isGuest ? null : CupertinoTabBar(
        activeColor: currentTheme.iconTheme.color,
        backgroundColor: currentTheme.backgroundColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: '')
        ],
        onTap: (page) => onPageChanged(page), //on tapping one of the button in bottom navigation bar page is given as argument then only we have to change the global value of page in set state
        currentIndex: _page,
      ),
    );
  }
}

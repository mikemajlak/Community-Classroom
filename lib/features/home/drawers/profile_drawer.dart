//profile drawer of user

import 'package:community_classroom/features/auth/controller/auth_controller.dart';
import 'package:community_classroom/theme/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

//extends consumer widget to get userprovider instance so to get usermodel data
class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});

  //method to logout calls the authcontroller logout method
  void logOut(WidgetRef ref) {
    ref.read(authControllerProvider.notifier).logOut();
  }

  //navigate to user screen
  void navigateToUserProfile(String uid, BuildContext context) {
    Routemaster.of(context).push('/u/$uid');
  }

  //method to toggle the theme
  void toggleTheme(WidgetRef ref) {
    ref.watch(themeNotifierProvider.notifier).toggleTheme();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;

    return Drawer(
      child: SafeArea(
          child: Column(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(user.profilePic),
            radius: 70,
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            'u/${user.name}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(),
          ListTile(
            title: const Text('My Profile'),
            leading: const Icon(Icons.person),
            onTap: () => navigateToUserProfile(user.uid, context),
          ),
          ListTile(
            title: const Text('Log Out'),
            leading: Icon(
              Icons.logout,
              color: Pallete.redColor,
            ),
            onTap: () => logOut(ref),
          ),
          Switch.adaptive(value: ref.watch(themeNotifierProvider.notifier).mode == ThemeMode.dark, onChanged: (val) => toggleTheme(ref)),
        ],
      )),
    );
  }
}

//logged out route
import 'package:community_classroom/features/auth/screens/login_screen.dart';
import 'package:community_classroom/features/community/screens/add_mods_screen.dart';
import 'package:community_classroom/features/community/screens/community_screen.dart';
import 'package:community_classroom/features/community/screens/create_community_screen.dart';
import 'package:community_classroom/features/community/screens/edit_community_screen.dart';
import 'package:community_classroom/features/community/screens/mod_tools_screen.dart';
import 'package:community_classroom/features/home/screens/home_screen.dart';
import 'package:community_classroom/features/post/screens/add_post_type_screen.dart';
import 'package:community_classroom/features/post/screens/comment_screen.dart';
import 'package:community_classroom/features/user_profile/screens/edit_profile_screen.dart';
import 'package:community_classroom/features/user_profile/screens/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

//logged out route to login screen
final loggedOutRoute =
    RouteMap(routes: {'/': (_) => const MaterialPage(child: LoginScreen())});

//logged in route to home screen
final loggedInRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: HomeScreen()),
  '/create-community': (_) =>
      const MaterialPage(child: CreateCommunityScreen()),
  //dynamic route differnent name lead to fetching of different community
  '/r/:name': (route) => MaterialPage(
          child: CommunityScreen(
        name: route.pathParameters['name']!,
      )), //route.pathparameters return a map where key is the string name in the route

  //need the name to edit the community
  '/mod-tools/:name': (routeData) => MaterialPage(
          child: ModToolsScreen(
        name: routeData.pathParameters['name']!,
      )),
  '/edit-community/:name': (routeData) => MaterialPage(
          child: EditCommunityScreen(
        name: routeData.pathParameters['name']!,
      )),
  '/add-mods/:name': (routeData) => MaterialPage(
          child: AddModsScreen(
        name: routeData.pathParameters['name']!,
      )),
  '/u/:uid' : (routeData) => MaterialPage(child: UserProfile(uid: routeData.pathParameters['uid']!)),
  '/edit-profile/:uid' : (routeData) => MaterialPage(child: EditProfileScreen(uid: routeData.pathParameters['uid']!)),
  '/add-post/:type' : (routeData) => MaterialPage(child: AddPostTypeScreen(type: routeData.pathParameters['type']!)),
  '/post/:postId/comments' : (routeData) => MaterialPage(child: CommentScreen(postId: routeData.pathParameters['postId']!)),

});


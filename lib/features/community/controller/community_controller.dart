import 'dart:io';

import 'package:community_classroom/core/failure.dart';
import 'package:community_classroom/models/post_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:routemaster/routemaster.dart';

import 'package:community_classroom/core/Constants/constants.dart';
import 'package:community_classroom/core/providers/storage_repository_provider.dart';
import 'package:community_classroom/core/utils.dart';
import 'package:community_classroom/features/auth/controller/auth_controller.dart';
import 'package:community_classroom/features/community/repository/community_repository.dart';
import 'package:community_classroom/models/community_model.dart';

//provider for list of communities
final userCommunitiesProvider = StreamProvider((ref) {
  final communityController = ref.watch(communityControllerProvider.notifier);
  return communityController.getUserCommunities();
});

//provider for community controller class which is of type of stateNotifier so we require the statenotifier provider
final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
  final communityRepository = ref.watch(communityRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return CommunityController(
      communityRepository: communityRepository,
      ref: ref,
      storageRepository: storageRepository);
});

//provider for community by name stream provider
final getCommunityByNameProvider = StreamProvider.family((ref, String name) {
  return ref
      .watch(communityControllerProvider.notifier)
      .getCommunityByName(name);
});

//provider for search community list query is type of stream provider to cache the instance
final searchCommunityProvider = StreamProvider.family((ref, String query) {
  return ref.watch(communityControllerProvider.notifier).searchCommunity(query);
});

//provider for getting community post
final getCommunityPostsProvider = StreamProvider.family((ref, String communityName) {
  return ref
      .watch(communityControllerProvider.notifier)
      .getCommunityPosts(communityName);
});

//for loading, this class extends statenotifer of bool used when ui call to loading spinner
class CommunityController extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;

  //constructor
  CommunityController(
      {required CommunityRepository communityRepository,
      required ref,
      required StorageRepository storageRepository})
      : _communityRepository = communityRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  //method to create the community require the name of the community taken from the text editing controller and the context for the loading part
  void createCommunity(String name, BuildContext context) async {
    //state is used for showing loader and for using this we need to use stateNotifierProvider<communityController, bool> for accessing state use ref.watch(provider) and for instance of class use - ref.watch(provider.notifier)
    state = true;

    //get the uid of current user from user provider for making the current user as the member of new community
    final uid = _ref.read(userProvider)?.uid ?? '';
    //create the community class instance in controller part
    Community community = Community(
        id: name,
        name: name,
        banner: Constants.bannerDefault,
        avatar: Constants.avatarDefault,
        //the person who created the community is the first member of the community and the modulator of community
        members: [uid],
        mods: [uid]);

    state = false;
    final res = await _communityRepository.createCommunity(community);
    res.fold((l) => showSnackbar(context, l.message), (r) {
      showSnackbar(context, "Community created successfully!");
      Routemaster.of(context).pop();
    });
  }

  //method to join the community controller version which have the main business logic
  Future<void> joinCommunity(Community communtiy, BuildContext context) async {
    final user = _ref.read(userProvider)!;

    //same method to join and leave the community as there is only one button
    //if the current user is the part of community then he wants to leave the communitiy
    Either<Failure, void> res;
    if (communtiy.members.contains(user.uid)) {
      res = await _communityRepository.leaveCommunity(communtiy.name, user.uid);
    } else {
      //else current user is not a part of community then he wants to join the community
      res = await _communityRepository.joinCommunity(communtiy.name, user.uid);
    }

    //get the res as error or success
    res.fold((l) => showSnackbar(context, l.message), (r) {
      if (communtiy.members.contains(user.uid)) {
        showSnackbar(context, 'Community left successfully!');
      } else {
        showSnackbar(context, 'Community joined successfully!');
      }
    });
  }

  //method to get all the community which the user is part of by getting the uid of current user by user provider and call the community repository method to get the communities
  Stream<List<Community>> getUserCommunities() {
    final uid = _ref.read(userProvider)!.uid;
    return _communityRepository.getUserCommunities(uid);
  }

  //method to edit community require file profile file and banner file context and community in which we are changing the data
  void editCommunity(
      {required File? bannerFile,
      required File? profileFile,
      required BuildContext context,
      required Community community}) async {
    //for loader to show because this process takes time
    state = true;
    //for profile file
    if (profileFile != null) {
      //communities/profile/${community.name} as id for diff. community this is the folder structure of firebase storage to store the imagees
      final res = await _storageRepository.storeFile(
          //store file function is of type Future<Either<Failure,string>> to get the download url
          path: 'communities/profile',
          id: community.name,
          file: profileFile);

      res.fold((l) => showSnackbar(context, l.message),
          (r) => community = community.copyWith(avatar: r));
    }

    //for banner file
    if (bannerFile != null) {
      //communities/banner/${community.name} as id for diff. community this is the folder structure of firebase storage to store the imagees
      final res = await _storageRepository.storeFile(
          //store file function is of type Future<Either<Failure,string>> to get the download url
          path: 'communities/banner',
          id: community.name,
          file: bannerFile);
      //change the community instance with community copywith new banner
      res.fold((l) => showSnackbar(context, l.message),
          (r) => community = community.copyWith(banner: r));
    }
    //change the data in collection of community in firestore
    final res = await _communityRepository.editCommunity(community);

    //when the process completes change the loader state to false
    state = false;

    //when the success occures pop of the current screen
    res.fold((l) => showSnackbar(context, l.message),
        (r) => Routemaster.of(context).pop());
  }

  //method to get the community by name
  Stream<Community> getCommunityByName(String name) {
    return _communityRepository.getCommunityByName(name);
  }

  //method to search the community by name takes query as argument
  Stream<List<Community>> searchCommunity(String query) {
    return _communityRepository.searchCommunity(query);
  }

  //method to add mods
  void addMods(
      String communityName, List<String> uids, BuildContext context) async {
    final res = await _communityRepository.addMods(communityName, uids);
    res.fold((l) => showSnackbar(context, l.message),
        (r) => Routemaster.of(context).pop());
  }

  Stream<List<Post>> getCommunityPosts(String communityName) {
    return _communityRepository.getCommunityPosts(communityName);
  }
}

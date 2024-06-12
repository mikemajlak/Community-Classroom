import 'dart:io';

import 'package:community_classroom/core/enums/enums.dart';
import 'package:community_classroom/core/providers/storage_repository_provider.dart';
import 'package:community_classroom/core/utils.dart';
import 'package:community_classroom/features/auth/controller/auth_controller.dart';
import 'package:community_classroom/features/post/repository/post_repository.dart';
import 'package:community_classroom/features/user_profile/controller/user_profile_controller.dart';
import 'package:community_classroom/models/comment_model.dart';
import 'package:community_classroom/models/community_model.dart';
import 'package:community_classroom/models/post_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

//provider for post controller of type statenotifierprovider
final postControllerProvider =
    StateNotifierProvider<PostController, bool>((ref) {
  final communityRepository = ref.watch(postRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return PostController(
      postRepository: communityRepository,
      ref: ref,
      storageRepository: storageRepository);
});

//provider for the user post
final userPostProvider =
    StreamProvider.family((ref, List<Community> communities) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchUserPosts(communities);
});

final guestPostProvider =
    StreamProvider((ref) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchGuestPosts();
});

//provider for post by postid
final getPostByIdProvider = StreamProvider.family((ref, String postId) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.getPostById(postId);
});

//stream provider for the comments
final getPostCommentProvider = StreamProvider.family((ref, String postId) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchPostComments(postId);
});

class PostController extends StateNotifier<bool> {
  final PostRepository _postRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;

  //constructor
  PostController(
      {required PostRepository postRepository,
      required Ref ref,
      required StorageRepository storageRepository})
      : _postRepository = postRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  //method to share text post (controller part) parameters title of post and description of post
  void shareTextPost(
      {required BuildContext context,
      required String title,
      required String description,
      required Community selectedCommunity}) async {
    state = true;
    //id of the post
    String postId = const Uuid().v1();

    //watch the current user
    final user = _ref.read(userProvider)!;

    //creating the post instance
    final Post post = Post(
        id: postId,
        title: title,
        communityName: selectedCommunity.name,
        communityProfilePic: selectedCommunity.avatar,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        username: user.name,
        uid: user.uid,
        type: 'text',
        createdAt: DateTime.now(),
        awards: [],
        description: description);

    final res = await _postRepository.addPost(post);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.textPost);
    state = false;
    res.fold((l) => showSnackbar(context, l.message), (r) {
      showSnackbar(context, 'Posted successfully');
      Routemaster.of(context).pop();
    });
  }

  //method to share link post
  void shareLinkPost(
      {required BuildContext context,
      required String title,
      required String link,
      required Community selectedCommunity}) async {
    state = true;
    //id of the post
    String postId = const Uuid().v1();

    //watch the current user
    final user = _ref.read(userProvider)!;

    //creating the post instance
    final Post post = Post(
        id: postId,
        title: title,
        communityName: selectedCommunity.name,
        communityProfilePic: selectedCommunity.avatar,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        username: user.name,
        uid: user.uid,
        type: 'link',
        createdAt: DateTime.now(),
        awards: [],
        link: link);

    final res = await _postRepository.addPost(post);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.linkPost);
    state = false;
    res.fold((l) => showSnackbar(context, l.message), (r) {
      showSnackbar(context, 'Posted successfully');
      Routemaster.of(context).pop();
    });
  }

  //method to post image post and store it in firebase storage so we can use it again
  void shareImagePost(
      {required BuildContext context,
      required String title,
      required File? file,
      required Community selectedCommunity}) async {
    state = true;
    //id of the post
    String postId = const Uuid().v1();

    //watch the current user
    final user = _ref.read(userProvider)!;

    //store it in firestorage with the help of storage repository
    final imageRes = await _storageRepository.storeFile(
        path: 'posts/${selectedCommunity.name}', id: postId, file: file);

    imageRes.fold((l) => showSnackbar(context, l.message), (r) async {
      //when the success occurs it return the download url and we save it into post model

      //creating the post instance
      final Post post = Post(
          id: postId,
          title: title,
          communityName: selectedCommunity.name,
          communityProfilePic: selectedCommunity.avatar,
          upvotes: [],
          downvotes: [],
          commentCount: 0,
          username: user.name,
          uid: user.uid,
          type: 'image',
          createdAt: DateTime.now(),
          awards: [],
          link: r); //store the link of download link

      final res = await _postRepository.addPost(post);

      //update the user karma based on the type of post 
      _ref
          .read(userProfileControllerProvider.notifier)
          .updateUserKarma(UserKarma.imagePost);
      
      //state is used for loading after all work the state become false and the loader will stop showing 
      //for this extend this class to state notifier of bool
      state = false;
      res.fold((l) => showSnackbar(context, l.message), (r) {
        showSnackbar(context, 'Posted successfully');
        Routemaster.of(context).pop();
      });
    });
  }

  //method to fetch the post for user from the community where the user is part of(controller part)
  Stream<List<Post>> fetchUserPosts(List<Community> communities) {
    if (communities.isNotEmpty) {
      //if user is part of some commmunity
      return _postRepository.fetchUserPosts(communities);
    }
    return Stream.value(
        []); //if user is not a part of any community then return empty stream of list
  }

  Stream<List<Post>> fetchGuestPosts() {
    return _postRepository.fetchGuestPosts();
  }

  //method to delete the post controller part
  void deletePost(Post post, BuildContext context) async {
    final res = await _postRepository.deletePost(post);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.deletePost);

    res.fold((l) => null,
        (r) => showSnackbar(context, 'Post Deleted Successfully!'));
  }

  //method to upvote
  void upVote(Post post) async {
    final uid = _ref.read(userProvider)!.uid;
    _postRepository.upVote(post, uid);
  }

  //method to downvote
  void downVote(Post post) async {
    final uid = _ref.read(userProvider)!.uid;
    _postRepository.downVote(post, uid);
  }

  Stream<Post> getPostById(String postId) {
    return _postRepository.getPostById(postId);
  }

  void addComment({
    required BuildContext context,
    required String text,
    required Post post,
  }) async {
    final user = _ref.read(userProvider)!;
    String commentId = const Uuid().v1();
    Comment comment = Comment(
        id: commentId,
        text: text,
        createdAt: DateTime.now(),
        postId: post.id,
        username: user.name,
        profilePic: user.profilePic);
    final res = await _postRepository.addComment(comment);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.comment);
    res.fold((l) => showSnackbar(context, l.message), (r) => null);
  }

  Stream<List<Comment>> fetchPostComments(String postId) {
    return _postRepository.getCommentsOfPosts(postId);
  }
}

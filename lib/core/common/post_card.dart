import 'package:any_link_preview/any_link_preview.dart';
import 'package:community_classroom/core/Constants/constants.dart';
import 'package:community_classroom/core/common/error_text.dart';
import 'package:community_classroom/core/common/loader.dart';
import 'package:community_classroom/features/auth/controller/auth_controller.dart';
import 'package:community_classroom/features/community/controller/community_controller.dart';
import 'package:community_classroom/features/post/controlller/post_controller.dart';
import 'package:community_classroom/models/post_model.dart';
import 'package:community_classroom/theme/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class PostCard extends ConsumerWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  //method to delete the post
  void deletePost(BuildContext context, WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).deletePost(post, context);
  }

  //method to upvote
  void upVotePost(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).upVote(post);
  }

  //method to downvote
  void downVotePost(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).downVote(post);
  }

  //method to navigate to user when current user clicks on post user icon
  void navigateToUser(BuildContext context) {
    Routemaster.of(context).push('/u/${post.uid}');
  }

  //method to navigate to community
  void navigateToCommunity(BuildContext context) {
    Routemaster.of(context).push('/r/${post.communityName}');
  }

  //method to navigate to comment screen
  void navigateToComments(BuildContext context) {
    Routemaster.of(context).push('/post/${post.id}/comments');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTypeImage = post.type == 'image';
    final isTypeLink = post.type == 'link';
    final isTypeText = post.type == 'text';

    //getting the current user for getting uid
    final user = ref.watch(userProvider)!;

    final isGuest = !user.isAuthenticated;
    final currentTheme = ref.watch(themeNotifierProvider);

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: currentTheme.drawerTheme.backgroundColor,
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 16,
                      ).copyWith(right: 0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => navigateToCommunity(context),
                                      child: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            post.communityProfilePic),
                                        radius: 16,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'r/${post.communityName}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () =>
                                                navigateToUser(context),
                                            child: Text(
                                              'u/${post.username}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                if (post.uid == user.uid)
                                  IconButton(
                                      onPressed: () => deletePost(context, ref),
                                      icon: Icon(
                                        Icons.delete,
                                        color: Pallete.redColor,
                                      ))
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                post.title,
                                style: const TextStyle(
                                    fontSize: 19, fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (isTypeImage)
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.35,
                                width: double.infinity,
                                child: Image.network(
                                  post.link!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            if (isTypeLink)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 18),
                                child: AnyLinkPreview(
                                    displayDirection:
                                        UIDirection.uiDirectionHorizontal,
                                    link: post.link!),
                              ),
                            if (isTypeText)
                              Container(
                                alignment: Alignment.bottomLeft,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0),
                                  child: Text(
                                    post.description!,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: isGuest ? () {} : () => upVotePost(ref),
                                      icon: Icon(
                                        Constants.up,
                                        size: 30,
                                        color: post.upvotes.contains(user.uid)
                                            ? Pallete.redColor
                                            : null,
                                      ),
                                    ),
                                    Text(
                                      '${post.upvotes.length - post.downvotes.length == 0 ? 'Vote' : post.upvotes.length - post.downvotes.length}',
                                      style: const TextStyle(fontSize: 17),
                                    ),
                                    IconButton(
                                      onPressed: isGuest
                                          ? () {}
                                          : () => downVotePost(ref),
                                      icon: Icon(
                                        Constants.down,
                                        size: 30,
                                        color: post.downvotes.contains(user.uid)
                                            ? Pallete.blueColor
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () =>
                                          navigateToComments(context),
                                      icon: const Icon(Icons.comment),
                                    ),
                                    Text(
                                      '${post.commentCount == 0 ? 'Comment' : post.commentCount}',
                                      style: const TextStyle(fontSize: 17),
                                    ),
                                  ],
                                ),
                                ref
                                    .watch(getCommunityByNameProvider(
                                        post.communityName))
                                    .when(
                                        data: (community) {
                                          if (community.mods
                                              .contains(user.uid)) {
                                            return IconButton(
                                              icon: const Icon(
                                                  Icons.admin_panel_settings),
                                              onPressed: () =>
                                                  deletePost(context, ref),
                                            );
                                          }
                                          return const SizedBox();
                                        },
                                        error: (error, stackTrace) =>
                                            ErrorText(error: error.toString()),
                                        loading: () => const Loader()),
                              ],
                            )
                          ]),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}

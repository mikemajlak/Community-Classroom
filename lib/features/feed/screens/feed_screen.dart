import 'package:community_classroom/core/common/error_text.dart';
import 'package:community_classroom/core/common/loader.dart';
import 'package:community_classroom/core/common/post_card.dart';
import 'package:community_classroom/features/auth/controller/auth_controller.dart';
import 'package:community_classroom/features/community/controller/community_controller.dart';
import 'package:community_classroom/features/post/controlller/post_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;

    if(!isGuest){
     return ref.watch(userCommunitiesProvider).when(
        data: (communities) => ref.watch(userPostProvider(communities)).when(
            data: (posts) {
              return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (BuildContext context, int index) {
                    final post = posts[index];
                    return PostCard(post: post);
                  });
            },
            error: (error, stackTrace) {
              if (kDebugMode) print(error);
              return ErrorText(error: error.toString());
            },
            loading: () => const Loader()),
        error: (error, stackTrace) => ErrorText(error: error.toString()),
        loading: () => const Loader());
  } 
  return ref.watch(userCommunitiesProvider).when(
        data: (communities) => ref.watch(guestPostProvider).when(
            data: (posts) {
              return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (BuildContext context, int index) {
                    final post = posts[index];
                    return PostCard(post: post);
                  });
            },
            error: (error, stackTrace) {
              if (kDebugMode) print(error);
              return ErrorText(error: error.toString());
            },
            loading: () => const Loader()),
        error: (error, stackTrace) => ErrorText(error: error.toString()),
        loading: () => const Loader());
  }
}

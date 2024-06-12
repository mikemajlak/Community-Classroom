import 'package:community_classroom/core/common/error_text.dart';
import 'package:community_classroom/core/common/loader.dart';
import 'package:community_classroom/core/common/post_card.dart';
import 'package:community_classroom/features/auth/controller/auth_controller.dart';
import 'package:community_classroom/features/post/controlller/post_controller.dart';
import 'package:community_classroom/features/post/widget/comment_card.dart';
import 'package:community_classroom/models/post_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommentScreen extends ConsumerStatefulWidget {
  final String postId;
  const CommentScreen({super.key, required this.postId});

  @override
  ConsumerState<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends ConsumerState<CommentScreen> {
  final commentController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
  }

  void addComment(Post post) {
    ref.read(postControllerProvider.notifier).addComment(
        context: context, text: commentController.text.trim(), post: post);

    setState(() {
      commentController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Comments'),
        centerTitle: true,
      ),
      body: ref.watch(getPostByIdProvider(widget.postId)).when(
          data: (post) {
            return Column(
              children: [
                PostCard(post: post),
              if(!isGuest)
                TextField(
                  onSubmitted: (val) => addComment(post),
                  controller: commentController,
                  decoration: const InputDecoration(
                    hintText: "What are your thoughts?",
                    filled: true,
                    border: InputBorder.none,
                  ),
                ),
                ref.watch(getPostCommentProvider(widget.postId)).when(
                    data: (comments) {
                      return Expanded(
                        child: ListView.builder(
                            itemCount: comments.length,
                            itemBuilder: (BuildContext context, int index) {
                              final comment = comments[index];
                              return CommentCard(comment: comment);
                            }),
                      );
                    },
                    error: (error, stackTrace) {
                      return ErrorText(error: error.toString());
                    },
                    loading: () => const Loader()),
              ],
            );
          },
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader()),
    );
  }
}

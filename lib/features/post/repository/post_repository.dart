import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_classroom/core/Constants/firebase_constants.dart';
import 'package:community_classroom/core/failure.dart';
import 'package:community_classroom/core/providers/firebase_provider.dart';
import 'package:community_classroom/core/type_defs.dart';
import 'package:community_classroom/models/comment_model.dart';
import 'package:community_classroom/models/community_model.dart';
import 'package:community_classroom/models/post_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final postRepositoryProvider = Provider((ref) {
  return PostRepository(firestore: ref.watch(fireStoreProvider));
});

class PostRepository {
  final FirebaseFirestore _firestore;
  PostRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  //getter for post collection
  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);

  //getter for comments collection
  CollectionReference get _comments =>
      _firestore.collection(FirebaseConstants.commentsCollection);

  //method to add the post in firestore collection takes the parameter of post instance
  FutureVoid addPost(Post post) async {
    try {
      return right(_posts.doc(post.id).set(post.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  //method to get all the post of communities where the user is part of (for feed screen)
  Stream<List<Post>> fetchUserPosts(List<Community> communities) {
    return _posts
        .where('communityName',
            whereIn: communities.map((e) => e.name).toList())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) => event.docs
            .map(
              (e) => Post.fromMap(e.data() as Map<String, dynamic>),
            )
            .toList());
  }


  Stream<List<Post>> fetchGuestPosts() {
    return _posts
        .orderBy('createdAt', descending: true).limit(10)
        .snapshots()
        .map((event) => event.docs
            .map(
              (e) => Post.fromMap(e.data() as Map<String, dynamic>),
            )
            .toList());
  }

  //method to delete the post post can be deleted by the user who posted it or modulator of the community
  FutureVoid deletePost(Post post) async {
    try {
      return right(_posts
          .doc(post.id)
          .delete()); //use the delete method of collection firestore each post has unique post id
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  //method to upvote the post
  void upVote(Post post, String uid) {
    //if user already down votes the post and want to upvote then first remove is from downvote and put in upvote
    if (post.downvotes.contains(uid)) {
      _posts.doc(post.id).update({
        'downvotes': FieldValue.arrayRemove([uid])
      });
    }

    //if user already upvotes the post then remove it from upvote
    if (post.upvotes.contains(uid)) {
      _posts.doc(post.id).update({
        'upvotes': FieldValue.arrayRemove([uid])
      });
    } else {
      //else user not upvoted nor downvoted then put it in upvote
      _posts.doc(post.id).update({
        'upvotes': FieldValue.arrayUnion([uid])
      });
    }
  }

  //method to downvote the post
  void downVote(Post post, String uid) {
    //if user already down votes the post and want to upvote then first remove is from downvote and put in upvote
    if (post.upvotes.contains(uid)) {
      _posts.doc(post.id).update({
        'upvotes': FieldValue.arrayRemove([uid])
      });
    }

    //if user already upvotes the post then remove it from upvote
    if (post.downvotes.contains(uid)) {
      _posts.doc(post.id).update({
        'downvotes': FieldValue.arrayRemove([uid])
      });
    } else {
      //else user not upvoted nor downvoted then put it in upvote
      _posts.doc(post.id).update({
        'downvotes': FieldValue.arrayUnion([uid])
      });
    }
  }

  //method to get the specific post with the use of post id for comment section
  Stream<Post> getPostById(String postId) {
    return _posts
        .doc(postId)
        .snapshots()
        .map((event) => Post.fromMap(event.data() as Map<String, dynamic>));
  }

  //method to add comment in the comment collection in firestore
  FutureVoid addComment(Comment comment) async {
    try {
      await _comments.doc(comment.id).set(comment.toMap());
      return right(_posts.doc(comment.postId).update({
        'commentCount' : FieldValue.increment(1), //increment the comment count
      })); 
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  //method to get the list of commmnets on the post
  Stream<List<Comment>> getCommentsOfPosts(String postId) {
    return _comments
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) => event.docs
            .map(
              (e) => Comment.fromMap(e.data() as Map<String, dynamic>),
            )
            .toList());
  }
}

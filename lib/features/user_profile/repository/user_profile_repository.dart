
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_classroom/core/Constants/firebase_constants.dart';
import 'package:community_classroom/core/failure.dart';
import 'package:community_classroom/core/providers/firebase_provider.dart';
import 'package:community_classroom/core/type_defs.dart';
import 'package:community_classroom/models/post_model.dart';
import 'package:community_classroom/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final userProfileRepositoryProvider = Provider((ref) {
  return UserProfileRepository(firestore: ref.watch(fireStoreProvider));
});

class UserProfileRepository {
  final FirebaseFirestore _firestore;
  UserProfileRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);

  FutureVoid editProfile(UserModel user) async {
    try {
      return right(_users.doc(user.uid).update(user.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  //method to show all the post done by current user
  Stream<List<Post>> getPost(String uid) {
    return _posts
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) => event.docs
            .map((e) => Post.fromMap(e.data() as Map<String, dynamic>))
            .toList());
  }
  
  
  FutureVoid updateUserKarma(UserModel user) async {
    try {
      return right(_users.doc(user.uid).update({
        'karma': user.karma,
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}

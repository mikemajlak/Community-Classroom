import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_classroom/core/Constants/firebase_constants.dart';
import 'package:community_classroom/core/failure.dart';
import 'package:community_classroom/core/providers/firebase_provider.dart';
import 'package:community_classroom/core/type_defs.dart';
import 'package:community_classroom/models/community_model.dart';
import 'package:community_classroom/models/post_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

//provider for community repository instance (catched instance of community repository)
final communityRepositoryProvider = Provider((ref) {
  return CommunityRepository(firestore: ref.watch(fireStoreProvider));
});

class CommunityRepository {
  final FirebaseFirestore _firestore;

  CommunityRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  //get the community instance from controller part and save that in the firebase 
  //database and the logic for this is in the repository class
  FutureVoid createCommunity(Community community) async {
    try {
      //check whether the same name community exists or not if not then create 
      //one else throw exception
      var communityDoc = await _communities.doc(community.name).get();
      if (communityDoc.exists) {
        throw "Community with same name exists";
      }
      //community not exists saves this community in the firebase database
      return right(_communities.doc(community.name).set(community.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  //method to join the community takes the community name and user id of the user 
  //who wants to join the community
  FutureVoid joinCommunity(String communityName, String userId) async {
    try {
      return right(_communities.doc(communityName).update({
        'members': FieldValue.arrayUnion([
          userId
        ]), // union the new userid to the members array in firestore using FieldValue 
        //class arrayUnion method
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  //method to leave the community same as of join method but this time we remove the 
  //current user id from the members list in database
  FutureVoid leaveCommunity(String communityName, String userId) async {
    try {
      return right(_communities.doc(communityName).update({
        'members': FieldValue.arrayRemove([userId]),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  //method to return the list of communities where the user is the memeber of community
  Stream<List<Community>> getUserCommunities(String uid) {
    return _communities
        .where('members', arrayContains: uid)
        .snapshots()
        .map((event) {
      //create the community empty list and fill with each document snapshot 
      //which is map (which is converted into conmmunity instance)
      List<Community> communities = [];
      for (var doc in event.docs) {
        communities.add(Community.fromMap(doc.data() as Map<String, dynamic>));
      }
      return communities;
    });
  }

  //method to return the given community instance by name given as argument from the database
  Stream<Community> getCommunityByName(String name) {
    return _communities.doc(name).snapshots().map(
        (event) => Community.fromMap(event.data() as Map<String, dynamic>));
  }

  //method to edit the community banner and avatar by passing new community as 
  //parameter and change the firestore collection of community
  FutureVoid editCommunity(Community community) async {
    try {
      //update requires a map therefore used toMap method
      return right(_communities.doc(community.name).update(community.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  //method to add mods to the community which takes the community name and the 
  //list of new moderators
  FutureVoid addMods(String communityName, List<String> uids) async {
    try {
      //update requires a map therefore used toMap method
      return right(_communities.doc(communityName).update({
        'mods': uids,
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  //method to search for community in the firestore database and return stream 
  //of list of communities
  Stream<List<Community>> searchCommunity(String query) {
    //query for searching community with the given name
    return _communities
        .where(
          'name', //attribute name is primary key for community that is unique
          //logic to search for community by name
          isGreaterThanOrEqualTo: query.isEmpty
              ? 0
              : query, //if query is empty then return nothing as without this
               //it will show every community in the database
          isLessThan: query.isEmpty
              ? null
              : query.substring(0, query.length - 1) +
                  String.fromCharCode(query.codeUnitAt(query.length - 1) + 1),
        )
        .snapshots()
        .map((event) {
      //take every community and add in the list of community as the event.docs 
      //return mapping so change it into instance of community by the static method from map
      List<Community> communities = [];
      for (var community in event.docs) {
        communities
            .add(Community.fromMap(community.data() as Map<String, dynamic>));
      }
      return communities; //return the list of communities
    });
  }

  //method to show all the post done in this community
  Stream<List<Post>> getCommunityPosts(String communityName) {
    return _posts
        .where('communityName', isEqualTo: communityName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) => event.docs
            .map((e) => Post.fromMap(e.data() as Map<String, dynamic>))
            .toList());
  }

  //getter for getting collection reference for posts
  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);

  //getter for getting collection reference for communities
  CollectionReference get _communities =>
      _firestore.collection(FirebaseConstants.communitiesCollection);
}

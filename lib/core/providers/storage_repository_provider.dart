//class to store the avatar and banner of community and user in firebase database storage we can't use firestore to store the images
import 'dart:io';

import 'package:community_classroom/core/failure.dart';
import 'package:community_classroom/core/providers/firebase_provider.dart';
import 'package:community_classroom/core/type_defs.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

//provider to get the instance of storage repository
final storageRepositoryProvider = Provider(
    (ref) => StorageRepository(firebaseStorage: ref.watch(storageProvider)));

class StorageRepository {
  final FirebaseStorage _firebaseStorage;

  const StorageRepository({required FirebaseStorage firebaseStorage})
      : _firebaseStorage = firebaseStorage;

  //method to get the download url and save to community model avatar and banner because they are string
  FutureEither<String> storeFile(
      //required the path to store the file, file and id file can be of type null in webview
      {required String path,
      required String id,
      required File? file}) async {
    try {
      //get the reference of database storage at particular point in the database
      final ref = _firebaseStorage.ref().child(path).child(id);

      //upload the file using put file method
      UploadTask uploadTask = ref.putFile(file!);

      //get the snapshot
      final snapshot = await uploadTask;

      //return right if success the string of download url
      return right(await snapshot.ref.getDownloadURL());
    } catch (e) {
      //return failure message when some error occur
      //this method doesn't throw exception it either left(failure) or right(on success)
      return left(Failure(e.toString()));
    }
  }
}

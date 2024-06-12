import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_classroom/core/Constants/constants.dart';
import 'package:community_classroom/core/Constants/firebase_constants.dart';
import 'package:community_classroom/core/failure.dart';
import 'package:community_classroom/core/providers/firebase_provider.dart';
import 'package:community_classroom/core/type_defs.dart';
import 'package:community_classroom/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';

//use ref.read outside the buld
//context doesn't reflect the change state when the state of provider is changed
final authRepositoryProvider = Provider((ref) => AuthRepository(
    auth: ref.read(authProvider),
    firestore: ref.read(fireStoreProvider),
    googleSignIn: ref.read(googleSignInProvider)));

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  //constructor
  AuthRepository(
      {required FirebaseAuth auth,
      required FirebaseFirestore firestore,
      required googleSignIn})
      : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;
  //creating getter for getting collection reference
  //syntax for getter in dart
  //type of data that we want to get | get keyword | name of the function/variable |
  // return statement if only one line then use arrow
  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  //get the users if the data in the databases changes implementing getter of 
  //stream of user data
  Stream<User?> get authStateChange => _auth.authStateChanges();

  //method to sign in with google
  FutureEither<UserModel> signInWithGoogle(bool isFromLogin) async {
    //inside try and catch block to handle the exception and throw that to 
    //controller part
    try {
      //get the google account details when user clicks on email id
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      //get the user account authentication detail
      final googleAuth = await googleUser?.authentication;

      //get the credential of user by authentication details which requires access
      // token and id token
      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);

      UserCredential userCredential;

      if(isFromLogin){
        //sign in using crendential to firebase
        userCredential =
          await _auth.signInWithCredential(credential);
      }else{
        userCredential =
            await _auth.currentUser!.linkWithCredential(credential);
      }

      //print(userCredential.user?.email);

      UserModel userModel;

      if (userCredential.additionalUserInfo!.isNewUser) {
        //if user is not stored in database then create the user model of the user 
        //and return it
        userModel = UserModel(
            name: userCredential.user!.displayName ?? 'No name',
            profilePic:
                userCredential.user!.photoURL ?? Constants.avatarDefault,
            banner: Constants.bannerDefault,
            uid: userCredential.user!.uid,
            isAuthenticated: true,
            karma: 0,
            awards: []);
        //save the usermodel(user detail) in the firestore database
        await _users.doc(userCredential.user!.uid).set(userModel.toMap());
      } else {
        //if the user is already stored in the database then return the usermodel
        userModel = await getUserData(userCredential.user!.uid).first;
      }
      return right(userModel);
    } on FirebaseAuthException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  //sign as guest
  FutureEither<UserModel> signInAsGuest() async {
    //inside try and catch block to handle the exception and throw that to
    // controller part
    try {
      var userCredential = await _auth.signInAnonymously();

      UserModel userModel = UserModel(
          name: 'Guest',
          profilePic: Constants.avatarDefault,
          banner: Constants.bannerDefault,
          uid: userCredential.user!.uid,
          isAuthenticated: false,
          karma: 0,
          awards: []);

      return right(userModel);
    } on FirebaseAuthException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<UserModel> getUserData(String uid) {
    return _users.doc(uid).snapshots().map<UserModel>(
        (event) => UserModel.fromMap(event.data() as Map<String, dynamic>));
  }

  //method to log out change the auth state so data become null to open the
  // logout route
  void logOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}

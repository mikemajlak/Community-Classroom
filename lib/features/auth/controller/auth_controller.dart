import 'package:community_classroom/core/utils.dart';
import 'package:community_classroom/features/auth/repository/auth_repository.dart';
import 'package:community_classroom/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//user data provider of type state provider as state changes if the user data changes
final userProvider = StateProvider<UserModel?>((ref) => null);

//we are not going to use AuthController authController = AuthController(); as the instance of authcontroller builds again and again as ui changes
//widget rebuild instead we use provider that cache the authcontroller instance so we doesn't have to create again and again

//Provider is read only widget it not change is value if you want to listen to changes then use other type of widget
final authControllerProvider = StateNotifierProvider<AuthController, bool>(
    (ref) => AuthController(
        authRepository: ref.watch(authRepositoryProvider), ref: ref));

//stream provider for auth state change
final authStateChangeProvider = StreamProvider((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.authStateChange;
});

//stream provider for user model for getting data of any user not only current user as we have to pass only the uid of the person that we want to get the data of
final getUserDataProvider = StreamProvider.family((ref, String uid) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.getUserModel(uid);
});

class AuthController extends StateNotifier<bool> {
  //instance of auth repository
  final AuthRepository _authRepository;
  final Ref _ref;

  //constructor
  AuthController({required AuthRepository authRepository, required Ref ref})
      : _authRepository = authRepository,
        _ref = ref,
        super(false);

  //auth state change getter in controller
  Stream<User?> get authStateChange => _authRepository.authStateChange;

  //method to sign in with goolge calls repository sign in with google
  void signInWithGoogle(BuildContext context, bool isFromLogin) async {
    state = true;
    final user = await _authRepository.signInWithGoogle(isFromLogin);
    state = false;
    user.fold(
        (l) => showSnackbar(context, l.message),
        (userModel) =>
            _ref.read(userProvider.notifier).update((state) => userModel));
  }

  //method to sign in as guest
  void signInWithGuest(BuildContext context) async {
    state = true;
    final user = await _authRepository.signInAsGuest();
    state = false;
    user.fold(
        (l) => showSnackbar(context, l.message),
        (userModel) =>
            _ref.read(userProvider.notifier).update((state) => userModel));
  }

  //creating same method as of auth repository to get user data if it is in database by calling authrepository get user data inside
  Stream<UserModel> getUserModel(String uid) {
    return _authRepository.getUserData(uid);
  }

  //method to logout user
  void logOut() async {
    _authRepository.logOut();
  }
}

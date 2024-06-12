import 'package:community_classroom/core/common/loader.dart';
import 'package:community_classroom/core/common/login_button.dart';
import 'package:community_classroom/core/Constants/constants.dart';
import 'package:community_classroom/features/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  //method to sign in as guest
  void signInAsGuest(WidgetRef ref, BuildContext context){
    ref.read(authControllerProvider.notifier).signInWithGuest(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authControllerProvider);
    return Scaffold(
        appBar: AppBar(
          title: Center(child: Image.asset(Constants.logoPath, height: 40)),
          actions: [
            TextButton(
                onPressed: () => signInAsGuest(ref, context),
                child: const Text(
                  "skip",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ))
          ],
        ),
        body: isLoading
            ? const Loader()
            : Column(
                children: [
                  const SizedBox(height: 30),
                  const Text("Dive into Anything",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          letterSpacing: 0.5)),
                  const SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(Constants.logoEmotePath, height: 400),
                  ),
                  const SizedBox(height: 30),
                  const SignInButton()
                ],
              ));
  }
}

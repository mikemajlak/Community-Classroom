import 'dart:io';

import 'package:community_classroom/core/Constants/constants.dart';
import 'package:community_classroom/core/common/error_text.dart';
import 'package:community_classroom/core/common/loader.dart';
import 'package:community_classroom/core/utils.dart';
import 'package:community_classroom/features/auth/controller/auth_controller.dart';
import 'package:community_classroom/features/user_profile/controller/user_profile_controller.dart';
import 'package:community_classroom/theme/pallete.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final String uid;
  const EditProfileScreen({super.key, required this.uid});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  //global variable for file of banner
  File? bannerFile;
  File? profileFile;
  //text editing controller for editing name
  late TextEditingController nameController;

  //the current name should be shown in text field when this widget builds
  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: ref.read(userProvider)!.name);
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

  //method to select the new banner image
  void selectBannerImage() async {
    final res = await pickImage();

    if (res != null) {
      //call the set state method to re-run the build method
      setState(() {
        bannerFile = File(res.files.first.path!);
      });
    }
  }

  //method to select the new profile image
  void selectProfileImage() async {
    final res = await pickImage();

    if (res != null) {
      //call the set state method to re-run the build method
      setState(() {
        profileFile = File(res.files.first.path!);
      });
    }
  }

  //method to save the changes in database
  void save() {
    ref.read(userProfileControllerProvider.notifier).editCommunity(
        profileFile: profileFile,
        bannerFile: bannerFile,
        context: context,
        name: nameController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(userProfileControllerProvider);
    return ref.watch(getUserDataProvider(widget.uid)).when(
        data: (user) => Scaffold(
              backgroundColor: Pallete.darkModeAppTheme.colorScheme.background,
              appBar: AppBar(
                title: const Text('Edit Profile'),
                centerTitle: false,
                actions: [
                  TextButton(onPressed:save, child: const Text('Save'))
                ],
              ),
              body: isLoading ? const Loader() 
              :Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: [
                  SizedBox(
                    height: 200,
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: selectBannerImage,
                          child: DottedBorder(
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(10),
                              dashPattern: const [10, 4],
                              strokeCap: StrokeCap.round,
                              color: Pallete.darkModeAppTheme.textTheme
                                  .bodyMedium!.color!,
                              child: Container(
                                width: double.infinity,
                                height: 150,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10)),
                                child: (bannerFile != null)
                                    ? Image.file(bannerFile!)
                                    : user.banner
                                                .isEmpty || //if the banner file is not null then show new bannre file image if it is null
                                            user.banner ==
                                                Constants.bannerDefault
                                        ? const Center(
                                            child: Icon(
                                              Icons.camera_alt_outlined,
                                              size: 40,
                                            ),
                                          )
                                        : Image.network(user.banner),
                              )),
                        ),
                        Positioned(
                          bottom:
                              20, //from the bottom of sized box up from bottom
                          left: 20, //left from the botton of the sized box
                          child: GestureDetector(
                            onTap: selectProfileImage,
                            child: profileFile != null
                                ? CircleAvatar(
                                    backgroundImage: FileImage(profileFile!),
                                    radius: 32,
                                  )
                                : CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(user.profilePic),
                                    radius: 32,
                                  ),
                          ),
                        )
                      ],
                    ),
                  ),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      filled: true,
                      hintText: 'Name',
                      focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(10)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(18),
                    ),
                  )
                ]),
              ),
            ),
        error: (error, stackTrace) => ErrorText(error: error.toString()),
        loading: () => const Loader());
  }
}

import 'dart:io';

import 'package:community_classroom/core/Constants/constants.dart';
import 'package:community_classroom/core/common/error_text.dart';
import 'package:community_classroom/core/common/loader.dart';
import 'package:community_classroom/core/utils.dart';
import 'package:community_classroom/features/community/controller/community_controller.dart';
import 'package:community_classroom/models/community_model.dart';
import 'package:community_classroom/theme/pallete.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//we use stateful widget as we are changing the image banner of community
class EditCommunityScreen extends ConsumerStatefulWidget {
  final String name;
  const EditCommunityScreen({super.key, required this.name});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditCommunityScreenState();
}

class _EditCommunityScreenState extends ConsumerState<EditCommunityScreen> {
  //global variable for file of banner
  File? bannerFile;
  File? profileFile;

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

  //to save the changes of community in database
  void save(Community community) {
    ref.read(communityControllerProvider.notifier).editCommunity(
        bannerFile: bannerFile,
        profileFile: profileFile,
        context: context,
        community: community);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);
    return ref.watch(getCommunityByNameProvider(widget.name)).when(
        data: (community) => Scaffold(
              backgroundColor: Pallete.darkModeAppTheme.colorScheme.background,
              appBar: AppBar(
                title: const Text('Edit Community'),
                centerTitle: false,
                actions: [
                  TextButton(
                      onPressed: () => save(community),
                      child: const Text('Save'))
                ],
              ),
              body: isLoading ? const Loader() : Padding(
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
                                    : community.banner
                                                .isEmpty || //if the banner file is not null then show new bannre file image if it is null
                                            community.banner ==
                                                Constants.bannerDefault
                                        ? const Center(
                                            child: Icon(
                                              Icons.camera_alt_outlined,
                                              size: 40,
                                            ),
                                          )
                                        : Image.network(community.banner),
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
                                        NetworkImage(community.avatar),
                                    radius: 32,
                                  ),
                          ),
                        )
                      ],
                    ),
                  )
                ]),
              ),
            ),
        error: (error, stackTrace) => ErrorText(error: error.toString()),
        loading: () => const Loader());
  }
}

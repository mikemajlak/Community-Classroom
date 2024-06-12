import 'dart:io';

import 'package:community_classroom/core/common/error_text.dart';
import 'package:community_classroom/core/common/loader.dart';
import 'package:community_classroom/core/utils.dart';
import 'package:community_classroom/features/community/controller/community_controller.dart';
import 'package:community_classroom/features/post/controlller/post_controller.dart';
import 'package:community_classroom/models/community_model.dart';
import 'package:community_classroom/theme/pallete.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddPostTypeScreen extends ConsumerStatefulWidget {
  final String type;
  const AddPostTypeScreen({super.key, required this.type});

  @override
  ConsumerState<AddPostTypeScreen> createState() => _AddPostTypeScreenState();
}

class _AddPostTypeScreenState extends ConsumerState<AddPostTypeScreen> {
  //title of the post controller
  final titleController = TextEditingController();

  //description controller
  final descriptionController = TextEditingController();

  //link controller
  final linkController = TextEditingController();

  //image that we want to post
  File? bannerFile;

  //List of all the community which is joined by current user global variable
  List<Community> communities = [];

  //selected community where the post will be added
  Community? selectedCommunity;

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

  //method to share the post
  void sharePost() {
    if (widget.type == 'image' &&
        titleController.text.isNotEmpty &&
        bannerFile != null) {
      ref.read(postControllerProvider.notifier).shareImagePost(
          context: context,
          title: titleController.text.trim(),
          file: bannerFile,
          selectedCommunity: selectedCommunity ?? communities[0]);
    } else if (widget.type == 'text' && titleController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareTextPost(
          context: context,
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          selectedCommunity: selectedCommunity ?? communities[0]);
    } else if (widget.type == 'link' &&
        titleController.text.isNotEmpty &&
        linkController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareLinkPost(
          context: context,
          title: titleController.text.trim(),
          link: linkController.text.trim(),
          selectedCommunity: selectedCommunity ?? communities[0]);
    } else {
      showSnackbar(context, 'Please enter all the fields');
    }
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
    linkController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //check the type of post that is choosen by the user
    final isTypeImage = widget.type == 'image';
    final isTypeText = widget.type == 'text';
    final isTypeLink = widget.type == 'link';
    final currentTheme = ref.watch(themeNotifierProvider);
    final isLoading = ref.watch(postControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Post ${widget.type}'),
        actions: [
          TextButton(onPressed: sharePost, child: const Text('Share')),
        ],
      ),
      body: isLoading ? const Loader() : Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                filled: true,
                hintText: 'Enter Title here',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(18),
              ),
              maxLength: 30,
            ),
            const SizedBox(
              height: 10,
            ),
            if (isTypeImage)
              GestureDetector(
                onTap: selectBannerImage,
                child: DottedBorder(
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(10),
                    dashPattern: const [10, 4],
                    strokeCap: StrokeCap.round,
                    color: currentTheme.textTheme.bodyText2!.color!,
                    child: Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10)),
                      child: (bannerFile != null)
                          ? Image.file(bannerFile!)
                          : const Center(
                              child: Icon(
                                Icons.camera_alt_outlined,
                                size: 40,
                              ),
                            ),
                    )),
              ),
            if (isTypeText) //if the post is of type text then this is for description
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  filled: true,
                  hintText: 'Enter Description here',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(18),
                ),
                maxLines: 6,
              ),
            if (isTypeLink)
              TextField(
                controller: linkController,
                decoration: const InputDecoration(
                  filled: true,
                  hintText: 'Enter Link here',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(18),
                ),
              ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.topLeft,
              child: Text('Select Community'),
            ),
            ref.watch(userCommunitiesProvider).when(
                data: (data) {
                  communities = data;

                  if (data.isEmpty) {
                    return const SizedBox();
                  }
                  return DropdownButton(
                      value: selectedCommunity ??
                          data[
                              0], //if the there is no selected community then show top community in the list
                      items: data //this needs a list
                          .map((e) =>
                              DropdownMenuItem(value: e, child: Text(e.name)))
                          .toList(),
                      onChanged: (val) {
                        //when the new community is choosen(val)
                        setState(() {
                          selectedCommunity =
                              val; //change the global variable selected community
                        });
                      });
                },
                error: (error, stackTrace) =>
                    ErrorText(error: error.toString()),
                loading: () => const Loader())
          ],
        ),
      ),
    );
  }
}

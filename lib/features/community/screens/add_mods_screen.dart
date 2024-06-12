import 'package:community_classroom/core/common/error_text.dart';
import 'package:community_classroom/core/common/loader.dart';
import 'package:community_classroom/features/auth/controller/auth_controller.dart';
import 'package:community_classroom/features/community/controller/community_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//creating consumer stateful widget because we are using checkbox to select or deselect the moderator in the community which require state to rebuild the widget when the user checks the box

class AddModsScreen extends ConsumerStatefulWidget {
  final String name; //name of the community required
  const AddModsScreen({super.key, required this.name});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddModsScreenState();
}

class _AddModsScreenState extends ConsumerState<AddModsScreen> {
  //set of uids for showing the members that are moderators
  Set<String> uids = {}; //set of moderators
  //counter to not refill the set again when setstate runs rebuild the build
  int cnt = 0;

  //method to add the uid in the set of moderators
  void addUid(String uid) {
    setState(() {
      uids.add(uid);
    });
  }

  //method to remove the uid in the set of moderators
  void removeUid(String uid) {
    setState(() {
      uids.remove(uid);
    });
  }

  //method to save mods in database
  void saveMods() {
    ref
        .read(communityControllerProvider.notifier)
        .addMods(widget.name, uids.toList(), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(onPressed: () => saveMods(), icon: const Icon(Icons.done)),
      ]),
      body: ref.watch(getCommunityByNameProvider(widget.name)).when(
          data: (community) {
            return ListView.builder(
              itemCount: community.members.length,
              itemBuilder: (context, index) {
                final member = community.members[index];
                return ref.watch(getUserDataProvider(member)).when(
                    data: (user) {
                      if (community.mods.contains(user.uid) && cnt == 0) {
                        uids.add(user.uid);
                      }
                      cnt++;
                      return CheckboxListTile(
                        value: uids.contains(user.uid),
                        onChanged: (val) {
                          if (val!) {
                            uids.add(user.uid);
                          } else {
                            uids.remove(user.uid);
                          }
                        },
                        title: Text(user.name),
                      );
                    },
                    error: (error, stackTrace) =>
                        ErrorText(error: error.toString()),
                    loading: () => const Loader());
              },
            );
          },
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader()),
    );
  }
}

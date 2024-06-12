import 'package:community_classroom/core/common/loader.dart';
import 'package:community_classroom/features/community/controller/community_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateCommunityScreen extends ConsumerStatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends ConsumerState<CreateCommunityScreen> {
  final communityNameController = TextEditingController();

  //to dispose the text that previously used when we close(dispose) the page or widget
  @override
  void dispose() {
    super.dispose();
    communityNameController.dispose();
  }

  //method to create the community
  void createCommunity() {
    ref
        .read(communityControllerProvider.notifier)
        .createCommunity(communityNameController.text.trim(), context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Create a community'),
        ),
        body: isLoading ? const Loader() : Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const Align(
                  alignment: Alignment.topLeft, child: Text('Community name')),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: communityNameController,
                decoration: const InputDecoration(
                    hintText: 'r/community_name',
                    filled: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(18)),
                maxLength: 21,
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                onPressed: () => createCommunity(),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                child: const Text(
                  'Create community',
                  style: TextStyle(fontSize: 17),
                ),
              )
            ],
          ),
        ));
  }
}

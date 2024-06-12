import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

//method to show the snackbar
void showSnackbar(BuildContext context, String T) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(T),
    ));
}

//method to get the image from the device using file_picker dependency
Future<FilePickerResult?> pickImage() async{
  final image = await FilePicker.platform.pickFiles();
  return image;
}

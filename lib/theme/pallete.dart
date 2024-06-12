import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Provider for the theme
final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});

//pallete class
class Pallete {
  // Colors
  static const blackColor = Color.fromRGBO(1, 1, 1, 1); // primary color
  static const greyColor = Color.fromRGBO(26, 39, 45, 1); // secondary color
  static const drawerColor = Color.fromRGBO(18, 18, 18, 1);
  static const whiteColor = Colors.white;
  static var redColor = Colors.red.shade500;
  static var blueColor = Colors.blue.shade300;

  // Themes
  static var darkModeAppTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: blackColor,
    cardColor: greyColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: drawerColor,
      iconTheme: IconThemeData(
        color: whiteColor,
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: drawerColor,
    ),
    primaryColor: redColor,
    backgroundColor:
        drawerColor, // will be used as alternative background color
  );

  static var lightModeAppTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: whiteColor,
    cardColor: greyColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: whiteColor,
      elevation: 0,
      iconTheme: IconThemeData(
        color: blackColor,
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: whiteColor,
    ),
    primaryColor: redColor,
    backgroundColor: whiteColor,
  );
}

//using shared preference we can store the prefrence of theme in local database and when we close the app it shows our prefered theme and when we toggle we save to local database
class ThemeNotifier extends StateNotifier<ThemeData> {
  //state of this class is themedata
  ThemeMode _mode; //enum
  //constructor by default theme is dark
  ThemeNotifier({ThemeMode mode = ThemeMode.dark})
      : _mode = mode,
        super(Pallete.darkModeAppTheme) {
    getTheme(); //whenever the constructor run we get the theme
  }

  //getter to get the mode
  ThemeMode get mode => _mode;

  //method to get the theme local database
  void getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final theme = prefs.get('theme'); //get the theme frome local database

    //if the theme is light then state is light theme and mode is light also
    if (theme == 'light') {
      _mode = ThemeMode.light;
      state = Pallete.lightModeAppTheme;
    } else {
      _mode = ThemeMode.dark;
      state = Pallete.darkModeAppTheme;
    }
  }

  //method to toggle the theme when toggle switches then change the theme
  void toggleTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //if the current mode is dark change to light and chage the preferecne as well
    if (_mode == ThemeMode.dark) {
      _mode = ThemeMode.light; //change mode
      state = Pallete.lightModeAppTheme; //change the state
      prefs.setString('theme',
          'light'); //change the preference and store in local database for further usage
    } else {
      //same with light mode as well
      _mode = ThemeMode.dark;
      state = Pallete.darkModeAppTheme;
      prefs.setString('theme', 'dark');
    }
  }
}

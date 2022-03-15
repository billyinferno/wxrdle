import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wxrdle/home.dart';

import 'globals/colors.dart';

void main() {
  // this is needed to ensure that all the binding already initialized before
  // we plan to load the shared preferences.
  WidgetsFlutterBinding.ensureInitialized();

  // initialize flutter application
  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]), // set prefered orientation
  ]).then((_) {
    // if all the future success means application is initialized
    debugPrint("💯 Application Initialized");
  }).onError((error, stackTrace) {
    // if caught error print all the error and the stack trace
    debugPrint(error.toString());
    debugPrint(stackTrace.toString());
  }).whenComplete(() {
    // run the application whatever happen with the future
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wxrdle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: '--apple-system',
        brightness: Brightness.dark,
        backgroundColor: primaryBackground,
        scaffoldBackgroundColor: primaryBackground,
        primaryColor: textColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryBackground
        ),
      ),
      home: const HomePage(),
    );
  }
}

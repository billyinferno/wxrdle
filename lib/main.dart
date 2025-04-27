import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:wxrdle/home.dart';
import 'package:wxrdle/storage/local_box.dart';
import 'globals/colors.dart';

void main() {
  // this is needed to ensure that all the binding already initialized before
  // we plan to load the shared preferences.
  WidgetsFlutterBinding.ensureInitialized();

  // initialize flutter application
  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]), // set prefered orientation
    Hive.initFlutter(),
    LocalBox.init(),
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
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wxrdle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: '--apple-system',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: primaryBackground,
        primaryColor: textColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryBackground
        ),
        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: primaryBackground,
          onPrimary: textColor,
          secondary: primaryBackground,
          onSecondary: textColor,
          error: Colors.red[900]!,
          onError: textColor,
          surface: primaryBackground,
          onSurface: textColor,
        ),
      ),
      home: const HomePage(),
    );
  }
}

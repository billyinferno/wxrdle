import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:wxrdle/globals/colors.dart';
import 'package:wxrdle/home.dart';
import 'package:wxrdle/storage/local_box.dart';

void main() {
  // this is needed to ensure that all the binding already initialized before
  // we plan to load the shared preferences.
  WidgetsFlutterBinding.ensureInitialized();

  // initialize flutter application
  Future.microtask(() async {
    // load the env
    await dotenv.load(fileName: 'env/.prod.env');
  }).then((value) async {
    debugPrint("🔐 Env Loaded");

    // load all necessary configuration needed    
    Future.wait([
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]), // set prefered orientation
      Hive.initFlutter(),
      LocalBox.init(),
    ]).then((_) {
      // if all the future success means application is initialized
      debugPrint("💯 Application Initialized");
    }).onError((error, stackTrace) {
      // if caught error print all the error and the stack trace
      debugPrint("❌ Error during application init");
      debugPrint("Error: ${error.toString()}");
      debugPrint(stackTrace.toString());
    }).whenComplete(() {
      // run the application whatever happen with the future
      runApp(const MyApp());
    });
  },).onError((error, stackTrace) {
    debugPrint("❌ Error when loading .env");
    debugPrint("Error: ${error.toString()}");
    debugPrintStack(stackTrace: stackTrace);
  },);
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

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hoohacks/authentication_page.dart';
import 'package:hoohacks/constant.dart';
import 'package:hoohacks/firebase_options.dart';
import 'package:hoohacks/home_page.dart';
import 'package:hoohacks/states/activity_state.dart';
import 'package:hoohacks/states/organization_state.dart';
import 'package:hoohacks/states/theme_state.dart';
import 'package:hoohacks/states/user_state.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final UserState userState = UserState();
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ActivityState()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => OrganizationState()),
        ChangeNotifierProvider(create: (context) => userState),
      ],
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Consumer<ThemeProvider>(
          builder: (context, ThemeProvider themeProvider, child) {
            return MaterialApp(
              title: 'Flutter Demo',
              themeMode: themeProvider.themeMode,
              theme: ThemeData(
                appBarTheme: const AppBarTheme(backgroundColor: ctaColor),
                colorScheme: ColorScheme(
                  brightness: Brightness.light,
                  primary: ctaColor,
                  onPrimary: Colors.black,
                  secondary: ctaColor,
                  onSecondary: Colors.black,
                  error: Colors.red,
                  onError: Colors.red,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
              ),
              darkTheme: ThemeData.dark().copyWith(
                appBarTheme: const AppBarTheme(backgroundColor: ctaColor),
                colorScheme: ColorScheme(
                  brightness: Brightness.dark,
                  primary: ctaColor,
                  onPrimary: Colors.black,
                  secondary: ctaColor,
                  onSecondary: Colors.black,
                  error: Colors.red,
                  onError: Colors.red,
                  surface: Colors.black,
                  onSurface: Colors.white,
                ),
              ),
              home:
                  FirebaseAuth.instance.currentUser == null
                      ? const AuthenticationPage()
                      : const HomePage(),
            );
          },
        ),
      ),
    );
  }
}

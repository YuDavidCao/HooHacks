import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hoohacks/authentication_page.dart';
import 'package:hoohacks/firebase_options.dart';
import 'package:hoohacks/home_page.dart';
import 'package:hoohacks/states/activity_state.dart';
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
        ChangeNotifierProvider(create: (context) => userState),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 255, 64, 0),
          ),
        ),
        home:
            FirebaseAuth.instance.currentUser == null
                ? const AuthenticationPage()
                : const HomePage(),
      ),
    );
  }
}

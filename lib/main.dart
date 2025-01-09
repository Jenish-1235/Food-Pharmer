import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'auth_widget.dart';
import 'home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // Uses a StreamBuilder to listen to auth state changes.
  // If the user is signed in, show HomePageWidget; otherwise, show AuthWidget.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Pharmer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // While checking the auth state, show a loader
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // If user is signed in, show HomePageWidget
          if (snapshot.hasData) {
            return const HomePageWidget();
          }

          // If not signed in, show AuthWidget
          return const AuthWidget();
        },
      ),
    );
  }
}

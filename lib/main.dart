import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tut_mynotes/constants/routes.dart';

import 'package:flutter_tut_mynotes/firebase_options.dart';
import 'package:flutter_tut_mynotes/views/login_view.dart';
import 'package:flutter_tut_mynotes/views/notes_view.dart';
import 'package:flutter_tut_mynotes/views/register_view.dart';
import 'package:flutter_tut_mynotes/views/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: const HomePage(),
    routes: {
      loginRoute: (context) => const LoginView(),
      registerRoute: (context) => const RegisterView(),
      notesRoute: (context) => const NotesView()
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          // case ConnectionState.none:
          //   break;
          // case ConnectionState.waiting:
          //   break;
          // case ConnectionState.active:
          // break;
          case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;

            if (user != null) {
              if (user.emailVerified) {
                return const NotesView();
              } else {                
                // * after verification the user needs to be relogged in
                // * for the data to be reloaded
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }
            
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}

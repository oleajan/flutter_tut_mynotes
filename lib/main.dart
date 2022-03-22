import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tut_mynotes/firebase_options.dart';
import 'package:flutter_tut_mynotes/views/login_view.dart';
import 'package:flutter_tut_mynotes/views/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: const HomePage(),
    )
  );
}

class HomePage extends StatelessWidget {
  const HomePage({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform
        ),
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

              // return const LoginView();

              // * after verification the user needs to be relogged in
              // * for the data to be reloaded
              if (user?.emailVerified ?? false) {
              } else {
                return const VerifyEmailView();
              }

              return const Text('DONE');
            default: 
              return const Text('Loading');
          }
        },
      ),
    );
  }
}
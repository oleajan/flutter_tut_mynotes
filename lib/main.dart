import 'package:flutter/material.dart';
import 'package:flutter_tut_mynotes/constants/routes.dart';

import 'package:flutter_tut_mynotes/services/auth/auth_service.dart';
import 'package:flutter_tut_mynotes/views/login_view.dart';
import 'package:flutter_tut_mynotes/views/notes/create_update_note_view.dart';
import 'package:flutter_tut_mynotes/views/notes/notes_view.dart';
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
      notesRoute: (context) => const NotesView(),
      createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      verifyEmailRoute: (context) => const VerifyEmailView(), 
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;

            if (user != null) {
              if (user.isEmailVerified) {
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

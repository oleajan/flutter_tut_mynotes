import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../firebase_options.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: FutureBuilder(
          future: Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {

              // case ConnectionState.none:
              //   break;
              // case ConnectionState.waiting:
              //   break;
              // case ConnectionState.active:
              //   break;

              case ConnectionState.done:
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _email,
                          decoration: const InputDecoration(
                              hintText: 'Enter your email here'),
                          autocorrect: false,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        TextField(
                          controller: _password,
                          decoration: const InputDecoration(
                              hintText: 'Enter your password here'),
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                        ),
                        TextButton(
                          onPressed: () async {
                            final email = _email.text;
                            final password = _password.text;

                            // final userCred;
                            try {
                              final userCred = await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(email: email, password: password);

                              print(userCred);
                            } on FirebaseAuthException catch (e) {
                              switch (e.code) {
                                case 'user-not-found':
                                  print("USER NOT FOUND.");
                                  break;
                                case 'wrong-password':
                                  print("WRONG PASSWORD");
                                  break;
                                default: print("Oops.. Something went wrong: \n$e.code"); break;
                              }
                            }
                          },
                          child: const Text('Login'),
                        ),
                      ],
                    ),
                  ),
                );

              default:
                return const Text('LOADING...');
            }
          }),
    );
  }
}

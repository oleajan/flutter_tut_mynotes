import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tut_mynotes/constants/routes.dart';
import 'dart:developer' as devtools show log;

import '../utilities/show_error_dialog.dart';
class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
      appBar: AppBar(title: const Text('Register'),),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              TextField(
                controller: _email,
                decoration:
                    const InputDecoration(hintText: 'Enter your email here'),
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _password,
                decoration:
                    const InputDecoration(hintText: 'Enter your password here'),
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
              ),
              TextButton(
                onPressed: () async {
                  final email = _email.text;
                  final password = _password.text;
    
                  try {
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: email, password: password);

                    
                  } on FirebaseAuthException catch (e) {
                    switch (e.code) {
                      case 'weak-password':
                        await showErrorDialog(context, 'Weak Password');
                        devtools.log('weak password');
                        break;
                      case 'email-already-in-use':
                        await showErrorDialog(context, 'Email is already in use');
                        devtools.log('email already in use');
                        break;
                      case 'invalid-email':
                        await showErrorDialog(context, 'Invalid Email');
                        devtools.log('invalid email');
                        break;
                      default:
                        await showErrorDialog(context, 'Error: ${e.code}');
                        devtools.log("Error: ${e.code}");
                        break;
                    }
                  } catch (e) {
                    devtools.log(e.toString());
                  }

                },
                child: const Text('Register'),
              ),
              TextButton(onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
              },
              child: const Text('Already registered? Login here!'))
            ],
          ),
        ),
      ),
    );
  }
}

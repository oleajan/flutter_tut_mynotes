import 'package:flutter/material.dart';

import 'dart:developer' as devtools show log;

import 'package:flutter_tut_mynotes/constants/routes.dart';
import 'package:flutter_tut_mynotes/services/auth/auth_exceptions.dart';
import 'package:flutter_tut_mynotes/services/auth/auth_service.dart';

import '../utilities/show_error_dialog.dart';

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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
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
                    final userCred = await AuthService.firebase().logIn(
                      email: email,
                      password: password,
                    );

                    devtools.log(userCred.toString());

                    final user = AuthService.firebase().currentUser;

                    if (user?.isEmailVerified ?? false) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        notesRoute,
                        (route) => false,
                      );
                    } else {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        verifyEmailRoute,
                        (route) => false,
                      );
                    }
                  } on UserNotFoundAuthException {
                    await showErrorDialog(context, 'User not found');
                    devtools.log("USER NOT FOUND.");
                  } on WrongPasswordAuthException {
                    await showErrorDialog(context, 'Wrong password');
                    devtools.log("WRONG PASSWORD");
                  } on GenericAuthException {
                    await showErrorDialog(context, 'Authentication Error!');
                    devtools.log("authentication error");
                  }
                },
                child: const Text('Login'),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        registerRoute, (route) => false);
                  },
                  child: const Text('Not registered yet? Register Here!'))
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_tut_mynotes/constants/routes.dart';
import 'package:flutter_tut_mynotes/services/auth/auth_exceptions.dart';
import 'package:flutter_tut_mynotes/services/auth/auth_service.dart';
import 'dart:developer' as devtools show log;

import '../utilities/dialogs/error_dialog.dart';

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
      appBar: AppBar(
        title: const Text('Register'),
      ),
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
                    await AuthService.firebase().createUser(
                      email: email,
                      password: password,
                    );

                    await AuthService.firebase().sendEmailVerification();

                    Navigator.pushNamed(context, verifyEmailRoute);
                  } on WeakPasswordAuthException {
                    await showErrorDialog(context, 'Weak Password');
                    devtools.log('weak password');
                  } on EmailAlreadyInUserAuthException {
                    await showErrorDialog(context, 'Email is already in use');
                    devtools.log('email already in use');
                  } on InvalidEmailAuthException {
                    await showErrorDialog(context, 'Invalid Email');
                    devtools.log('invalid email');
                  } on GenericAuthException {
                    await showErrorDialog(context, 'Failed to register');
                    devtools.log("registration error");
                  }
                },
                child: const Text('Register'),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(loginRoute, (route) => false);
                  },
                  child: const Text('Already registered? Login here!'))
            ],
          ),
        ),
      ),
    );
  }
}

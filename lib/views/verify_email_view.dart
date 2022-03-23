import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tut_mynotes/constants/routes.dart';
import 'package:flutter_tut_mynotes/views/login_view.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Scaffold(
        appBar: AppBar(title: const Text('Verify E-Mail')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                const Text('We have already sent an email verification to your account.'),
                const Text("If you haven't received a verfication email yet, please press the button below."),
                TextButton(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    await user?.sendEmailVerification();
                  },
                  child: const Text('Send email verification'),
                ),
                TextButton(
                  onPressed: () async{
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushNamedAndRemoveUntil(context, registerRoute, (route) => false);
                  },
                  child: const Text('Restart'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

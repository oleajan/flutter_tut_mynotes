import 'package:flutter/material.dart';
import 'package:flutter_tut_mynotes/constants/routes.dart';
import 'package:flutter_tut_mynotes/services/auth/auth_service.dart';

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
                    AuthService.firebase().currentUser;
                    await AuthService.firebase().sendEmailVerification();
                  },
                  child: const Text('Send email verification'),
                ),
                TextButton(
                  onPressed: () async{
                    await AuthService.firebase().logOut();
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

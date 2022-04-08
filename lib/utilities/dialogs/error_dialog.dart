import 'package:flutter/material.dart';
import 'package:flutter_tut_mynotes/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog<void>(
    context: context,
    title: 'An error has occured',
    content: text,
    optionsBuilder: () => {
      'Ok': null,
    },
  );
}

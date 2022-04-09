import 'package:flutter/material.dart';
import 'package:flutter_tut_mynotes/utilities/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyNotesDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Sharing',
    content: 'You cannot share an empty note!',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}

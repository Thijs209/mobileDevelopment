import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<dynamic> ShowAlertDialog(
    BuildContext context, {
      required String title,
      required String content,
      required String defaultActionText,
    }) {
  return showDialog(
    context: context,
    builder: (context) =>
        AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text(defaultActionText),
              onPressed: () => Navigator.of(context).pop(true),
            )
          ],
        ),
  );
}
import 'package:flutter/material.dart';

void showAlertDialog(BuildContext context, String message) {
  // set up the AlertDialog
  showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text(
        'Error',
        style: TextStyle(color: Colors.black),
      ),
      content: Text(
        message,
        style: TextStyle(color: Colors.black),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'OK'),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

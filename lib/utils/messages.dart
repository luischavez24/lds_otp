import 'package:flutter/material.dart';

showErrorMessage(BuildContext context, String message) {
  final snackBar = SnackBar(
      backgroundColor: Colors.redAccent,
      content: Text(message)
  );
  Scaffold.of(context).showSnackBar(snackBar);
}
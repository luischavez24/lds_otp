import 'package:flutter/material.dart';
import 'package:lds_otp/utils/theme.dart';
enum MessageType {
  INFO,
  SUCCESS,
  ERROR,
  WARNING
}

const _messageTypesColors = <MessageType, Color> {
  MessageType.INFO : Colors.black,
  MessageType.SUCCESS: AppColors.primaryColor,
  MessageType.ERROR: Colors.redAccent,
  MessageType.WARNING: AppColors.accentColor
};

showMessage(BuildContext context, String message,  { MessageType type }){
  final snackBar = SnackBar(
      backgroundColor: _messageTypesColors[type ?? MessageType.INFO],
      content: Text(message)
  );
  Scaffold.of(context).showSnackBar(snackBar);
}
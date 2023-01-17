// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String getFormattedDateTime(num dt, String pattern) {
  return DateFormat(pattern)
      .format(DateTime.fromMillisecondsSinceEpoch(dt.toInt() * 1000));
}

void showMsg(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

void showMsgWithAction(
    {required BuildContext context,
    required String msg,
    required VoidCallback callback}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: Duration(days: 365),
      content: Text(msg),
      action: SnackBarAction(
        label: 'Go to settings',
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          callback();
        }
      ),
    ),
  );
}

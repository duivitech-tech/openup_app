// lib/widgets/app_toast.dart

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppToast {
  AppToast._();

  static void error(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color(0xFF6B1F1F),
      textColor: const Color(0xFFF0EEF4),
      fontSize: 13.0,
    );
  }

  static void success(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color(0xFF1E7A47),
      textColor: const Color(0xFFF0EEF4),
      fontSize: 13.0,
    );
  }

  static void info(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color(0xFF2A2A32),
      textColor: const Color(0xFFF0EEF4),
      fontSize: 13.0,
    );
  }
}

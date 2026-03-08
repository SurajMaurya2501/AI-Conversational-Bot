import 'package:firebase_gemini_ai/controller/shared_preferences.dart';
import 'package:firebase_gemini_ai/view/chat_screen.dart';
import 'package:firebase_gemini_ai/view/login.dart';
import 'package:firebase_gemini_ai/view/signup.dart';
import 'package:flutter/material.dart';

class SplashController {
  final sharedPred = SharedPref();

  void verifyUser(BuildContext context) async {
    String email = await sharedPred.getData("email");
    if (email.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ChatScreen(),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    }
  }
}

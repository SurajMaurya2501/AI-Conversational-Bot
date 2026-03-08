import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_gemini_ai/controller/shared_preferences.dart';
import 'package:firebase_gemini_ai/view/chat_screen.dart';
import 'package:firebase_gemini_ai/view/signup.dart';
import 'package:flutter/material.dart';

class SignUpController {
  final _auth = FirebaseAuth.instance;
  final sharedPref = SharedPref();

  Future<void> signupWithEmail(String email, String password,
      BuildContext context, String userName) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      userCredential.user!.updateDisplayName(userName);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SignUpAndLoginScreen(
            isLoginPage: true,
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.toString() ==
          '[firebase_auth/email-already-in-use] The email address is already in use by another account.') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Email Already in Use",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      print("Error Occured While Sign up With Email:$e");
    }
  }

  Future<void> loginWithEmail(
      String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (userCredential.user != null) {
        sharedPref.storeData("email", email);
        sharedPref.storeData("userName", userCredential.user!.displayName!);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ChatScreen()));

        print("Login Successfully!");
      }
    } catch (e) {
      if (e.toString() ==
          '[firebase_auth/invalid-credential] The supplied auth credential is incorrect, malformed or has expired.') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Email or Password is Incorrect",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }

      print("Error Occured while login with email:$e");
    }
  }
}

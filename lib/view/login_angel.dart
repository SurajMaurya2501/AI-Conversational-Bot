import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_gemini_ai/view/chat_screen.dart';
import 'package:flutter/material.dart';

class AngelLogin extends StatefulWidget {
  const AngelLogin({super.key});

  @override
  State<AngelLogin> createState() => _AngelLoginState();
}

class _AngelLoginState extends State<AngelLogin> {
  final _controller = TextEditingController();
  final smsController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? verificationId;
  bool _codeSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 26, 25, 25),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 26, 25, 25),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 10.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Login",
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
              ),
            ),
            const Text(
              "Enter Mobile Number to continue",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 40.0,
              ),
              child: const Text(
                "Mobile Number",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextField(
              style: const TextStyle(
                color: Colors.white,
              ),
              controller: _controller,
              decoration: InputDecoration(
                prefix: Container(
                  margin: const EdgeInsets.only(right: 15.0),
                  child: const Text(
                    "+91",
                  ),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 3,
                    color: Color.fromARGB(
                      255,
                      72,
                      87,
                      248,
                    ),
                  ),
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 3,
                    color: Color.fromARGB(
                      255,
                      72,
                      87,
                      248,
                    ),
                  ),
                ),
              ),
            ),
            if (_codeSent) // If OTP is sent, show OTP field
              TextField(
                controller: smsController,
                decoration: const InputDecoration(
                  labelText: 'OTP',
                ),
                keyboardType: TextInputType.number,
              ),
            const Spacer(),
            InkWell(
              onTap: _codeSent ? signInWithOtp : _verifyPhone,
              child: Container(
                margin: const EdgeInsets.only(
                  bottom: 20.0,
                ),
                alignment: Alignment.center,
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    5.0,
                  ),
                  color: const Color.fromARGB(
                    255,
                    72,
                    87,
                    248,
                  ),
                ),
                child: Text(
                  _codeSent ? "Verify OTP" : "Send OTP",
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verifyPhone() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: _controller.text.trim(),
      verificationCompleted: (phoneAuthCredential) async {
        await _auth.signInWithCredential(phoneAuthCredential);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChatScreen(),
          ),
        );
      },
      verificationFailed: (error) {
        print("Verification failed: ${error.message}");
      },
      codeSent: (verificationId, forceResendingToken) {
        setState(() {
          verificationId = verificationId;
          _codeSent = true; // OTP has been sent
        });
      },
      codeAutoRetrievalTimeout: (verificationId) {
        setState(() {
          verificationId = verificationId;
        });
      },
    );
    print("Sign In Successfull");
  }

  Future<void> signInWithOtp() async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId!, smsCode: smsController.text.trim());
      await _auth.signInWithCredential(credential);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ChatScreen(),
        ),
      );
      print("Sign In Successfull");
    } catch (e) {
      print("Error Occured While signinWithOtp : $e");
    }
  }
}

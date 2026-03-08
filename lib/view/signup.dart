import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_gemini_ai/controller/sign_up_controller.dart';
import 'package:firebase_gemini_ai/view/chat_screen.dart';
import 'package:flutter/material.dart';

class SignUpAndLoginScreen extends StatefulWidget {
  final bool isLoginPage;
  const SignUpAndLoginScreen({super.key, required this.isLoginPage});

  @override
  State<SignUpAndLoginScreen> createState() => _SignUpAndLoginScreenState();
}

class _SignUpAndLoginScreenState extends State<SignUpAndLoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final userController = TextEditingController();
  final signUpController = SignUpController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 26, 26, 26),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(top: 100, left: 10.0, right: 10.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AnimatedTextKit(
                  isRepeatingAnimation: false,
                  animatedTexts: [
                    TyperAnimatedText(
                      speed: const Duration(milliseconds: 200),
                      widget.isLoginPage ? "Welcome Back" : "Create An Account",
                      textStyle: const TextStyle(
                        fontSize: 35,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 50.0,
                ),
                if (!widget.isLoginPage)
                  Container(
                    margin: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Username';
                        }
                        return null;
                      },
                      controller: userController,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        errorStyle: const TextStyle(fontSize: 15),
                        suffixIcon: const Icon(Icons.person_2),
                        hintText: "Enter Username",
                        hintStyle: const TextStyle(color: Colors.white),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            5.0,
                          ),
                          borderSide: const BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              5.0,
                            ),
                            borderSide: const BorderSide(
                              color: Colors.white,
                            )),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            5.0,
                          ),
                          borderSide: const BorderSide(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                Container(
                  margin: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                    controller: emailController,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      errorStyle: const TextStyle(fontSize: 15),
                      suffixIcon: const Icon(Icons.email),
                      hintText: "Enter Email",
                      hintStyle: const TextStyle(color: Colors.white),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          5.0,
                        ),
                        borderSide: const BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            5.0,
                          ),
                          borderSide: const BorderSide(
                            color: Colors.white,
                          )),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          5.0,
                        ),
                        borderSide: const BorderSide(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                    controller: passwordController,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    obscureText: true,
                    decoration: InputDecoration(
                      suffixIcon: const Icon(
                        Icons.lock,
                      ),
                      hintStyle: const TextStyle(color: Colors.white),
                      hintText: "Enter Password",
                      errorStyle: const TextStyle(fontSize: 15),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          5.0,
                        ),
                        borderSide: const BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          5.0,
                        ),
                        borderSide: const BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          5.0,
                        ),
                        borderSide: const BorderSide(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                if (!widget.isLoginPage)
                  RichText(
                      text: TextSpan(children: [
                    const TextSpan(
                      text: "Already have an account?",
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    WidgetSpan(
                      child: Container(
                        margin: const EdgeInsets.only(left: 5.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SignUpAndLoginScreen(
                                    isLoginPage: true,
                                  ),
                                ));
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ),
                    ),
                  ])),
                if (widget.isLoginPage)
                  RichText(
                      text: TextSpan(children: [
                    const TextSpan(
                      text: "Don't have an account?",
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    WidgetSpan(
                      child: Container(
                        margin: const EdgeInsets.only(left: 5.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SignUpAndLoginScreen(
                                    isLoginPage: false,
                                  ),
                                ));
                          },
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ),
                    ),
                  ])),
                Container(
                  margin: const EdgeInsets.only(top: 10.0),
                  child: ElevatedButton(
                    onPressed: widget.isLoginPage == false
                        ? () {
                            if (_formKey.currentState!.validate()) {
                              signUpController.signupWithEmail(
                                  emailController.text.trim(),
                                  passwordController.text.trim(),
                                  context,
                                  userController.text.trim());
                            }
                          }
                        : () {
                            if (_formKey.currentState!.validate()) {
                              signUpController.loginWithEmail(
                                  emailController.text.trim(),
                                  passwordController.text.trim(),
                                  context);
                            }
                          },
                    child: Text(
                      widget.isLoginPage ? "Login" : "Create Account",
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      )),
    );
  }
}

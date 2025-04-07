
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talk_easy/screens/registerscreen.dart';
import 'homescreen.dart';

class LoginScreen extends StatefulWidget {
    const LoginScreen({super.key}); // ✅ Added const

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = "";

  void navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterScreen()),
    );
  }

  Future<void> _login() async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    log("User: ${userCredential.user}");
    log('User logged in');

    // ✅ Fetch the saved theme mode
    final prefs = await SharedPreferences.getInstance();
    final bool isDarkMode = prefs.getBool('isDarkMode') ?? false;

    // ✅ Pass `isDarkMode` when navigating
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          onThemeToggle: (bool isDark) async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isDarkMode', isDark);
          },
          isDarkMode: isDarkMode, // ✅ Fix: Pass the correct theme state
        ),
      ),
    );
  } on FirebaseAuthException catch (e) {
    setState(() {
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided.';
      } else {
        errorMessage = 'An error occurred. Please try again.';
      }
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF000428), Color(0xFF004E92)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 600,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(550),
                  bottomRight: Radius.circular(1),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/logo.jpg', height: 120),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildToggleButton("Log In", true, () {}),
                                _buildToggleButton("Sign Up", false, navigateToSignUp),
                              ],
                            ),
                          ),
                          SizedBox(height: 30),
                          TextField(
                            cursorColor: Colors.black87,
                            style: TextStyle(color: Colors.black),
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: "Email",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.email, color: Colors.indigo),
                            ),
                          ),
                          SizedBox(height: 30),
                          TextField(
                            style: TextStyle(color: Colors.black),
                            cursorColor: Colors.black87,
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "Password",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.password, color: Colors.indigo),
                            ),
                          ),
                          SizedBox(height: 20),
                          if (errorMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                errorMessage,
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF004E92),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                            ),
                            child: Text(
                              "Log In",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text("or", style: TextStyle(color: Colors.black54)),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: FaIcon(FontAwesomeIcons.google),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Color(0xFF004E92) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

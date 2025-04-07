import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  /// **✅ Function to Navigate to Login Screen**
  void navigateToLogin() {
    Navigator.pushNamed(context, "/login");
  }

  /// **✅ Function to Navigate to Signup Screen**
  void navigateToSignup() {
    Navigator.pushNamed(context, "/signup");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // **🔹 Background Gradient**
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF000428), Color(0xFF004E92)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // **🔹 Main Content (Buttons, Logo, Animation)**
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // **🔹 Logo**
              Image.asset('assets/logo-w.png', width: 250, height: 220),

              const SizedBox(height: 40),

              Text(
                "Welcome! Create Account",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 20),

              // **🔹 Sign Up Button**
              SizedBox(
                width: 250, // Adjust width
                height: 55, // Adjust height
                child: ElevatedButton(
                  onPressed: navigateToSignup,
                  style: elevatedButtonStyle,
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "Already User? Sign In",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 20),

              // **🔹 Login Button**
              SizedBox(
                width: 250, // Adjust width
                height: 55, // Adjust height
                child: ElevatedButton(
                  onPressed: navigateToLogin,
                  style: elevatedButtonStyle,
                  child: const Text(
                    "Login",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // **🔹 Lottie Animation**
              Lottie.asset(
                'assets/voice-command.json',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// **✅ Button Styling**
  ButtonStyle get elevatedButtonStyle {
    return ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: const Color(0xFF004E92),
      foregroundColor: Colors.white,
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:talk_easy/screens/homescreen.dart';
import 'package:talk_easy/screens/loginscreen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String selectedLanguage = "Hindi";
  String selectedGender = "Male"; // Default Gender
  int step = 1;

  /// **✅ Returns default profile picture based on gender**
  String _getDefaultProfilePic() {
    return selectedGender == "Male"
        ? "assets/male.jpg" // ✅ Default Male Image
        : "assets/female.jpg"; // ✅ Default Female Image
  }

  void nextStep() {
    if (step < 5) {
      setState(() => step++);
    }
  }

  void prevStep() {
    if (step > 1) {
      setState(() => step--);
    }
  }

  void navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Future<void> _register() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();
    String username = usernameController.text.trim();
    String profilePic = _getDefaultProfilePic(); // Get selected profile picture

    if (username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // ✅ Store user profile in Firestore with gender & default profile pic
        await FirebaseFirestore.instance.collection("users").doc(userCredential.user!.uid).set({
          "user_id": userCredential.user!.uid,
          "email": email,
          "name": username,
          "language": selectedLanguage,
          "gender": selectedGender,
          "profile_pic": profilePic,
          "bio": "",
        });

        print("✅ User profile created successfully!");

        // ✅ Navigate directly to HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(onThemeToggle: (_) {}, isDarkMode: false),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Registration failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
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
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(550),
                  bottomRight: Radius.circular(1),
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/logo.jpg', height: 100),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      children: [
                        _buildStepContent(),
                        const SizedBox(height: 20),

                        // ✅ Swapped Previous & Next Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: step > 1 ? prevStep : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF004E92),
                              ),
                              child: const Text(
                                "Previous",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: step == 5 ? _register : nextStep,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF004E92),
                              ),
                              child: Text(
                                step == 5 ? "Sign Up" : "Next",
                                style: const TextStyle(color: Colors.white),
                              ),
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
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (step) {
      case 1:
        return TextField(
          controller: usernameController,
          decoration: const InputDecoration(labelText: "Username", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
        );
      case 2:
        return TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
        );
      case 3:
        return Column(
          children: [
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Confirm Password", border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock_outline)),
            ),
          ],
        );
      case 4:
        return DropdownButtonFormField<String>(
          value: selectedLanguage,
          items: ["English", "Hindi", "Bengali", "Tamil", "Telugu"].map((lang) => DropdownMenuItem(value: lang, child: Text(lang))).toList(),
          onChanged: (value) => setState(() => selectedLanguage = value!),
          decoration: const InputDecoration(labelText: "Select Language"),
        );
      case 5:
        return Column(
          children: [
            const Text("Select Gender"),
            Row(
              children: [
                Expanded(child: RadioListTile(value: "Male", groupValue: selectedGender, title: const Text("Male"), onChanged: (value) => setState(() => selectedGender = value.toString()))),
                Expanded(child: RadioListTile(value: "Female", groupValue: selectedGender, title: const Text("Female"), onChanged: (value) => setState(() => selectedGender = value.toString()))),
              ],
            ),
            const SizedBox(height: 20),
            Image.asset(_getDefaultProfilePic(), height: 100), // ✅ Live Profile Picture Update
          ],
        );
      default:
        return const Text("Invalid Selection", style: TextStyle(color: Colors.red));
    }
  }
}

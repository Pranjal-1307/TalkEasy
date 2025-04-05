import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About Us"),
        backgroundColor: Colors.blue[900], // Dark Blue AppBar
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration( // ✅ Removed `const`
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.white], // ✅ Fixed gradient colors
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Image.asset("assets/logo.jpg", height: 100)), // Add your logo
              const SizedBox(height: 20),
              const Text(
                "Welcome to TalkEasy!",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 2),
                  ],
                ),
                child: const Text(
                  "TalkEasy is a revolutionary communication app that helps you connect with the world effortlessly. Our mission is to create a seamless experience for users worldwide.",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.justify,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "🔹 Why Choose Us?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),
              _buildBulletPoint(" Fast & Secure Communication"),
              _buildBulletPoint(" User-friendly Interface"),
              _buildBulletPoint(" Global Accessibility"),
              _buildBulletPoint(" Reliable Performance"),
              const Spacer(),
              Center(
                child: Text(
                  "Version 1.0.0",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 16, color: Colors.white)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help & Support"),
        backgroundColor: Colors.blue[900], // Dark Blue AppBar
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.white], // Dark Blue → White Gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "How can we help you?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),

              // FAQ Section
              _buildFaqTile("How do I reset my password?", "Go to settings > account > reset password."),
              _buildFaqTile("How do I update my profile?", "Navigate to the profile page and click edit."),
              _buildFaqTile("Is TalkEasy free to use?", "Yes, TalkEasy is completely free for all users."),

              const SizedBox(height: 20),

              // Contact Support Section
              const Text("Contact Us", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              _buildContactTile(Icons.email, "Email", "support@talkeasy.com"),
              _buildContactTile(Icons.phone, "Phone", "+1 234 567 890"),
              _buildContactTile(Icons.location_on, "Address", "123 TalkEasy Street, NY, USA"),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqTile(String question, String answer) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: const Icon(Icons.question_answer, color: Colors.blue),
        title: Text(question, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(answer, style: const TextStyle(fontSize: 14, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(IconData icon, String title, String detail) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue[900]),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Text(detail, style: const TextStyle(fontSize: 14, color: Colors.black87)),
      ),
    );
  }
}

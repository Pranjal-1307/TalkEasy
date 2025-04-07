import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:talk_easy/screens/Help_Support.dart';
import 'package:talk_easy/screens/loginscreen.dart';
import 'profilescreen.dart';
import 'aboutus_screen.dart';
import '../main.dart'; // Import theme provider

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSettingsTile(Icons.person, "Profile", () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
            }),
            _buildSettingsTile(Icons.info, "About Us", () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AboutUsScreen()));
            }),
            _buildSettingsTile(Icons.help, "Help & Support", () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => HelpSupportScreen()));
            }),
            _buildThemeToggle(themeProvider),
            _buildSettingsTile(Icons.logout, "Logout", () => _logout(context), isRed: true),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggle(ThemeProvider themeProvider) {
  bool isDarkMode = themeProvider.isDarkMode;

  return Card(
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: SwitchListTile(
      title: Text(
        isDarkMode ? "Dark Mode" : "Light Mode",  // 🔥 Dynamic text change
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      secondary: Icon(
        isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,  // 🔥 Sun 🌞 for light mode, Moon 🌙 for dark mode
        color: isDarkMode ? Colors.blue : Colors.orange,
      ),
      value: isDarkMode,
      onChanged: (bool value) {
        themeProvider.toggleTheme(value);
      },
    ),
  );
}

  Widget _buildSettingsTile(IconData icon, String title, VoidCallback? onTap, {bool isRed = false}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: isRed ? Colors.red : Colors.blue),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }
}

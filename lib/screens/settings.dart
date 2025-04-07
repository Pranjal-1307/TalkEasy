//TOGGLER MODE

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


//UI
/*
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:talk_easy/screens/Help_Support.dart';
import 'package:talk_easy/screens/loginscreen.dart';
import 'profilescreen.dart';
import 'aboutus_screen.dart';
import '../main.dart'; // ThemeProvider location

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
    final isDarkMode = themeProvider.isDarkMode;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF000428), Color(0xFF004E92)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              "Settings",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _glassTile(
                    icon: Icons.person,
                    text: "Profile",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProfileScreen()),
                    ),
                  ),
                  _glassTile(
                    icon: Icons.info,
                    text: "About Us",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AboutUsScreen()),
                    ),
                  ),
                  _glassTile(
                    icon: Icons.help_outline,
                    text: "Help & Support",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => HelpSupportScreen()),
                    ),
                  ),
                  _themeToggle(isDarkMode, themeProvider),
                  _glassTile(
                    icon: Icons.logout,
                    text: "Logout",
                    iconColor: Colors.redAccent,
                    onTap: () => _logout(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glassTile({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color iconColor = Colors.cyanAccent,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _themeToggle(bool isDarkMode, ThemeProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(
            isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
            color: isDarkMode ? Colors.blueAccent : Colors.orangeAccent,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              isDarkMode ? "Dark Mode" : "Light Mode",
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Switch(
            value: isDarkMode,
            activeColor: Colors.cyanAccent,
            onChanged: provider.toggleTheme,
          ),
        ],
      ),
    );
  }
}
*/
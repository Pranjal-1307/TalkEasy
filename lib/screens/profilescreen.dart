//Normal
/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  String? _userId;
  String? _selectedGender = "Male"; // Default gender
  String? _profilePic = "assets/male.jpg"; // Default profile picture
  String _selectedLanguage = "Not Set"; // Default language

  /// **Supported Languages**
  final Map<String, String> _languageMap = {
    "English": "en",
    "Hindi": "hi",
    "Bengali": "bn",
    "Tamil": "ta",
    "Telugu": "te",
    "Marathi": "mr",
    "Gujarati": "gu",
    "Kannada": "kn",
    "Malayalam": "ml",
    "Punjabi": "pa",
  };

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  /// **Fetch User Profile from Firestore**
  Future<void> _loadProfile() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        setState(() {
          _userId = user.uid;
        });

        DocumentSnapshot profile =
            await FirebaseFirestore.instance.collection("users").doc(user.uid).get();

        if (profile.exists && profile.data() != null) {
          setState(() {
            _nameController.text = profile["name"] ?? "";
            _selectedLanguage = profile["language"] ?? "Not Set";
            _selectedGender = profile["gender"] ?? "Male"; // Get gender from Firestore
            _profilePic = _getProfilePic(_selectedGender); // Set profile picture based on gender
          });
        }
      }
    } catch (e) {
      print("Error loading profile: $e");
    }
  }

  /// **Returns profile picture based on gender**
  String _getProfilePic(String? gender) {
    return gender == "Female" ? "assets/female.jpg" : "assets/male.jpg";
  }

  /// **Update User Name in Firestore**
  Future<void> _updateName() async {
    try {
      if (_userId != null) {
        await FirebaseFirestore.instance.collection("users").doc(_userId).update({
          "name": _nameController.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")),
        );
      }
    } catch (e) {
      print("Error updating name: $e");
    }
  }

  /// **Update Language in Firestore**
  Future<void> _updateLanguage(String newLanguage) async {
    try {
      if (_userId != null) {
        await FirebaseFirestore.instance.collection("users").doc(_userId).update({
          "language": newLanguage,
        });

        setState(() {
          _selectedLanguage = newLanguage;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Language updated successfully!")),
        );
      }
    } catch (e) {
      print("Error updating language: $e");
    }
  }

  /// **Delete User Profile**
  Future<void> _deleteProfile() async {
    try {
      if (_userId != null) {
        await FirebaseFirestore.instance.collection("users").doc(_userId).delete();
        await _auth.currentUser?.delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile deleted successfully!")),
        );

        // Navigate back to login screen
        Navigator.pushReplacementNamed(context, "/login");
      }
    } catch (e) {
      print("Error deleting profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete profile.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // **Profile Picture**
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage(_profilePic!), // ✅ Dynamic Profile Picture
              ),
            ),
            const SizedBox(height: 10),

            // **User Name Below Profile Picture**
            Text(
              _nameController.text.isEmpty ? "No Name Set" : _nameController.text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 20),

            // **Editable Name Input**
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Enter Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.person, color: Colors.blue),
              ),
            ),

            const SizedBox(height: 15),

            // **Profile Info Cards**
            _buildInfoCard(Icons.email, "Email", user?.email ?? "Not Available"),
            _buildInfoCard(Icons.vpn_key, "User ID", user?.uid ?? "Not Available"),
            _buildInfoCard(Icons.person_outline, "Gender", _selectedGender ?? "Not Set"),

            // **Preferred Language Section**
            _buildLanguageSelection(),

            const SizedBox(height: 20),

            // **Update & Delete Profile Buttons**
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _deleteProfile,
                  icon: const Icon(Icons.delete),
                  label: const Text("Delete Profile"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _updateName,
                  icon: const Icon(Icons.save),
                  label: const Text("Update Profile"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// **Preferred Language Selection UI**
  Widget _buildLanguageSelection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 📌 Text + Icon for "Preferred Language"
            Row(
              children: [
                const Icon(Icons.language, color: Colors.blue), // 🌍 Language Icon
                const SizedBox(width: 5), // 🔹 Space between icon and text
                const Text(
                  " Language",
                  style: TextStyle(fontSize: 16, ),
                ),
              ],
            ),

            // 🔽 Dropdown for Language Selection
            DropdownButton<String>(
              value: _selectedLanguage != "Not Set" ? _selectedLanguage : null,
              hint: const Text("Select Language"),
              items: _languageMap.keys.map((String key) {
                return DropdownMenuItem(
                  value: key,
                  child: Text(key),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _updateLanguage(newValue);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// **Reusable Card Widget for Displaying Profile Info**
  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}
*/


//UI 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  String? _userId;
  String? _selectedGender = "Male";
  String? _profilePic = "assets/male.jpg";
  String _selectedLanguage = "Not Set";

  final Map<String, String> _languageMap = {
    "English": "en",
    "Hindi": "hi",
    "Bengali": "bn",
    "Tamil": "ta",
    "Telugu": "te",
    "Marathi": "mr",
    "Gujarati": "gu",
    "Kannada": "kn",
    "Malayalam": "ml",
    "Punjabi": "pa",
  };

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        setState(() {
          _userId = user.uid;
        });

        DocumentSnapshot profile =
            await FirebaseFirestore.instance.collection("users").doc(user.uid).get();

        if (profile.exists && profile.data() != null) {
          setState(() {
            _nameController.text = profile["name"] ?? "";
            _selectedLanguage = profile["language"] ?? "Not Set";
            _selectedGender = profile["gender"] ?? "Male";
            _profilePic = _getProfilePic(_selectedGender);
          });
        }
      }
    } catch (e) {
      print("Error loading profile: $e");
    }
  }

  String _getProfilePic(String? gender) {
    return gender == "Female" ? "assets/female.jpg" : "assets/male.jpg";
  }

  Future<void> _updateName() async {
    if (_userId != null) {
      await FirebaseFirestore.instance.collection("users").doc(_userId).update({
        "name": _nameController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
    }
  }

  Future<void> _updateLanguage(String newLanguage) async {
    if (_userId != null) {
      await FirebaseFirestore.instance.collection("users").doc(_userId).update({
        "language": newLanguage,
      });

      setState(() {
        _selectedLanguage = newLanguage;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Language updated successfully!")),
      );
    }
  }

  Future<void> _deleteProfile() async {
    if (_userId != null) {
      await FirebaseFirestore.instance.collection("users").doc(_userId).delete();
      await _auth.currentUser?.delete();
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.blue[900],
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 10),
              CircleAvatar(
                radius: 55,
                backgroundImage: AssetImage(_profilePic!),
              ),
              const SizedBox(height: 12),
              Text(
                _nameController.text.isEmpty ? "No Name Set" : _nameController.text,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField("Enter Name", Icons.person, _nameController),
              const SizedBox(height: 15),
              _buildInfoCard(Icons.email, "Email", user?.email ?? "Not Available"),
              _buildInfoCard(Icons.vpn_key, "User ID", user?.uid ?? "Not Available"),
              _buildInfoCard(Icons.person, "Gender", _selectedGender ?? "Male"),
              _buildLanguageDropdown(),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _deleteProfile,
                      icon: const Icon(Icons.delete),
                      label: const Text("Delete"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _updateName,
                      icon: const Icon(Icons.save),
                      label: const Text("Save"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
                Text(value, style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        value: _selectedLanguage != "Not Set" ? _selectedLanguage : null,
        dropdownColor: Colors.blueGrey,
        iconEnabledColor: Colors.white,
        hint: const Text("Select Language", style: TextStyle(color: Colors.white70)),
        underline: const SizedBox(),
        style: const TextStyle(color: Colors.white),
        items: _languageMap.keys.map((String key) {
          return DropdownMenuItem(
            value: key,
            child: Text(key),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            _updateLanguage(newValue);
          }
        },
      ),
    );
  }
}

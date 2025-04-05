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
/*---------------------------------------------------------------------------------------------------------------------------*/

//WITH UI
/*import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'createprofilescreen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  String? _userId;
  String? _selectedLanguage = "Not Set"; // Default language text
  bool _profileExists = false;

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
          _nameController.text = user.displayName ?? "";
        });

        DocumentSnapshot profile =
            await FirebaseFirestore.instance.collection("users").doc(user.uid).get();

        if (profile.exists && profile.data() != null) {
          setState(() {
            _nameController.text = profile["name"];
            _selectedLanguage = profile["language"] ?? "Not Set";
            _profileExists = true;
          });
        } else {
          _profileExists = false;
        }
      }
    } catch (e) {
      print("Error loading profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.blue[900], // Dark Blue AppBar
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: user?.photoURL != null && user!.photoURL!.isNotEmpty
                      ? NetworkImage(user.photoURL!)
                      : const AssetImage('assets/a1.jpg') as ImageProvider,
                ),
              ),
              const SizedBox(height: 20),

              // Name Display
              _buildInfoCard(Icons.person, "Name", _nameController.text.isEmpty ? "No Name Set" : _nameController.text),

              // Email Display
              _buildInfoCard(Icons.email, "Email", user?.email ?? "Not Available"),

              // UID Display
              _buildInfoCard(Icons.vpn_key, "User ID", user?.uid ?? "Not Available"),

              // Language Display
              _buildInfoCard(Icons.language, "Language", _selectedLanguage ?? "Not Set"),

              const SizedBox(height: 20),

              // Editable Name Input
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Enter Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.edit, color: Colors.blue),
                ),
              ),

              const SizedBox(height: 20),

              // Profile Actions
              if (_profileExists) ...[
                ElevatedButton.icon(
                  onPressed: _updateProfile,
                  icon: const Icon(Icons.save),
                  label: const Text("Update Profile"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _deleteProfile,
                  icon: const Icon(Icons.delete),
                  label: const Text("Delete Profile"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                ),
              ] else ...[
                Center(
                  child: Column(
                    children: [
                      const Text(
                        "No profile found!",
                        style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _navigateToCreateProfile,
                        icon: const Icon(Icons.add),
                        label: const Text("Create Profile"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Reusable Card Widget for Displaying Profile Info
  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue[900]),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.grey),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Future<void> _updateProfile() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      String newName = _nameController.text.trim();

      if (newName.isNotEmpty) {
        await user.updateDisplayName(newName);
        await user.reload();

        await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
          "name": newName,
          "email": user.email,
          "language": _selectedLanguage,
        }, SetOptions(merge: true));

        setState(() {
          _profileExists = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile Updated!")),
        );
      }
    } catch (e) {
      print("Error updating profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile.")),
      );
    }
  }

  Future<void> _deleteProfile() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection("users").doc(user.uid).delete();
      await _auth.signOut();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Deleted!")),
      );

      Navigator.pushReplacementNamed(context, "/login");
    } catch (e) {
      print("Error deleting profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete profile.")),
      );
    }
  }

  void _navigateToCreateProfile() {
    if (_userId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateProfileScreen(userId: _userId!, email: _auth.currentUser!.email ?? ""),
        ),
      ).then((_) {
        _loadProfile(); // Reload profile after returning
      });
    }
  }
}
*/
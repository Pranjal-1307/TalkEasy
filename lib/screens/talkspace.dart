//TOGGLER MODE
/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:talk_easy/screens/callscreen.dart';
import 'package:talk_easy/screens/chatscreen.dart';
import 'package:talk_easy/screens/videocall.dart';

class TalkSpace extends StatefulWidget {
  final String userId;
  final String selectedLanguage;

  const TalkSpace({super.key, required this.userId, required this.selectedLanguage});

  @override
  _TalkSpaceState createState() => _TalkSpaceState();
}

class _TalkSpaceState extends State<TalkSpace> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _userList = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').get();
      setState(() {
        _userList = snapshot.docs.map((doc) => {
          'userId': doc.id,
          'name': doc['name'],
        }).toList();
        _filteredUsers = _userList;
      });
    } catch (e) {
      print("🔥 Firestore Error: $e");
    }
  }

  void _searchUsers(String query) {
    setState(() {
      _filteredUsers = query.isEmpty
          ? _userList
          : _userList.where((user) => user['name'].toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  Future<void> _sendCallRequest(String receiverId, String receiverName, String callType) async {
    String currentUserId = _auth.currentUser!.uid;
    String currentUserName = "User"; // Optional: fetch actual name

    DocumentReference requestRef = FirebaseFirestore.instance.collection('call_requests').doc();
    await requestRef.set({
      'requestId': requestRef.id,
      'callerId': currentUserId,
      'callerName': currentUserName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
      'callType': callType,
    });

    FirebaseFirestore.instance.collection('call_requests').doc(requestRef.id).snapshots().listen((doc) {
      if (doc.exists && doc['status'] == 'accepted' && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => callType == 'video'
                ? VideoCallScreen(channelId: doc['receiverId'], isCaller: true)
                : CallScreen(channelId: doc['receiverId'], isCaller: true),
          ),
        );
      }
    });
  }

  void _navigateToChat(String receiverId, String receiverName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          receiverId: receiverId,
          receiverName: receiverName,
          selectedLanguage: widget.selectedLanguage,
          receiverLanguage: '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Text(
                "Talk Space",
                style: GoogleFonts.poppins(
                  color: theme.colorScheme.onBackground,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: _searchUsers,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: "Search users...",
                  hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  prefixIcon: Icon(Icons.search, color: theme.iconTheme.color),
                  filled: true,
                  fillColor: theme.cardColor.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear, color: theme.iconTheme.color),
                    onPressed: () {
                      _searchController.clear();
                      _searchUsers('');
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: _filteredUsers.isEmpty
                  ? Center(
                      child: Text(
                        "No users found",
                        style: GoogleFonts.poppins(color: theme.colorScheme.onBackground.withOpacity(0.7)),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: theme.cardColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: theme.colorScheme.secondary,
                                child: Text(
                                  user['name'][0].toUpperCase(),
                                  style: TextStyle(color: theme.colorScheme.onSecondary),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  user['name'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: theme.colorScheme.onBackground,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.chat, color: theme.colorScheme.primary),
                                onPressed: () => _navigateToChat(user['userId'], user['name']),
                              ),
                              IconButton(
                                icon: Icon(Icons.call, color: Colors.green),
                                onPressed: () => _sendCallRequest(user['userId'], user['name'], 'audio'),
                              ),
                              IconButton(
                                icon: Icon(Icons.video_call, color: Colors.deepPurpleAccent),
                                onPressed: () => _sendCallRequest(user['userId'], user['name'], 'video'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
*/


//UI 
/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:talk_easy/screens/callscreen.dart';
import 'package:talk_easy/screens/chatscreen.dart';
import 'package:talk_easy/screens/videocall.dart';

class TalkSpace extends StatefulWidget {
  final String userId;
  final String selectedLanguage;

  const TalkSpace({super.key, required this.userId, required this.selectedLanguage});

  @override
  _TalkSpaceState createState() => _TalkSpaceState();
}

class _TalkSpaceState extends State<TalkSpace> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _userList = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').get();
      setState(() {
        _userList = snapshot.docs.map((doc) => {
          'userId': doc.id,
          'name': doc['name'],
        }).toList();
        _filteredUsers = _userList;
      });
    } catch (e) {
      print("🔥 Firestore Error: $e");
    }
  }

  void _searchUsers(String query) {
    setState(() {
      _filteredUsers = query.isEmpty
          ? _userList
          : _userList.where((user) => user['name'].toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  Future<void> _sendCallRequest(String receiverId, String receiverName, String callType) async {
    String currentUserId = _auth.currentUser!.uid;
    String currentUserName = "User"; // You can fetch this from Firestore if needed

    DocumentReference requestRef = FirebaseFirestore.instance.collection('call_requests').doc();
    await requestRef.set({
      'requestId': requestRef.id,
      'callerId': currentUserId,
      'callerName': currentUserName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
      'callType': callType,
    });

    FirebaseFirestore.instance.collection('call_requests').doc(requestRef.id).snapshots().listen((doc) {
      if (doc.exists && doc['status'] == 'accepted' && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => callType == 'video'
                ? VideoCallScreen(channelId: doc['receiverId'], isCaller: true)
                : CallScreen(channelId: doc['receiverId'], isCaller: true),
          ),
        );
      }
    });
  }

  void _navigateToChat(String receiverId, String receiverName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          receiverId: receiverId,
          receiverName: receiverName,
          selectedLanguage: widget.selectedLanguage,
          receiverLanguage: '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Text(
                "Talk Space",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Search Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: _searchUsers,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search users...",
                  hintStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white70),
                    onPressed: () {
                      _searchController.clear();
                      _searchUsers('');
                    },
                  ),
                ),
              ),
            ),

            // User List
            Expanded(
              child: _filteredUsers.isEmpty
                  ? Center(
                      child: Text(
                        "No users found",
                        style: GoogleFonts.poppins(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];
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
                              CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                child: Text(
                                  user['name'][0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  user['name'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.chat, color: Colors.lightBlueAccent),
                                onPressed: () => _navigateToChat(user['userId'], user['name']),
                              ),
                              IconButton(
                                icon: const Icon(Icons.call, color: Colors.greenAccent),
                                onPressed: () => _sendCallRequest(user['userId'], user['name'], 'audio'),
                              ),
                              IconButton(
                                icon: const Icon(Icons.video_call, color: Colors.deepPurpleAccent),
                                onPressed: () => _sendCallRequest(user['userId'], user['name'], 'video'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:talk_easy/screens/callscreen.dart';
import 'package:talk_easy/screens/chatscreen.dart';
import 'package:talk_easy/screens/videocall.dart';

class TalkSpace extends StatefulWidget {
  final String userId;
  final String selectedLanguage;

  const TalkSpace({super.key, required this.userId, required this.selectedLanguage});

  @override
  _TalkSpaceState createState() => _TalkSpaceState();
}

class _TalkSpaceState extends State<TalkSpace> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _userList = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  /// **Fetch Users from Firestore**
  Future<void> _fetchUsers() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').get();
      setState(() {
        _userList = snapshot.docs.map((doc) => {
          'userId': doc.id,
          'name': doc['name'],
        }).toList();
        _filteredUsers = _userList;
      });
    } catch (e) {
      print("🔥 Firestore Error: $e");
    }
  }

  /// **Filter Users by Name**
  void _searchUsers(String query) {
    setState(() {
      _filteredUsers = query.isEmpty
          ? _userList
          : _userList.where((user) => user['name'].toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  /// **Send Call Request**
  Future<void> _sendCallRequest(String receiverId, String receiverName, String callType) async {
    String currentUserId = _auth.currentUser!.uid;
    String currentUserName = "User"; // TODO: Fetch from Firestore

    DocumentReference requestRef = FirebaseFirestore.instance.collection('call_requests').doc();
    await requestRef.set({
      'requestId': requestRef.id,
      'callerId': currentUserId,
      'callerName': currentUserName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
      'callType': callType,
    });

    /// **Listen for call acceptance**
    FirebaseFirestore.instance.collection('call_requests').doc(requestRef.id).snapshots().listen((doc) {
      if (doc.exists && doc['status'] == 'accepted' && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => callType == 'video'
                ? VideoCallScreen(channelId: doc['receiverId'], isCaller: true)
                : CallScreen(channelId: "aimanzaki", isCaller: true),
          ),
        );
      }
    });
  }

  /// **Navigate to Chat Screen**
  void _navigateToChat(String receiverId, String receiverName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          receiverId: receiverId,
          receiverName: receiverName,
          selectedLanguage: widget.selectedLanguage,
          receiverLanguage: '', // ✅ Pass selectedLanguage
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _searchUsers,
              decoration: InputDecoration(
                labelText: "Search Users",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _searchUsers('');
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredUsers.isEmpty
                ? const Center(child: Text("No users found"))
                : ListView.builder(
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(_filteredUsers[index]['name'][0]),
                  ),
                  title: Text(_filteredUsers[index]['name']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chat, color: Colors.blue),
                        onPressed: () => _navigateToChat(
                          _filteredUsers[index]['userId'],
                          _filteredUsers[index]['name'],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.call, color: Colors.green),
                        onPressed: () => _sendCallRequest(
                          _filteredUsers[index]['userId'],
                          _filteredUsers[index]['name'],
                          'audio', // ✅ Always pass 'audio' for normal calls
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.video_call, color: Colors.purple),
                        onPressed: () => _sendCallRequest(
                          _filteredUsers[index]['userId'],
                          _filteredUsers[index]['name'],
                          'video', // ✅ Always pass 'video' for video calls
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


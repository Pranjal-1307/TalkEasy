/*import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';
import 'package:talk_easy/widgets/voice_button.dart';

class TalkSpace extends StatefulWidget {
  final String userId;
  const TalkSpace({super.key, required this.userId});

  @override
  _TalkSpaceState createState() => _TalkSpaceState();
}

class _TalkSpaceState extends State<TalkSpace> {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final GoogleTranslator _translator = GoogleTranslator();
  final TextEditingController _textController = TextEditingController();

  String _recognizedText = "Press the mic and speak...";
  bool _isListening = false;
  String _selectedLanguage = "en"; // Default English
  String _translatedText = "";

  final Map<String, String> _languages = {
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
    "Urdu": "ur",
  };

  @override
  void initState() {
    super.initState();
    _flutterTts.setSpeechRate(0.5);
  }

  /// Start listening and stop automatically when done
  Future<void> _startListening() async {
    bool available = await _speechToText.initialize(
      onError: (val) => print("Speech recognition error: $val"),
    );

    if (available) {
      setState(() => _isListening = true);
      _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            setState(() {
              _recognizedText = result.recognizedWords;
              _textController.text = result.recognizedWords;
              _isListening = false; // Stop listening when speech is processed
            });
          }
        },
        localeId: _selectedLanguage, // Use selected language
      );
    } else {
      print("Speech recognition not available.");
    }
  }

  /// Translate and speak
  Future<void> _translateAndSpeak() async {
    if (_textController.text.isNotEmpty) {
      try {
        final translation = await _translator.translate(
          _textController.text,
          to: _selectedLanguage,
        );

        setState(() {
          _translatedText = translation.text;
          _textController.text = translation.text;
        });

        await _flutterTts.setLanguage(_selectedLanguage);
        await _flutterTts.speak(_translatedText);
      } catch (e) {
        print("Translation error: $e");
      }
    } else {
      print("No text to translate and speak!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Talk Space"), automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedLanguage,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() => _selectedLanguage = newValue);
                }
              },
              items: _languages.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.value,
                  child: Text(entry.key),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: "Enter text to convert to speech",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _textController.clear(),
                ),
              ),
            ),
            const SizedBox(height: 10),

            Text(
              "Translated: $_translatedText",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                VoiceButton(
                  onPressed: _startListening, // Mic starts listening
                  icon: Icons.mic, // Always shows mic icon
                  color: Colors.blue, // Mic stays blue
                ),
                const SizedBox(width: 20),
                VoiceButton(
                  onPressed: _translateAndSpeak,
                  icon: Icons.translate,
                  color: Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}*/

/*---------------------------------------------------------------------------------------------------------------------------*/
/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:talk_easy/screens/callscreen.dart';

class TalkSpace extends StatefulWidget {
  final String userId;
  const TalkSpace({super.key, required this.userId});

  @override
  _TalkSpaceState createState() => _TalkSpaceState();
}

class _TalkSpaceState extends State<TalkSpace> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// **Search Firestore Users by Name**
  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) return;

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .get();

      setState(() {
        _searchResults = snapshot.docs.map((doc) => {
          'userId': doc.id,
          'name': doc['name'],
        }).toList();
      });
    } catch (e) {
      print("🔥 Firestore Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching users")),
      );
    }
  }

  /// **Send Call Request to Firestore**
  Future<void> _sendCallRequest(String receiverId, String receiverName) async {
  try {
    String currentUserId = _auth.currentUser!.uid;
    String currentUserName = _auth.currentUser!.displayName ?? "Unknown";

    DocumentReference requestRef =
        FirebaseFirestore.instance.collection('call_requests').doc();

    await requestRef.set({
      'requestId': requestRef.id,
      'callerId': currentUserId,
      'callerName': currentUserName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
    });

    print("✅ Call request sent to $receiverName");

    // **Caller should listen for 'accepted' call status**
    _listenForCallAcceptance(requestRef.id);

  } catch (e) {
    print("🔥 Error sending call request: $e");
  }
}

/// **Listen for Call Acceptance (Caller Side)**
void _listenForCallAcceptance(String requestId) {
  FirebaseFirestore.instance
      .collection('call_requests')
      .doc(requestId)
      .snapshots()
      .listen((doc) {
    if (doc.exists && doc['status'] == 'accepted') {
      print("✅ Call Accepted! Navigating caller to CallScreen");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(channelId: doc['receiverId'], isCaller: true),
        ),
      );
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Talk Space")),
      body: Column(
        children: [
          // **Search Bar**
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search Users",
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => _searchUsers(_searchController.text),
                ),
              ),
            ),
          ),

          // **Search Results**
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_searchResults[index]['name']),
                  trailing: IconButton(
                    icon: Icon(Icons.call, color: Colors.green),
                    onPressed: () => _sendCallRequest(
                      _searchResults[index]['userId'],
                      _searchResults[index]['name'],
                    ),
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
*/
/*-------------------------------------------------------------------------------------*/

/*
//CALL ONLY

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:talk_easy/screens/callscreen.dart';

class TalkSpace extends StatefulWidget {
  final String userId;
  const TalkSpace({super.key, required this.userId});

  @override
  _TalkSpaceState createState() => _TalkSpaceState();
}

class _TalkSpaceState extends State<TalkSpace> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _userList = []; // ✅ Store all users
  List<Map<String, dynamic>> _filteredUsers = []; // ✅ Filtered search results
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchUsers(); // ✅ Fetch all users when screen loads
    
  }

  /// **Fetch All Users from Firestore**
  Future<void> _fetchUsers() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').get();
      setState(() {
        _userList = snapshot.docs.map((doc) => {
          'userId': doc.id,
          'name': doc['name'],
        }).toList();
        _filteredUsers = _userList; // ✅ Show all users initially
      });
    } catch (e) {
      print("🔥 Firestore Error: $e");
    }
  }

  /// **Filter Users by Name**
  void _searchUsers(String query) {
    if (query.isEmpty) {
      setState(() => _filteredUsers = _userList); // ✅ Show all users if search is empty
    } else {
      setState(() {
        _filteredUsers = _userList.where((user) {
          return user['name'].toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  /// **Send Call Request to Firestore**
  Future<void> _sendCallRequest(String receiverId, String receiverName) async {
  try {
    String currentUserId = _auth.currentUser!.uid;
    
    // ✅ Fetch current user's name from Firestore
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUserId).get();
    String currentUserName = userDoc.exists ? userDoc['name'] : "Unknown"; // ✅ Ensure the caller name is fetched

    DocumentReference requestRef = FirebaseFirestore.instance.collection('call_requests').doc();

    await requestRef.set({
      'requestId': requestRef.id,
      'callerId': currentUserId,
      'callerName': currentUserName, // ✅ Store caller's name
      'receiverId': receiverId,
      'receiverName': receiverName,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
    });

    print("✅ Call request sent from $currentUserName to $receiverName");

    _listenForCallAcceptance(requestRef.id);
  } catch (e) {
    print("🔥 Error sending call request: $e");
  }
}

  /// **Listen for Call Acceptance (Caller Side)**
void _listenForCallAcceptance(String requestId) {
  FirebaseFirestore.instance.collection('call_requests').doc(requestId).snapshots().listen((doc) {
    if (doc.exists && doc['status'] == 'accepted') {
      print("✅ Call Accepted! Navigating caller to CallScreen");

      // ✅ Ensure the caller also joins the call
      FirebaseFirestore.instance.collection('active_calls').doc(doc['receiverId']).set({
        'status': 'active',
        'timestamp': FieldValue.serverTimestamp(),
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(channelId: doc['receiverId'], isCaller: true),
        ),
      );
    }
  });
}


  @override
   Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // **Search Bar**
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _searchUsers, // ✅ Update search results as user types
              decoration: InputDecoration(
                labelText: "Search Users",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _searchUsers(''); // ✅ Reset to show all users
                  },
                ),
              ),
            ),
          ),

          // **User Contact List (Search + All Users)**
          Expanded(
            child: _filteredUsers.isEmpty
                ? Center(child: Text("No users found"))
                : ListView.builder(
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(_filteredUsers[index]['name'][0]), // ✅ Show first letter of name
                        ),
                        title: Text(_filteredUsers[index]['name']),
                        trailing: IconButton(
                          icon: Icon(Icons.call, color: Colors.green),
                          onPressed: () => _sendCallRequest(
                            _filteredUsers[index]['userId'],
                            _filteredUsers[index]['name'],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}*/

/*-------------------------------------------------------------------------------------*/
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
                : CallScreen(channelId: doc['receiverId'], isCaller: true),
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

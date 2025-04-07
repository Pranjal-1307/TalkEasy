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
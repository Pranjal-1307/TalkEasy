//TOGGLER MODE
/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:talk_easy/screens/callscreen.dart';
import 'package:talk_easy/screens/videocall.dart';

class RequestHub extends StatefulWidget {
  @override
  _RequestHubState createState() => _RequestHubState();
}

class _RequestHubState extends State<RequestHub> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _acceptCall(String requestId, String callerId, String callerName, String callType) async {
    await FirebaseFirestore.instance.collection('call_requests').doc(requestId).update({'status': 'accepted'});

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => callType == 'video'
            ? VideoCallScreen(channelId: callerId, isCaller: false)
            : CallScreen(channelId: callerId, isCaller: false),
      ),
    );
  }

  void _declineCall(String requestId) async {
    try {
      await FirebaseFirestore.instance.collection('call_requests').doc(requestId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Call request declined")),
      );
    } catch (e) {
      print("🔥 Error declining call: $e");
    }
  }

  Future<String> _fetchCallerName(String callerId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(callerId).get();
      return userDoc.exists ? userDoc['name'] ?? "Unknown" : "Unknown";
    } catch (e) {
      print("🔥 Error fetching caller name: $e");
      return "Unknown";
    }
  }

  Widget _buildFriendRequests() {
    String currentUserId = _auth.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('friend_requests')
          .where('receiverId', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No friend requests"));
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            String requestId = doc.id;
            String senderId = doc['senderId'];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(senderId).get(),
              builder: (context, userSnapshot) {
                String senderName = userSnapshot.data?['name'] ?? "Unknown";

                return Card(
                  child: ListTile(
                    leading: Icon(Icons.person_add, color: Colors.orange),
                    title: Text("$senderName sent you a friend request"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            FirebaseFirestore.instance.collection('friend_requests').doc(requestId).update({
                              'status': 'accepted',
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            FirebaseFirestore.instance.collection('friend_requests').doc(requestId).delete();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCallRequests() {
    String currentUserId = _auth.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('call_requests')
          .where('receiverId', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No call requests"));
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            String requestId = doc['requestId'];
            String callerId = doc['callerId'];
            String callType = doc['callType'];

            return FutureBuilder<String>(
              future: _fetchCallerName(callerId),
              builder: (context, nameSnapshot) {
                String callerName = nameSnapshot.data ?? "Unknown";

                return Card(
                  child: ListTile(
                    leading: Icon(
                      callType == 'video' ? Icons.videocam : Icons.call,
                      color: callType == 'video' ? Colors.purple : Colors.blue,
                    ),
                    title: Text("$callerName is calling..."),
                    subtitle: Text("Tap to accept or decline."),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () => _acceptCall(requestId, callerId, callerName, callType),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () => _declineCall(requestId),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Top TabBar
          Container(
            color: Colors.white,
            child: TabBar(
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: [
                Tab(text: "Friend Requests"),
                Tab(text: "Call Requests"),
              ],
            ),
          ),

          // Tab View (Swipeable)
          Expanded(
            child: TabBarView(
              children: [
                _buildFriendRequests(),
                _buildCallRequests(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
*/

//UI 

//FREIND REQUEST 
/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:talk_easy/screens/callscreen.dart';
import 'package:talk_easy/screens/videocall.dart';

class RequestHub extends StatefulWidget {
  @override
  _RequestHubState createState() => _RequestHubState();
}

class _RequestHubState extends State<RequestHub> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _acceptCall(String requestId, String callerId, String callerName, String callType) async {
    await FirebaseFirestore.instance.collection('call_requests').doc(requestId).update({'status': 'accepted'});
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => callType == 'video'
            ? VideoCallScreen(channelId: callerId, isCaller: false)
            : CallScreen(channelId: callerId, isCaller: false),
      ),
    );
  }

  void _declineCall(String requestId) async {
    try {
      await FirebaseFirestore.instance.collection('call_requests').doc(requestId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Call request declined")),
      );
    } catch (e) {
      print("🔥 Error declining call: $e");
    }
  }

  Future<String> _fetchCallerName(String callerId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(callerId).get();
      return userDoc.exists ? userDoc['name'] ?? "Unknown" : "Unknown";
    } catch (e) {
      print("🔥 Error fetching caller name: $e");
      return "Unknown";
    }
  }

  Widget _buildFriendRequests() {
    String currentUserId = _auth.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('friend_requests')
          .where('receiverId', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No friend requests", style: TextStyle(color: Colors.white70)));
        }

        return ListView(
          padding: const EdgeInsets.all(12),
          children: snapshot.data!.docs.map((doc) {
            String requestId = doc.id;
            String senderId = doc['senderId'];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(senderId).get(),
              builder: (context, userSnapshot) {
                String senderName = userSnapshot.data?['name'] ?? "Unknown";

                return _buildGlassCard(
                  icon: Icons.person_add,
                  iconColor: Colors.orange,
                  title: "$senderName sent you a friend request",
                  onAccept: () {
                    FirebaseFirestore.instance.collection('friend_requests').doc(requestId).update({
                      'status': 'accepted',
                    });
                  },
                  onDecline: () {
                    FirebaseFirestore.instance.collection('friend_requests').doc(requestId).delete();
                  },
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCallRequests() {
    String currentUserId = _auth.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('call_requests')
          .where('receiverId', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No call requests", style: TextStyle(color: Colors.white70)));
        }

        return ListView(
          padding: const EdgeInsets.all(12),
          children: snapshot.data!.docs.map((doc) {
            String requestId = doc['requestId'];
            String callerId = doc['callerId'];
            String callType = doc['callType'];

            return FutureBuilder<String>(
              future: _fetchCallerName(callerId),
              builder: (context, nameSnapshot) {
                String callerName = nameSnapshot.data ?? "Unknown";

                return _buildGlassCard(
                  icon: callType == 'video' ? Icons.videocam : Icons.call,
                  iconColor: callType == 'video' ? Colors.purple : Colors.lightBlueAccent,
                  title: "$callerName is calling...",
                  subtitle: "Tap to accept or decline.",
                  onAccept: () => _acceptCall(requestId, callerId, callerName, callType),
                  onDecline: () => _declineCall(requestId),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildGlassCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onAccept,
    required VoidCallback onDecline,
  }) {
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
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 16)),
                if (subtitle != null)
                  Text(subtitle, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check, color: Colors.greenAccent),
            onPressed: onAccept,
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.redAccent),
            onPressed: onDecline,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF000428), Color(0xFF004e92)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text(
                "Request Hub",
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const TabBar(
                  indicatorColor: Colors.cyanAccent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: [
                    Tab(text: "Friend Requests"),
                    Tab(text: "Call Requests"),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildFriendRequests(),
                    _buildCallRequests(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/
/*---------------------------------------------------------------------------------------------------------------------------------------------------*/
/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:talk_easy/screens/callscreen.dart';
import 'package:talk_easy/screens/videocall.dart';

class RequestHub extends StatefulWidget {
  @override
  _RequestHubState createState() => _RequestHubState();
}

class _RequestHubState extends State<RequestHub> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _acceptCall(String requestId, String callerId, String callerName, String callType) async {
    await FirebaseFirestore.instance.collection('call_requests').doc(requestId).update({'status': 'accepted'});
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => callType == 'video'
            ? VideoCallScreen(channelId: callerId, isCaller: false)
            : CallScreen(channelId: callerId, isCaller: false),
      ),
    );
  }

  void _declineCall(String requestId) async {
    try {
      await FirebaseFirestore.instance.collection('call_requests').doc(requestId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Call request declined")),
      );
    } catch (e) {
      print("🔥 Error declining call: $e");
    }
  }

  Future<String> _fetchCallerName(String callerId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(callerId).get();
      return userDoc.exists ? userDoc['name'] ?? "Unknown" : "Unknown";
    } catch (e) {
      print("🔥 Error fetching caller name: $e");
      return "Unknown";
    }
  }

  Widget _buildCallRequests() {
    String currentUserId = _auth.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('call_requests')
          .where('receiverId', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No call requests", style: TextStyle(color: Colors.white70)));
        }

        return ListView(
          padding: const EdgeInsets.all(12),
          children: snapshot.data!.docs.map((doc) {
            String requestId = doc['requestId'];
            String callerId = doc['callerId'];
            String callType = doc['callType'];

            return FutureBuilder<String>(
              future: _fetchCallerName(callerId),
              builder: (context, nameSnapshot) {
                String callerName = nameSnapshot.data ?? "Unknown";

                return _buildGlassCard(
                  icon: callType == 'video' ? Icons.videocam : Icons.call,
                  iconColor: callType == 'video' ? Colors.purple : Colors.lightBlueAccent,
                  title: "$callerName is calling...",
                  subtitle: "Tap to accept or decline.",
                  onAccept: () => _acceptCall(requestId, callerId, callerName, callType),
                  onDecline: () => _declineCall(requestId),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildGlassCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onAccept,
    required VoidCallback onDecline,
  }) {
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
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 16)),
                if (subtitle != null)
                  Text(subtitle, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check, color: Colors.greenAccent),
            onPressed: onAccept,
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.redAccent),
            onPressed: onDecline,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF000428), Color(0xFF004e92)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Text(
              "Call Requests",
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildCallRequests()),
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
import 'package:talk_easy/screens/videocall.dart';

class RequestHub extends StatefulWidget {
  @override
  _RequestHubState createState() => _RequestHubState();
}

class _RequestHubState extends State<RequestHub> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// **Accept Call Request**
  void _acceptCall(String requestId, String callerId, String callerName, String callType) async {
    await FirebaseFirestore.instance.collection('call_requests').doc(requestId).update({'status': 'accepted'});

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => callType == 'video'
            ? VideoCallScreen(channelId: callerId, isCaller: false)
            : CallScreen(channelId: callerId, isCaller: false),
      ),
    );
  }

  /// **Decline Call Request**
  void _declineCall(String requestId) async {
    try {
      await FirebaseFirestore.instance.collection('call_requests').doc(requestId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Call request declined")),
      );
    } catch (e) {
      print("🔥 Error declining call: $e");
    }
  }

  /// **Fetch Caller’s Name from Firestore Users Collection**
  Future<String> _fetchCallerName(String callerId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(callerId).get();
      if (userDoc.exists) {
        return userDoc['name'] ?? "Unknown"; // ✅ Get caller's name from Firestore
      } else {
        return "Unknown";
      }
    } catch (e) {
      print("🔥 Error fetching caller name: $e");
      return "Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentUserId = _auth.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('call_requests')
          .where('receiverId', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No call requests"));
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            String requestId = doc['requestId'];
            String callerId = doc['callerId'];
            String callType = doc['callType']; // 🔥 Fetch `callType` from Firestore

            return FutureBuilder<String>(
              future: _fetchCallerName(callerId), // 🔥 Fetch caller's real name
              builder: (context, nameSnapshot) {
                String callerName = nameSnapshot.data ?? "Unknown"; // Default name if not found

                return Card(
                  child: ListTile(
                    leading: Icon(
                      callType == 'video' ? Icons.videocam : Icons.call,
                      color: callType == 'video' ? Colors.purple : Colors.blue,
                    ),
                    title: Text("$callerName is calling..."), // ✅ Show caller's actual name
                    subtitle: Text("Tap to accept or decline."),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () => _acceptCall(requestId, "aimanzaki", callerName, callType),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () => _declineCall(requestId),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}



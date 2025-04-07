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

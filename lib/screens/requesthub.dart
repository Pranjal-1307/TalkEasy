/*import 'package:flutter/material.dart';

class RequestHub extends StatefulWidget {
  const RequestHub({super.key});

  @override
  _RequestHubState createState() => _RequestHubState();
}

class _RequestHubState extends State<RequestHub> {
  List<String> requests = ['Alice', 'Bob', 'Charlie', 'David', 'Eve', 'Frank'];

  void _acceptRequest(int index) {
    setState(() {
      requests.removeAt(index);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request Accepted')),
      );
    });
  }

  void _declineRequest(int index) {
    setState(() {
      requests.removeAt(index);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request Declined')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.request_page),
                  title: Text(requests[index]),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _acceptRequest(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _declineRequest(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}*/

/*---------------------------------------------------------------------------------------------------------------------------*/

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
}

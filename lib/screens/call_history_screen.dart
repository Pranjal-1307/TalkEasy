import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class CallHistoryScreen extends StatelessWidget {
  const CallHistoryScreen({super.key});

  Stream<QuerySnapshot> _getCallHistoryStream() {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('call_history')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return DateFormat('dd MMM yyyy • hh:mm a').format(dateTime);
  }

  IconData _getCallIcon(String type) {
    return type == 'video' ? Icons.videocam : Icons.call;
  }

  Color _getCallColor(String type) {
    return type == 'video' ? Colors.purpleAccent : Colors.lightBlueAccent;
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
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
          centerTitle: true, // 👈 Center the title
          title: const Text(
            "Call History",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold, // 👈 Bold text
              fontSize: 30,
            ),
          ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white), // For white back icon if needed
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: _getCallHistoryStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text("No call history yet", style: TextStyle(color: Colors.white70)),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final callType = data['callType'];
                  final timestamp = data['timestamp'] as Timestamp;
                  final name = data['callerName'] ?? 'Unknown';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        Icon(_getCallIcon(callType), color: _getCallColor(callType), size: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$name (${callType.toUpperCase()} Call)",
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTimestamp(timestamp),
                                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ),
    );
  }
}

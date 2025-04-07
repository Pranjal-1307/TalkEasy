import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  ChatScreen({
    required this.receiverId,
    required this.receiverName,
    required String selectedLanguage,
    required String receiverLanguage,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterTts _flutterTts = FlutterTts();
  final GoogleTranslator _translator = GoogleTranslator();

  String selectedLanguage = "hi"; // Default to Hindi

  final Map<String, String> languageMap = {
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
    _flutterTts.getLanguages.then((languages) {
      print("Supported languages: $languages");
    });
  }

  Future<void> _sendMessage() async {
    String message = _messageController.text.trim();
    if (message.isEmpty) return;

    String senderId = _auth.currentUser!.uid;
    String chatId = senderId.hashCode <= widget.receiverId.hashCode
        ? "$senderId-${widget.receiverId}"
        : "${widget.receiverId}-$senderId";

    DocumentSnapshot senderDoc = await FirebaseFirestore.instance.collection("users").doc(senderId).get();
    DocumentSnapshot receiverDoc = await FirebaseFirestore.instance.collection("users").doc(widget.receiverId).get();

    String senderLanguage = senderDoc.exists ? senderDoc["language"] ?? "English" : "English";
    String receiverLanguage = receiverDoc.exists ? receiverDoc["language"] ?? "English" : "English";

    String senderLangCode = languageMap[senderLanguage] ?? "en";
    String receiverLangCode = languageMap[receiverLanguage] ?? "en";

    try {
      String translatedMessage = senderLangCode == receiverLangCode
          ? message
          : (await _translator.translate(message, from: senderLangCode, to: receiverLangCode)).text;

      await FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages').add({
        'senderId': senderId,
        'receiverId': widget.receiverId,
        'originalText': message,
        'text': translatedMessage,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
    } catch (e) {
      print("🔥 Error in translation: $e");
    }
  }

  Future<void> _translateAndSpeak(String message) async {
    try {
      await _flutterTts.setLanguage(selectedLanguage);
      await _flutterTts.speak(message);
    } catch (e) {
      print("🔥 Error in TTS: $e");
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    String senderId = _auth.currentUser!.uid;
    String chatId = senderId.hashCode <= widget.receiverId.hashCode
        ? "$senderId-${widget.receiverId}"
        : "${widget.receiverId}-$senderId";

    Color backgroundColor = Color(0xFFF2F4F7);
    Color myBubbleColor = Color(0xFFD6EAF8);
    Color theirBubbleColor = Color(0xFFF7F9F9);
    Color textColor = Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: textColor),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.receiverName, style: TextStyle(color: textColor)),
            DropdownButton<String>(
              value: selectedLanguage,
              items: languageMap.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.value,
                  child: Row(
                    children: [
                      Icon(Icons.language, color: textColor),
                      const SizedBox(width: 5),
                      Text(entry.key, style: TextStyle(color: textColor)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() => selectedLanguage = value!);
              },
              dropdownColor: Colors.white,
              iconEnabledColor: textColor,
              style: TextStyle(color: textColor),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var messageData = messages[index];
                    Map<String, dynamic> messageMap = messageData.data() as Map<String, dynamic>;

                    bool isMe = messageMap['senderId'] == senderId;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          if (!isMe)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                widget.receiverName,
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ),
                          GestureDetector(
                            onLongPress: () => _translateAndSpeak(messageMap['text']),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isMe ? myBubbleColor : theirBubbleColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    messageMap['text'] ?? "Translation Error",
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (messageMap['originalText'] != messageMap['text']) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      "(${messageMap['originalText']})",
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                  ],
                                  if (messageMap['timestamp'] != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        _formatTimestamp(messageMap['timestamp']),
                                        style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: TextStyle(color: Colors.grey),
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

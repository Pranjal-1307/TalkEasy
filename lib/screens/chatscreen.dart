/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const ChatScreen({super.key, required this.receiverId, required this.receiverName, required String selectedLanguage});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterTts _flutterTts = FlutterTts();
  final GoogleTranslator _translator = GoogleTranslator();
  String selectedLanguage = "hi"; // Default to Hindi

  /// **Send Message**
  Future<void> _sendMessage() async {
    String message = _messageController.text.trim();
    if (message.isEmpty) return;

    String senderId = _auth.currentUser!.uid;
    String chatId = senderId.hashCode <= widget.receiverId.hashCode
        ? "$senderId-${widget.receiverId}"
        : "${widget.receiverId}-$senderId";

    await FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages').add({
      'senderId': senderId,
      'receiverId': widget.receiverId,
      'text': message,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  /// **Translate and Speak Message**
  Future<void> _translateAndSpeak(String message) async {
    var translation = await _translator.translate(message, to: selectedLanguage);
    await _flutterTts.speak(translation.text);
  }

  @override
  Widget build(BuildContext context) {
    String senderId = _auth.currentUser!.uid;
    String chatId = senderId.hashCode <= widget.receiverId.hashCode
        ? "$senderId-${widget.receiverId}"
        : "${widget.receiverId}-$senderId";

    return Scaffold(
      appBar: AppBar(title: Text(" ${widget.receiverName}")),
      body: Column(
        children: [
          // **Messages List**
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text("Error loading messages"));
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var messageData = messages[index];
                    bool isMe = messageData['senderId'] == senderId;

                    return GestureDetector(
                      onLongPress: () => _translateAndSpeak(messageData['text']),
                      child: Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            messageData['text'],
                            style: TextStyle(color: isMe ? Colors.white : Colors.black),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // **Message Input Field**
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
}*/


import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  ChatScreen({required this.receiverId, required this.receiverName, required String selectedLanguage, required String receiverLanguage});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterTts _flutterTts = FlutterTts();
  final GoogleTranslator _translator = GoogleTranslator();

  String selectedLanguage = "hi"; // Default to Hindi

  // ✅ **Language Map for Indian Dialects**
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
    _checkTtsLanguages();
  }

  Future<void> _checkTtsLanguages() async {
    List<dynamic> languages = await _flutterTts.getLanguages;
    print("Supported languages: $languages");
  }

  /// **Send Message**
  Future<void> _sendMessage() async {
    String message = _messageController.text.trim();
    if (message.isEmpty) return;

    String senderId = _auth.currentUser!.uid;
    String chatId = senderId.hashCode <= widget.receiverId.hashCode
        ? "$senderId-${widget.receiverId}"
        : "${widget.receiverId}-$senderId";

    // ✅ **Fetch sender & receiver language from Firestore**
    DocumentSnapshot senderDoc =
        await FirebaseFirestore.instance.collection("users").doc(senderId).get();
    DocumentSnapshot receiverDoc =
        await FirebaseFirestore.instance.collection("users").doc(widget.receiverId).get();

    String senderLanguage = senderDoc.exists ? senderDoc["language"] ?? "English" : "English";
    String receiverLanguage = receiverDoc.exists ? receiverDoc["language"] ?? "English" : "English";

    // ✅ **Ensure language codes exist in the map**
    String senderLangCode = languageMap[senderLanguage] ?? "en";
    String receiverLangCode = languageMap[receiverLanguage] ?? "en";

    try {
      // ✅ **Translate message to receiver's language**
      String translatedMessage = senderLangCode == receiverLangCode
          ? message // ✅ No translation needed if same language
          : (await _translator.translate(message, from: senderLangCode, to: receiverLangCode)).text;

      await FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages').add({
        'senderId': senderId,
        'receiverId': widget.receiverId,
        'originalText': message, // ✅ Store original message
        'text': translatedMessage, // ✅ Store translated message
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
    } catch (e) {
      print("🔥 Error in translation: $e");
    }
  }

  /// **Translate & Speak Message**
  Future<void> _translateAndSpeak(String message) async {
    try {
      await _flutterTts.setLanguage(selectedLanguage);
      await _flutterTts.speak(message);
    } catch (e) {
      print("🔥 Error in TTS: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String senderId = _auth.currentUser!.uid;
    String chatId = senderId.hashCode <= widget.receiverId.hashCode
        ? "$senderId-${widget.receiverId}"
        : "${widget.receiverId}-$senderId";

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between title and actions
          children: [
            
            // Right side: Name and Language Dropdown
            Row(
              children: [
                Text(" ${widget.receiverName}", style: TextStyle(color: Colors.black)),
                const SizedBox(width: 100),
                DropdownButton<String>(
                  value: selectedLanguage,
                  items: languageMap.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.value,
                      child: Row(
                        children: [
                          // Add language flag/logo here
                          Icon(Icons.language, color: Colors.black), // You can replace this with flag icons
                          const SizedBox(width: 5),
                          Text(entry.key, style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() => selectedLanguage = value!);
                  },
                  dropdownColor: Colors.white, // Optional, customize dropdown color
                  iconEnabledColor: Colors.black, // Optional, for dropdown icon color
                  style: TextStyle(color: Colors.black), // Optional, for dropdown text color
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ✅ **Messages List**
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading messages"));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var messageData = messages[index];

                    bool isMe = messageData['senderId'] == senderId;

                    // ✅ **Fix: Explicitly cast to Map<String, dynamic>**
                    Map<String, dynamic> messageMap =
                        messageData.data() as Map<String, dynamic>;

                    return GestureDetector(
                      onLongPress: () => _translateAndSpeak(messageMap['text']),
                      child: Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                messageMap['text'] ?? "Translation Error",
                                style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              if (messageMap.containsKey('originalText') &&
                                  messageMap['originalText'] != messageMap['text']) ...[
                                const SizedBox(height: 5),
                                Text(
                                  "(${messageMap['originalText']})", // ✅ Show original text
                                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // ✅ **Message Input Field**
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
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
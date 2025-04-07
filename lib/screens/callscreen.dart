//AGORA
/*
import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:talk_easy/screens/homescreen.dart';
import 'package:talk_easy/services/agora_service.dart';

class CallScreen extends StatefulWidget {
  final String channelId;
  final bool isCaller;

  //const CallScreen({Key? key, required this.channelId, required this.isCaller}) : super(key: key);
  const CallScreen({
  Key? key,
  this.channelId = "a1gI18xntlfcZhYgiTteMcF5vTj1",
  required this.isCaller,
}) : super(key: key);


  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final AgoraService _agoraService = AgoraService();
  bool _isMicMuted = false;
  bool _isSpeakerOn = true;
  int? _remoteUid;
  Timer? _callTimer;
  int _callDuration = 0; // Call duration in seconds
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    _initializeCall();
  }

  /// **Initialize Call**
  Future<void> _initializeCall() async {
    if (await Permission.microphone.request().isGranted) {
      print("🎙️ Microphone permission granted");

      try {
        // ✅ Initialize Agora Engine
        await _agoraService.initAgora();
        _engine = _agoraService.agoraEngine!;

        // ✅ Join Call with Channel ID
        await _agoraService.joinCall(widget.channelId); // 🔥 Fixed: Pass channelId
        print("✅ Joined Agora Call Successfully on channel: ${widget.channelId}");

        // ✅ Set Audio Settings
        await _engine.setEnableSpeakerphone(true);
        await _engine.setAudioProfile(
          profile: AudioProfileType.audioProfileDefault,
          scenario: AudioScenarioType.audioScenarioGameStreaming,
        );

        _startCallTimer();
        _listenForCallEvents();
      } catch (e) {
        print("🔥 Error during call initialization: $e");
      }
    } else {
      print("❌ Microphone permission denied!");
    }
  }

  /// **Start Call Timer**
  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDuration += 1;
        });
      }
    });
  }

  /// **Format Time into mm:ss**
  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  void _toggleMute() {
    setState(() => _isMicMuted = !_isMicMuted);
    _agoraService.toggleMute(_isMicMuted);
  }

  void _toggleSpeaker() {
    setState(() => _isSpeakerOn = !_isSpeakerOn);
    _agoraService.toggleSpeaker(_isSpeakerOn);
  }

  /// **Listen for Call Events (User Joined/Left)**
  void _listenForCallEvents() {
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print("🟢 User $remoteUid joined the call");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          print("🔴 User $remoteUid left the call, reason: $reason");
          if (reason == UserOfflineReasonType.userOfflineQuit) {
            _endCall();
          }
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          print("❌ User left channel, stopping call UI");
          _endCall();
        },
      ),
    );
  }

  /// **End Call and Navigate to HomeScreen**
  void _endCall() async {
    try {
      _callTimer?.cancel(); // ✅ Stop the timer

      await _agoraService.leaveCall();
      await _engine.disableAudio(); // ✅ Explicitly disable audio
      await _engine.leaveChannel();
      await _engine.release(); // ✅ Ensure proper cleanup

      await FirebaseFirestore.instance.collection('active_calls').doc(widget.channelId).set({
        'status': 'ended',
        'endedBy': FirebaseAuth.instance.currentUser?.uid,
        'duration': _callDuration, // ✅ Save call duration
      }, SetOptions(merge: true));

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              onThemeToggle: (bool value) {}, // ✅ Match HomeScreen parameters
              isDarkMode: false, // ✅ Ensure theme is passed correctly
            ),
          ),
          (Route<dynamic> route) => false, // ✅ Clears previous screens
        );
      }
    } catch (e) {
      print("🔥 Error ending call: $e");
    }
  }

  @override
  void dispose() {
    _callTimer?.cancel(); // ✅ Stop timer
    _agoraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Voice Call")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mic,
              size: 100,
              color: _remoteUid != null ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              _remoteUid != null ? "Connected" : "Waiting for user...",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Call Duration: ${_formatDuration(_callDuration)}", // ✅ Show Call Timer
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blue),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(_isMicMuted ? Icons.mic_off : Icons.mic),
              color: _isMicMuted ? Colors.red : Colors.blue,
              onPressed: _toggleMute,
            ),
            const SizedBox(width: 20),
            IconButton(
              icon: Icon(_isSpeakerOn ? Icons.volume_up : Icons.volume_down),
              color: _isSpeakerOn ? Colors.green : Colors.grey,
              onPressed: _toggleSpeaker,
            ),
            const SizedBox(width: 20),
            IconButton(
              icon: const Icon(Icons.call_end, color: Colors.red),
              onPressed: _endCall, // ✅ Navigates to HomeScreen on end call
            ),
          ],
        ),
      ),
    );
  }
}
*/
/*---------------------------------------------------------------------------------------------------------------------------*/
//AGORA
import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:talk_easy/screens/homescreen.dart';
import 'package:talk_easy/services/agora_service.dart';

class CallScreen extends StatefulWidget {
  final String channelId;
  final bool isCaller;

  const CallScreen({Key? key, required this.channelId, required this.isCaller}) : super(key: key);

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final AgoraService _agoraService = AgoraService();
  bool _isMicMuted = false;
  bool _isSpeakerOn = true;
  int? _remoteUid;
  Timer? _callTimer;
  int _callDuration = 0; // Call duration in seconds
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    _initializeCall();
  }

  /// **Initialize Call**
  Future<void> _initializeCall() async {
    if (await Permission.microphone.request().isGranted) {
      print("🎙️ Microphone permission granted");

      try {
        // ✅ Initialize Agora Engine
        await _agoraService.initAgora();
        _engine = _agoraService.agoraEngine!;
        print("✅ Agora Initialized (Audio)");
        _listenForCallEvents();

        // ✅ Enable Audio
        await _engine.enableAudio();

        await _engine.setDefaultAudioRouteToSpeakerphone(true);

        // ✅ Set Audio Profile
        await _engine.setAudioProfile(
          profile: AudioProfileType.audioProfileDefault,
          scenario: AudioScenarioType.audioScenarioGameStreaming,
        );

        // ✅ Join Call
        await _agoraService.joinCall(widget.channelId);
        print("✅ Joined Agora Call Successfully on channel: ${widget.channelId}");

        _startCallTimer();
      } catch (e) {
        print("🔥 Error during call initialization: $e");
      }
    } else {
      print("❌ Microphone permission denied!");
    }
  }

  /// **Start Call Timer**
  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDuration += 1;
        });
      }
    });
  }

  /// **Format Time into mm:ss**
  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  void _toggleMute() {
    setState(() => _isMicMuted = !_isMicMuted);
    _agoraService.toggleMute(_isMicMuted);
  }

  void _toggleSpeaker() {
    setState(() => _isSpeakerOn = !_isSpeakerOn);
    _agoraService.toggleSpeaker(_isSpeakerOn);
  }

  /// **Listen for Call Events (User Joined/Left)**
  void _listenForCallEvents() {
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print("🟢 User $remoteUid joined the call");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          print("🔴 User $remoteUid left the call, reason: $reason");
          if (reason == UserOfflineReasonType.userOfflineQuit) {
            _endCall();
          }
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          print("❌ User left channel, stopping call UI");
          _endCall();
        },
      ),
    );
  }

  /// **End Call and Navigate to HomeScreen**
  void _endCall() async {
    try {
      _callTimer?.cancel(); // ✅ Stop the timer

      await _agoraService.leaveCall();
      await _engine.disableAudio(); // ✅ Explicitly disable audio
      await _engine.leaveChannel();
      await _engine.release(); // ✅ Ensure proper cleanup

      await FirebaseFirestore.instance.collection('active_calls').doc(widget.channelId).set({
        'status': 'ended',
        'endedBy': FirebaseAuth.instance.currentUser?.uid,
        'duration': _callDuration, // ✅ Save call duration
      }, SetOptions(merge: true));

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              onThemeToggle: (bool value) {}, // ✅ Match HomeScreen parameters
              isDarkMode: false, // ✅ Ensure theme is passed correctly
            ),
          ),
              (Route<dynamic> route) => false, // ✅ Clears previous screens
        );
      }
    } catch (e) {
      print("🔥 Error ending call: $e");
    }
  }

  @override
  void dispose() {
    _callTimer?.cancel(); // ✅ Stop timer
    _agoraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Voice Call")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mic,
              size: 100,
              color: _remoteUid != null ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              _remoteUid != null ? "Connected" : "Waiting for user...",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Call Duration: ${_formatDuration(_callDuration)}", // ✅ Show Call Timer
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blue),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(_isMicMuted ? Icons.mic_off : Icons.mic),
              color: _isMicMuted ? Colors.red : Colors.blue,
              onPressed: _toggleMute,
            ),
            const SizedBox(width: 20),
            IconButton(
              icon: Icon(_isSpeakerOn ? Icons.volume_up : Icons.volume_down),
              color: _isSpeakerOn ? Colors.green : Colors.grey,
              onPressed: _toggleSpeaker,
            ),
            const SizedBox(width: 20),
            IconButton(
              icon: const Icon(Icons.call_end, color: Colors.red),
              onPressed: _endCall, // ✅ Navigates to HomeScreen on end call
            ),
          ],
        ),
      ),
    );
  }
}

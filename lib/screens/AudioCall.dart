import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

const String appId = "6900741fa0f04513af9befbd65522483";
const String channelName = "TalkEasy";
const String token = "007eJxTYBBYd2XF+5K72b/OREou+8dcPPHG/zv7j+YvepP8OGi2adYLBQYzSwMDcxPDtESDNAMTU0PjxDTLpNS0pBQzU1MjIxML4zsTP6c3BDIyrCwtYWZkYGRgAWIQnwlMMoNJFjDJwRCSmJPtmlhcycAAANupJ/4="; // Generate from Agora Console

class AudioCallPage extends StatefulWidget {
  @override
  _AudioCallPageState createState() => _AudioCallPageState();
}

class _AudioCallPageState extends State<AudioCallPage> {
  late RtcEngine _engine;
  bool isJoined = false;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    // Request microphone permission
    await [Permission.microphone].request();

    // Create Agora Engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(appId: appId));

    // Register event handlers
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() => isJoined = true);
          print("✅ Joined channel: ${connection.channelId}");
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print("👤 User joined: $remoteUid");
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          print("🚪 User offline: $remoteUid");
          _endCall(); // Automatically end call if the other user disconnects
        },
      ),
    );

    // Enable audio
    await _engine.enableAudio();
  }

  void joinChannel() async {
    await _engine.joinChannel(
      token: token,
      channelId: channelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  void _endCall() async {
    await _engine.leaveChannel();
    setState(() => isJoined = false);
    if (mounted) {
      Navigator.pop(context); // Close UI when call ends
    }
  }

  @override
  void dispose() {
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Agora Audio Call")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(isJoined ? "🔊 Connected to Channel" : "❌ Not Connected"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isJoined ? _endCall : joinChannel,
              child: Text(isJoined ? "End Call" : "Join Call"),
            ),
          ],
        ),
      ),
    );
  }
}
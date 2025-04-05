import 'dart:ui';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class AgoraService {
  final String appId = "7e56aee6e92a4993ab2d792666e14076";
  final String token = "007eJxTYNhx7hb3/dl2B6epBSyO6jW9Kc2xKd7i9UNZq9g33iJKWu8UGMxTTc0SU1PNUi2NEk0sLY0Tk4xSzC2NzMzMUg1NDMzN/i96m94QyMjAZraFiZEBAkF8DoaQxJxs18TiSgYGALhJIGU=";
  RtcEngine? agoraEngine;
  
  bool _isSpeakerOn = true;
  bool _isVideoEnabled = false;

  /// **Callback to Notify UI When Call Ends**
  VoidCallback? onCallEnd;  // 🚀 FIXED: Define onCallEnd callback

  Future<void> initAgora({bool enableVideo = false}) async {
    try {
      agoraEngine = createAgoraRtcEngine();
      await agoraEngine!.initialize(
        RtcEngineContext(
          appId: appId,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );

      _isVideoEnabled = enableVideo;

      if (enableVideo) {
        await agoraEngine!.enableVideo();
      } else {
        await agoraEngine!.enableAudio();
        await agoraEngine!.disableVideo();
      }

      _registerAgoraEventHandlers();
      print("✅ Agora Initialized (${enableVideo ? 'Video' : 'Audio'})");
    } catch (e) {
      print("🔥 Error initializing Agora: $e");
    }
  }

  Future<void> leaveCall() async {
    if (agoraEngine == null) return;
    
    try {
      await agoraEngine!.leaveChannel();
      await agoraEngine!.stopPreview();
      print("🚪 Left Agora Call");

      // 🚀 FIXED: Notify the UI when call ends
      if (onCallEnd != null) {
        onCallEnd!();  // Call the function to close UI
      }
    } catch (e) {
      print("🔥 Error leaving call: $e");
    }
  }

  void _registerAgoraEventHandlers() {
    if (agoraEngine == null) return;

    agoraEngine!.registerEventHandler(
      RtcEngineEventHandler(
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print("👥 Remote user joined: $remoteUid");
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          print("🔴 Remote user left: $remoteUid, reason: $reason");

          // 🚀 FIXED: Call leaveCall() when other user disconnects
          print("🚨 Other user disconnected. Leaving call...");
          leaveCall();
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          print("❌ Left the channel.");
        },
      ),
    );
  }

  void dispose() {
    agoraEngine?.release();
    agoraEngine = null;
    print("🛑 Agora Engine Released");
  }

  void toggleMute(bool isMicMuted) {}

  void toggleSpeaker(bool isSpeakerOn) {}

  joinCall(String channelId) {}
}

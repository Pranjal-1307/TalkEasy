/*import 'package:zego_express_engine/zego_express_engine.dart';

class ZegoService {
  final int appID = 2089417047; 
  final String appSign =
      "04AAAAAGfuxF4ADBRS04sbTSFOB9MX0gCy0e1oYrq7dhxfKZuDmdTAwbWaMDotecPezX6uX6S0ECd9EDKB05ITHhjbhj7PHJFscVTdvRljp9EkRBAmDQB7iB43WfyUzX+vca5OLwboIBpSWtoS783ZNXPv1FUKLaNTFt2ieQHyqLoAn4KMk/V8ONY5o9398iSNZ9un4/ZI+zAfG8hzsekiZRxKSx+lEeQi7O6x6qM5pS0ifMxaFJRd/HwTLbfkXlnVXMHGF5+LlMI64gE=";

  bool isJoined = false;
  bool isVideoEnabled = false;

  Future<void> initialize() async {
    await ZegoExpressEngine.createEngineWithProfile(
      ZegoEngineProfile(
        appID,
        ZegoScenario.General,
        appSign: appSign,
      ),
    );
  }

  Future<void> joinCall({required String firebaseUserID, required String callType}) async {
  try {
    bool isVideo = (callType == "video"); // Check if it's a video call

    if (!isJoined) {
      await initialize();
      await ZegoExpressEngine.instance.loginRoom(
        "roomID",
        ZegoUser(firebaseUserID, "UserName"),
        config: ZegoRoomConfig(10, true, ""),
      );

      if (isVideo) {
        isVideoEnabled = true;
        await ZegoExpressEngine.instance.startPublishingStream("streamID");
        await ZegoExpressEngine.instance.startPreview();
      } else {
        await ZegoExpressEngine.instance.startPublishingStream("streamID");
      }

      isJoined = true;
    }
  } catch (e) {
    print("🔥 Error joining call: $e");
  }
}



  Future<void> leaveCall() async {
    try {
      if (isJoined) {
        if (isVideoEnabled) {
          await ZegoExpressEngine.instance.stopPreview();
        }

        await ZegoExpressEngine.instance.stopPublishingStream();
        await ZegoExpressEngine.instance.logoutRoom("roomID");
        ZegoExpressEngine.destroyEngine();

        isJoined = false;
        isVideoEnabled = false;
      }
    } catch (e) {
      print("🔥 Error leaving call: $e");
    }
  }

  /// **🔹 Toggle Microphone (Mute/Unmute)**
  Future<void> toggleMute(bool isMuted) async {
    try {
      await ZegoExpressEngine.instance.muteMicrophone(isMuted);
    } catch (e) {
      print("🔥 Error toggling mute: $e");
    }
  }

  /// **🔹 Toggle Speaker (Enable/Disable Speaker)**
  Future<void> toggleSpeaker(bool isSpeakerOn) async {
    try {
      await ZegoExpressEngine.instance.muteSpeaker(!isSpeakerOn);
    } catch (e) {
      print("🔥 Error toggling speaker: $e");
    }
  }
}
*/
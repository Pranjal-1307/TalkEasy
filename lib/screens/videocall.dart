import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoCallScreen extends StatefulWidget {
  final String channelId;
  final bool isCaller;

  const VideoCallScreen({Key? key, required this.channelId, required this.isCaller}) : super(key: key);

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final RtcEngine _engine = createAgoraRtcEngine();
  int? _remoteUid;
  bool _isVideoMuted = false;
  bool _isMicMuted = false;

  @override
  void initState() {
    super.initState();
    _initializeAgora();
  }

  Future<void> _initializeAgora() async {
  await [Permission.microphone, Permission.camera].request();

  await _engine.initialize(const RtcEngineContext(appId: "7e56aee6e92a4993ab2d792666e14076"));

  await _engine.enableVideo();
  await _engine.startPreview(); // ✅ Start local video preview
  await _engine.setChannelProfile(ChannelProfileType.channelProfileCommunication);

  await _engine.joinChannel(
    token: "007eJxTYNhx7hb3/dl2B6epBSyO6jW9Kc2xKd7i9UNZq9g33iJKWu8UGMxTTc0SU1PNUi2NEk0sLY0Tk4xSzC2NzMzMUg1NDMzN/i96m94QyMjAZraFiZEBAkF8DoaQxJxs18TiSgYGALhJIGU=",
    channelId: widget.channelId,
    uid: 0,
    options: const ChannelMediaOptions(
      publishCameraTrack: true, // ✅ Ensure camera is shared
      publishMicrophoneTrack: true, // ✅ Ensure mic is shared
    ),
  );

  _engine.registerEventHandler(RtcEngineEventHandler(
    onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
      setState(() {
        _remoteUid = remoteUid;
      });
    },
    onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
      setState(() {
        _remoteUid = null;
      });
    },
  ));
}

  void _toggleVideo() {
  setState(() {
    _isVideoMuted = !_isVideoMuted;
  });
  _engine.muteLocalVideoStream(_isVideoMuted);

  // ✅ Pause video stream properly
  _engine.enableLocalVideo(!_isVideoMuted);
}


  void _toggleMute() {
    setState(() {
      _isMicMuted = !_isMicMuted;
    });
    _engine.muteLocalAudioStream(_isMicMuted);
  }

  void _endCall() async {
    await _engine.leaveChannel();
    Navigator.pop(context);
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        // ✅ Show remote user video if available
        _remoteUid != null
            ? AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: _engine,
                  canvas: VideoCanvas(uid: _remoteUid!),
                  connection: RtcConnection(channelId: widget.channelId),
                ),
              )
            : const Center(child: Text("Waiting for user...")),

        // ✅ Local preview video in bottom-right corner
        Positioned(
          bottom: 70,
          right: 20,
          width: 100,
          height: 150,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AgoraVideoView(
              controller: VideoViewController(
                rtcEngine: _engine,
                canvas: const VideoCanvas(uid: 0), // ✅ Show local video
              ),
            ),
          ),
        ),

        // Call Controls
        Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(_isMicMuted ? Icons.mic_off : Icons.mic, color: Colors.blue),
                onPressed: _toggleMute,
              ),
              IconButton(
                icon: Icon(_isVideoMuted ? Icons.videocam_off : Icons.videocam, color: Colors.green),
                onPressed: _toggleVideo,
              ),
              IconButton(
                icon: const Icon(Icons.call_end, color: Colors.red),
                onPressed: _endCall,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}
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

    await _engine.initialize(
      const RtcEngineContext(appId: "6900741fa0f04513af9befbd65522483"),
    );

    await _engine.enableVideo();
    await _engine.startPreview();
    await _engine.setChannelProfile(ChannelProfileType.channelProfileCommunication);

    await _engine.joinChannel(
      token: "007eJxTYBBYd2XF+5K72b/OREou+8dcPPHG/zv7j+YvepP8OGi2adYLBQYzSwMDcxPDtESDNAMTU0PjxDTLpNS0pBQzU1MjIxML4zsTP6c3BDIyrCwtYWZkYGRgAWIQnwlMMoNJFjDJwRCSmJPtmlhcycAAANupJ/4=",
      channelId: widget.channelId,
      uid: 0,
      options: const ChannelMediaOptions(
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
      ),
    );

    _engine.registerEventHandler(
      RtcEngineEventHandler(
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
      ),
    );
  }

  void _toggleVideo() {
    setState(() {
      _isVideoMuted = !_isVideoMuted;
    });
    _engine.muteLocalVideoStream(_isVideoMuted);
    _engine.enableLocalVideo(!_isVideoMuted);
  }

  void _toggleMute() {
    setState(() {
      _isMicMuted = !_isMicMuted;
    });
    _engine.muteLocalAudioStream(_isMicMuted);
  }

  void _switchCamera() {
    _engine.switchCamera();
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
          // Remote video
          _remoteUid != null
              ? AgoraVideoView(
                  controller: VideoViewController.remote(
                    rtcEngine: _engine,
                    canvas: VideoCanvas(uid: _remoteUid!),
                    connection: RtcConnection(channelId: widget.channelId),
                  ),
                )
              : const Center(child: Text("Waiting for user...")),

          // Local preview
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
                  canvas: const VideoCanvas(uid: 0),
                ),
              ),
            ),
          ),

          // Call Controls
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
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
                    icon: const Icon(Icons.cameraswitch, color: Colors.orange),
                    onPressed: _switchCamera,
                  ),
                  IconButton(
                    icon: const Icon(Icons.call_end, color: Colors.red),
                    onPressed: _endCall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

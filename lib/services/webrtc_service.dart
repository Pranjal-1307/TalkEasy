/*import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WebRTCService {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String channelId;
  final Function(MediaStream stream)? onAddRemoteStream;
  final Function()? onCallEnded;

  WebRTCService({required this.channelId, this.onAddRemoteStream, this.onCallEnded});

  /// **Initialize WebRTC for Audio Calls**
  Future<void> init({bool isAudioOnly = true}) async {
    // ✅ Get microphone access
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': false,
    });

    // ✅ Create peer connection with STUN servers
    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'}, // ✅ Google's STUN server
      ],
    });

    // ✅ Add local audio track
    for (var track in _localStream!.getAudioTracks()) {
      _peerConnection!.addTrack(track, _localStream!);
    }

    // ✅ Listen for ICE candidates
    _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      _firestore
          .collection('calls')
          .doc(channelId)
          .collection('candidates')
          .add(candidate.toMap());
    };

    // ✅ Listen for remote track
    _peerConnection?.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams.first;
        onAddRemoteStream?.call(_remoteStream!);
      }
    };

    _listenForRemoteDescription();
    _listenForICECandidates();
    _listenForCallEnd();
  }

  /// **Create Offer (Caller)**
  Future<void> createOffer() async {
    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    await _firestore.collection('calls').doc(channelId).set({
      'offer': offer.toMap(),
      'status': 'active', // ✅ Call is active
    });
  }

  /// **Listen for Offer (Receiver) & Create Answer**
  Future<void> _listenForRemoteDescription() async {
    _firestore.collection('calls').doc(channelId).snapshots().listen((snapshot) async {
      if (snapshot.exists && snapshot.data()?['offer'] != null) {
        RTCSessionDescription remoteOffer = RTCSessionDescription(
          snapshot.data()?['offer']['sdp'],
          snapshot.data()?['offer']['type'],
        );
        await _peerConnection?.setRemoteDescription(remoteOffer);
        await createAnswer();
      }
    });
  }

  /// **Create Answer (Receiver)**
  Future<void> createAnswer() async {
    RTCSessionDescription answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    await _firestore.collection('calls').doc(channelId).update({
      'answer': answer.toMap(),
    });
  }

  /// **Listen for ICE Candidates from Remote Peer**
  Future<void> _listenForICECandidates() async {
    _firestore
        .collection('calls')
        .doc(channelId)
        .collection('candidates')
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        var candidate = RTCIceCandidate(
          doc['candidate'],
          doc['sdpMid'],
          doc['sdpMLineIndex'],
        );
        _peerConnection?.addCandidate(candidate);
      }
    });
  }

  /// **Listen for Call End & Disconnect**
  void _listenForCallEnd() {
    _firestore.collection('calls').doc(channelId).snapshots().listen((snapshot) {
      if (snapshot.exists && snapshot.data()?['status'] == 'ended') {
        onCallEnded?.call();
        endCall();
      }
    });
  }

  /// **End Call for Both Users**
  Future<void> endCall() async {
    await _peerConnection?.close();
    await _firestore.collection('calls').doc(channelId).update({
      'status': 'ended', // ✅ Notify Firestore
    });
    onCallEnded?.call();
  }

  /// **Toggle Speakerphone**
  void setSpeakerphoneOn(bool isOn) {
    for (var track in _localStream!.getAudioTracks()) {
      track.enabled = isOn;
    }
  }

  MediaStream? getLocalStream() => _localStream;
}
*/
/*--------------------------------------------------------------------------------------------------------------------*/
/*
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WebRTCService {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String channelId;
  final Function(MediaStream stream)? onAddRemoteStream;
  final Function()? onCallEnded;

  WebRTCService({required this.channelId, this.onAddRemoteStream, this.onCallEnded});

  /// **Initialize WebRTC for Audio Calls**
  Future<void> init({bool isAudioOnly = true}) async {
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': false,
    });

    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'}, // Google's STUN server
      ],
    });

    for (var track in _localStream!.getAudioTracks()) {
      _peerConnection!.addTrack(track, _localStream!);
    }

    // **✅ Log ICE Candidates**
    _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      print("🔵 Sending ICE Candidate: ${candidate.toMap()}");
      _firestore.collection('calls').doc(channelId).collection('candidates').add(candidate.toMap());
    };

    // **✅ Listen for Remote Track**
    _peerConnection?.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams.first;
        print("✅ Remote stream received!");
        onAddRemoteStream?.call(_remoteStream!);
      }
    };

    // **✅ Debug WebRTC Connection State**
    _peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      print("🟡 Connection State Changed: $state");
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        print("✅ WebRTC Call Connected!");
      }
    };

    _listenForRemoteDescription();
    _listenForICECandidates();
    _listenForCallEnd();
  }

  /// **Create Offer (Caller)**
  Future<void> createOffer() async {
    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    await _firestore.collection('calls').doc(channelId).set({
      'offer': offer.toMap(),
      'status': 'active', 
    });

    print("📞 Offer created and sent!");
  }

  /// **Listen for Offer & Create Answer**
  Future<void> _listenForRemoteDescription() async {
    _firestore.collection('calls').doc(channelId).snapshots().listen((snapshot) async {
      if (snapshot.exists && snapshot.data()?['offer'] != null) {
        RTCSessionDescription remoteOffer = RTCSessionDescription(
          snapshot.data()?['offer']['sdp'],
          snapshot.data()?['offer']['type'],
        );
        print("🔵 Setting Remote Description: ${remoteOffer.toMap()}");
        await _peerConnection?.setRemoteDescription(remoteOffer);
        await createAnswer();
      }
    });
  }

  /// **Create Answer (Receiver)**
  Future<void> createAnswer() async {
    RTCSessionDescription answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    await _firestore.collection('calls').doc(channelId).update({
      'answer': answer.toMap(),
    });

    print("✅ Answer created and sent!");
  }

  /// **Listen for ICE Candidates**
  Future<void> _listenForICECandidates() async {
    _firestore
        .collection('calls')
        .doc(channelId)
        .collection('candidates')
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        print("🟢 Received ICE Candidate: ${doc.data()}");
        var candidate = RTCIceCandidate(
          doc['candidate'],
          doc['sdpMid'],
          doc['sdpMLineIndex'],
        );
        _peerConnection?.addCandidate(candidate);
      }
    });
  }

  /// **Listen for Call End**
  void _listenForCallEnd() {
    _firestore.collection('calls').doc(channelId).snapshots().listen((snapshot) {
      if (snapshot.exists && snapshot.data()?['status'] == 'ended') {
        print("🚨 Call ended by other user!");
        onCallEnded?.call();
        endCall();
      }
    });
  }

  /// **End Call**
  Future<void> endCall() async {
    await _peerConnection?.close();
    await _firestore.collection('calls').doc(channelId).update({
      'status': 'ended',
    });
    onCallEnded?.call();
  }

  /// **Toggle Speakerphone**
  void setSpeakerphoneOn(bool isOn) {
    for (var track in _localStream!.getAudioTracks()) {
      track.enabled = isOn;
    }
  }

  MediaStream? getLocalStream() => _localStream;
}
*/
/*import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talk_easy/screens/homescreen.dart';
import 'package:talk_easy/screens/loginscreen.dart';
import 'package:talk_easy/screens/registerscreen.dart';
import 'package:talk_easy/screens/settings.dart';

// **Theme Provider**
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  void toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    notifyListeners();
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Talk Easy',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: _getInitialScreen(context, themeProvider),
      routes: {
        "/login": (context) => const LoginScreen(),
        "/signup": (context) => const RegisterScreen(),
        "/home": (context) => Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return HomeScreen(
                  onThemeToggle: (bool isDark) => themeProvider.toggleTheme(isDark),
                  isDarkMode: themeProvider.isDarkMode,
                );
              },
            ),
        "/settings": (context) => const SettingsScreen(),
      },
    );
  }

  /// **Determine the initial screen based on authentication state**
  Widget _getInitialScreen(BuildContext context, ThemeProvider themeProvider) {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null
        ? HomeScreen(
            onThemeToggle: (bool isDark) => themeProvider.toggleTheme(isDark),
            isDarkMode: themeProvider.isDarkMode,
          )
        : const LoginScreen();
  }
}*/
/*----------------------------------------------------------------------------------------------------------------------*/
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:talk_easy/screens/homescreen.dart';
import 'package:talk_easy/screens/loginscreen.dart';
import 'package:talk_easy/screens/registerscreen.dart';
import 'package:talk_easy/screens/settings.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

/// **Theme Provider**
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  void toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    notifyListeners();
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late RtcEngine agoraEngine;
  final String appId = "7e56aee6e92a4993ab2d792666e14076"; // 🔥 Your Agora App ID
  final String token = "007eJxTYNhx7hb3/dl2B6epBSyO6jW9Kc2xKd7i9UNZq9g33iJKWu8UGMxTTc0SU1PNUi2NEk0sLY0Tk4xSzC2NzMzMUg1NDMzN/i96m94QyMjAZraFiZEBAkF8DoaQxJxs18TiSgYGALhJIGU="; // 🔥 Replace with a valid token
  final String channelName = "TalkEasy";
  bool isMicMuted = false;
  bool isSpeakerOn = true;

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  /// **Initialize Agora for Audio Call**
  Future<void> _initAgora() async {
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(
      RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication, // ✅ Optimized for voice calls
      ),
    );

    await agoraEngine.enableAudio();
    await agoraEngine.setAudioProfile(
      profile: AudioProfileType.audioProfileSpeechStandard,  // ✅ Best for clear speech
      scenario: AudioScenarioType.audioScenarioGameStreaming,  // ✅ Reduces background noise
    );

    await agoraEngine.setDefaultAudioRouteToSpeakerphone(true); // ✅ Ensure audio plays on speaker
    await agoraEngine.setClientRole(role: ClientRoleType.clientRoleBroadcaster); // ✅ Both users are broadcasters
  }

  /// **Join an Audio Call**
  Future<void> _joinCall() async {
    await agoraEngine.joinChannel(
      token: token,
      channelId: channelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  /// **Leave the Audio Call**
  Future<void> _leaveCall() async {
    await agoraEngine.leaveChannel();
  }

  /// **Mute/Unmute Microphone**
  void _toggleMute() async {
    setState(() {
      isMicMuted = !isMicMuted;
    });
    await agoraEngine.muteLocalAudioStream(isMicMuted);
  }

  /// **Toggle Speaker (ON/OFF)**
  void _toggleSpeaker() async {
    setState(() {
      isSpeakerOn = !isSpeakerOn;
    });
    await agoraEngine.setEnableSpeakerphone(isSpeakerOn);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Talk Easy',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: _getInitialScreen(context, themeProvider),
      routes: {
        "/login": (context) => const LoginScreen(),
        "/signup": (context) => const RegisterScreen(),
        "/home": (context) => Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return HomeScreen(
                  onThemeToggle: (bool isDark) => themeProvider.toggleTheme(isDark),
                  isDarkMode: themeProvider.isDarkMode,
                );
              },
            ),
        "/settings": (context) => const SettingsScreen(),
        "/audioCall": (context) => AudioCallScreen(
              joinCall: _joinCall,
              leaveCall: _leaveCall,
              toggleMute: _toggleMute,
              toggleSpeaker: _toggleSpeaker,
              isMicMuted: isMicMuted,
              isSpeakerOn: isSpeakerOn,
            ),
      },
    );
  }

  /// **Determine the initial screen based on authentication state**
  Widget _getInitialScreen(BuildContext context, ThemeProvider themeProvider) {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null
        ? HomeScreen(
            onThemeToggle: (bool isDark) => themeProvider.toggleTheme(isDark),
            isDarkMode: themeProvider.isDarkMode,
          )
        : const LoginScreen();
  }
}

/// **Audio Call Screen**
class AudioCallScreen extends StatelessWidget {
  final VoidCallback joinCall;
  final VoidCallback leaveCall;
  final VoidCallback toggleMute;
  final VoidCallback toggleSpeaker;
  final bool isMicMuted;
  final bool isSpeakerOn;

  const AudioCallScreen({
    Key? key,
    required this.joinCall,
    required this.leaveCall,
    required this.toggleMute,
    required this.toggleSpeaker,
    required this.isMicMuted,
    required this.isSpeakerOn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Audio Call")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mic,
              size: 100,
              color: isMicMuted ? Colors.red : Colors.green,
            ),
            const SizedBox(height: 20),
            Text(
              "Audio Call Active",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(isMicMuted ? Icons.mic_off : Icons.mic),
                  color: isMicMuted ? Colors.red : Colors.blue,
                  onPressed: toggleMute,
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: Icon(isSpeakerOn ? Icons.volume_up : Icons.volume_down),
                  color: isSpeakerOn ? Colors.green : Colors.grey,
                  onPressed: toggleSpeaker,
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.call_end, color: Colors.red),
                  onPressed: leaveCall,
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: joinCall,
              child: const Text("Join Call"),
            ),
          ],
        ),
      ),
    );
  }
}

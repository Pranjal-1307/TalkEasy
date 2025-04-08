/*import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:talk_easy/screens/registerscreen.dart';
import 'loginscreen.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text(
              'Sign In',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: IntroductionScreen(
        pages: [
          PageViewModel(
            title: 'Welcome to Talk Easy',
            body: 'A simple way to communicate with ease.',
          ),
          PageViewModel(
            title: 'Stay Connected',
            body: 'Chat with friends and family anytime.',
          ),
          PageViewModel(
            title: 'Secure Conversations',
            body: 'Your messages are safe and private.',
          ),
          PageViewModel(
            title: 'Get Started',
            body: 'Sign up now and enjoy seamless communication.',
          ),
        ],
        done: const SizedBox.shrink(), // Hide the done button
        next: const Icon(Icons.arrow_forward),
        showSkipButton: true,
        skip: const Text('Skip'),
        onDone: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const RegisterScreen()),
          );
        },
        onChange: (index) {
          if (index == 3) { // Last page index
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            );
          }
        },
      ),
    );
  }
}
*/

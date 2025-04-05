import 'package:flutter/material.dart';

class VoiceButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color color;

  VoiceButton({required this.onPressed, this.icon = Icons.mic, this.color = Colors.blue});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: color,
      child: Icon(icon, size: 30),
    );
  }
}

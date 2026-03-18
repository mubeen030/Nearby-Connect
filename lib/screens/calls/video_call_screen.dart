import 'package:flutter/material.dart';

class VideoCallScreen extends StatelessWidget {
  const VideoCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Agora video call UI should be implemented here.'),
      ),
    );
  }
}

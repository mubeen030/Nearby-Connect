import 'package:flutter/material.dart';

class VoiceCallScreen extends StatelessWidget {
  const VoiceCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Call'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Agora voice call UI should be implemented here.'),
      ),
    );
  }
}

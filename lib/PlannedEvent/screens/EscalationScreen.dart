import 'package:flutter/material.dart';

class EscalationScreen extends StatelessWidget {
  final String accessToken;
  const EscalationScreen({super.key, required this.accessToken});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escalations')),
      body: const Center(
          child: Text(
              'Escalations - token length: "+accessToken.length.toString()+"')),
    );
  }
}

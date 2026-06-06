import 'package:flutter/material.dart';

class SystemUsersScreen extends StatelessWidget {
  final int userId;
  const SystemUsersScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('System Users')),
      body: Center(child: Text('System Users for user: $userId')),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import '../screens/ChatBotScreen.dart';

class DraggableChatBot extends StatefulWidget {
  final Map<String, dynamic>? user;
  const DraggableChatBot({super.key, this.user});

  @override
  State<DraggableChatBot> createState() => _DraggableChatBotState();
}

class _DraggableChatBotState extends State<DraggableChatBot> {
  Offset position = const Offset(20, 100); // Initial position from bottom-right

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Positioned(
      right: position.dx,
      bottom: position.dy,
      child: Draggable(
        feedback: _buildIcon(true),
        childWhenDragging: Container(),
        onDragEnd: (details) {
          setState(() {
            
            double newDx = size.width - details.offset.dx - 60; 
            double newDy = size.height - details.offset.dy - 60;

            position = Offset(
              newDx.clamp(20.0, size.width - 80.0),
              newDy.clamp(20.0, size.height - 100.0),
            );
          });
        },
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatBotScreen(user: widget.user),
              ),
            );
          },
          child: _buildIcon(false),
        ),
      ),
    );
  }

  Widget _buildIcon(bool isDragging) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDragging ? 0.3 : 0.2),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.file(
            File("C:\\Users\\HP\\.gemini\\antigravity\\brain\\da1ddb08-8bd3-423b-baca-725bbca80bc5\\chatbot_icon_1777963543548.png"),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.smart_toy, color: Color.fromARGB(255, 7, 69, 156), size: 30);
            },
          ),
        ),
      ),
    );
  }
}

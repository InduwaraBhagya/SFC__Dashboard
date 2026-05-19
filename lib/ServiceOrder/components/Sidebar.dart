import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/ChatBotScreen.dart';
import '../screens/ProfileScreen.dart';
import '../../PlannedEvent/service/AuthService.dart';
import '../../OnboardingScreen.dart';
import 'dart:convert';

class AppSidebar extends StatelessWidget {
  final Map<String, dynamic> user;
  final int currentIndex;
  final Function(int) onItemSelected;

  const AppSidebar({
    super.key,
    required this.user,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          _buildUserHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildMenuItem(0, Icons.speed, 'Dashboard', const Color(0xFF6C5CE7), context),
                
                _buildSectionHeader('RECORDS MANAGEMENT'),
                _buildMenuItem(1, Icons.check_circle_outline, 'Regular Records', const Color(0xFF4DB6AC), context),
                _buildMenuItem(2, Icons.warning_amber_rounded, 'Urgent Records', const Color(0xFFEC7063), context),
                _buildMenuItem(3, Icons.pause_circle_outline, 'Hold Records', const Color(0xFF5DADE2), context),
                _buildMenuItem(4, Icons.error_outline, 'OLA Violated', const Color(0xFFE91E63), context),
                _buildMenuItem(5, Icons.hourglass_empty, 'Dormant', const Color(0xFF95A5A6), context),

                _buildSectionHeader('PROJECT MANAGEMENT'),
                _buildMenuItem(6, Icons.folder_open, 'Projects', const Color(0xFFEB984E), context),

                _buildSectionHeader('ADMINISTRATION'),
                _buildMenuItem(14, Icons.group_outlined, 'Work Groups', const Color(0xFFE67E22), context),
                
                _buildSectionHeader('SUPPORT'),
                _buildChatBotItem(context),

                _buildSectionHeader('OTHER'),
                _buildThemeToggle(context),
                _buildUserTile(context),
                _buildSignOutTile(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen(user: user)),
        );
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF07459C),
              child: user['PhotoBase64'] != null && user['PhotoBase64'].isNotEmpty
                  ? ClipOval(
                      child: Image.memory(
                        base64Decode(user['PhotoBase64']),
                        fit: BoxFit.cover,
                        width: 48,
                        height: 48,
                      ),
                    )
                  : const Icon(Icons.person, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['Name'] ?? 'Guest User',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                  Text(
                    user['ServiceId'] ?? 'SVC000',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String title, Color color, BuildContext context) {
    final bool isSelected = currentIndex == index;
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: () {
          onItemSelected(index);
          Navigator.pop(context); // Close drawer
        },
        dense: true,
        visualDensity: const VisualDensity(vertical: -2),
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? color : const Color(0xFF444444),
          ),
        ),
        trailing: isSelected 
            ? Container(
                width: 4, 
                height: 20, 
                decoration: BoxDecoration(
                  color: color, 
                  borderRadius: BorderRadius.circular(4)
                )
              ) 
            : null,
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    return ListTile(
      dense: true,
      leading: const Icon(Icons.dark_mode_outlined, size: 22, color: Colors.grey),
      title: Text('Dark Mode', style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF444444))),
      trailing: Switch(
        value: false,
        onChanged: (val) {},
        activeColor: Colors.purple,
      ),
    );
  }

  Widget _buildUserTile(BuildContext context) {
    return ListTile(
      dense: true,
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen(user: user)),
        );
      },
      leading: const CircleAvatar(
        radius: 12,
        backgroundColor: Color(0xFFE8EAF6),
        child: Icon(Icons.person, size: 16, color: Color(0xFF07459C)),
      ),
      title: Text(user['Name'] ?? 'Administrator', 
        style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF444444), fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildSignOutTile(BuildContext context) {
    return ListTile(
      dense: true,
      onTap: () async {
        await AuthService().logout();
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
            (route) => false,
          );
        }
      },
      leading: const Icon(Icons.logout_rounded, size: 22, color: Colors.redAccent),
      title: Text('Sign Out', style: GoogleFonts.poppins(fontSize: 13, color: Colors.redAccent, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildChatBotItem(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: () {
          Navigator.pop(context); // Close drawer
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatBotScreen(user: user),
            ),
          );
        },
        dense: true,
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.smart_toy, color: Colors.blue, size: 20),
        ),
        title: Text(
          'SOMS AI Assistant',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF444444),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WorkgroupReportScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onBack;

  const WorkgroupReportScreen({
    super.key,
    required this.user,
    required this.onBack,
  });

  bool _isSupervisor() {
    // Check for Role 2 (Supervisor)
    // Based on the screenshot and project context, Role 2 is the required level.
    final userRoleId = user['UserRoleId'];
    final userRole = user['UserRole'];
    
    // Check both ID and Name to be safe
    return userRoleId == 2 || userRole == 'Supervisor';
  }

  @override
  Widget build(BuildContext context) {
    if (_isSupervisor()) {
      return _buildReportContent(context);
    } else {
      return _buildAccessDenied(context);
    }
  }

  Widget _buildAccessDenied(BuildContext context) {
    return Scaffold(
      
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Access Denied Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: const BoxDecoration(
                  color: Color(0xFFD9534F), // Red banner
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Theme.of(context).cardColor, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Access Denied',
                      style: GoogleFonts.poppins(
                        color: Theme.of(context).cardColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Main Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Shield Icon
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.security,
                          size: 80,
                          color: const Color(0xFFD9534F).withOpacity(0.1),
                        ),
                        const Icon(
                          Icons.close,
                          size: 30,
                          color: Color(0xFFD9534F),
                        ),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFD9534F),
                              width: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Title
                    Text(
                      'Workgroup Progress Report',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Message
                    Text(
                      'This report is only available to workgroup supervisors (Role 2).',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF34495E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "You don't have the necessary permissions to view this page.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Back to Home Button
                    SizedBox(
                      width: 160,
                      child: ElevatedButton(
                        onPressed: onBack,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF07459C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.arrow_back, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Back to Home',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Workgroup Progress Report',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.analytics_outlined, size: 80, color: Color(0xFF1A237E)),
            const SizedBox(height: 16),
            Text(
              'Report Data Coming Soon',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'As a Supervisor, you will be able to see\nworkgroup progress metrics here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}


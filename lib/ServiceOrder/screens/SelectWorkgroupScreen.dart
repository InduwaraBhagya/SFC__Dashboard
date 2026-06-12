import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../OnboardingScreen.dart';
import '../ServiceOrderMain.dart';
import '../../PlannedEvent/service/AuthService.dart' as auth;
import '../../PlannedEvent/model/WorkGroup.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SelectWorkgroupScreen extends StatefulWidget {
  final OnboardingDestination destination;

  const SelectWorkgroupScreen({
    super.key,
    this.destination = OnboardingDestination.serviceOrder,
  });

  @override
  _SelectWorkgroupScreenState createState() => _SelectWorkgroupScreenState();
}

class _SelectWorkgroupScreenState extends State<SelectWorkgroupScreen> {
  final auth.AuthService _authService = auth.AuthService();
  List<WorkGroup> _workGroups = [];
  WorkGroup? _selectedWorkGroup;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchWorkGroups();
  }

  Future<void> _fetchWorkGroups() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final workgroups = await _authService.getSomsWorkGroups();
      setState(() {
        _workGroups = workgroups;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load workgroups: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _onProceed() async {
    if (_selectedWorkGroup == null) return;
   
    const storage = FlutterSecureStorage();
    await storage.write(key: 'soms_selected_workgroup_id', value: _selectedWorkGroup!.id.toString());
    await storage.write(key: 'soms_selected_workgroup_name', value: _selectedWorkGroup!.name);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const ServiceOrderMain(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Soft modern background
      appBar: AppBar(
        title: Text('Select Workgroup', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: const Color.fromARGB(255, 16, 37, 89),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color.fromARGB(255, 16, 37, 89)))
          : _errorMessage != null
              ? _buildErrorState()
              : _buildMainContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchWorkGroups,
              icon: const Icon(Icons.refresh),
              label: Text('Retry', style: GoogleFonts.poppins()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 16, 37, 89),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          children: [
            // Header Image/Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.hub_outlined,
                size: 80,
                color: Color.fromARGB(255, 16, 37, 89),
              ),
            ),
            const SizedBox(height: 40),
            
            // Title & Description
            Text(
              'Welcome!',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 16, 37, 89),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please select your Workgroup to continue processing Service Orders.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Selection Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Workgroup',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField2<WorkGroup>(
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color.fromARGB(255, 16, 37, 89), width: 2),
                      ),
                    ),
                    isExpanded: true,
                    hint: Text('Choose a workgroup', style: GoogleFonts.poppins(color: Colors.grey[400])),
                    items: _workGroups
                        .map((wg) => DropdownMenuItem<WorkGroup>(
                              value: wg,
                              child: Text(
                                wg.name, 
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ))
                        .toList(),
                    value: _selectedWorkGroup,
                    onChanged: (value) {
                      setState(() {
                        _selectedWorkGroup = value;
                      });
                    },
                    buttonStyleData: const ButtonStyleData(
                      height: 55,
                      padding: EdgeInsets.only(right: 16),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      offset: const Offset(0, -5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Proceed Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedWorkGroup == null ? null : _onProceed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 16, 37, 89),
                  disabledBackgroundColor: Colors.grey[300],
                  foregroundColor: Colors.white,
                  elevation: _selectedWorkGroup == null ? 0 : 5,
                  shadowColor: const Color.fromARGB(255, 16, 37, 89).withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Proceed', 
                      style: GoogleFonts.poppins(
                        fontSize: 18, 
                        fontWeight: FontWeight.w600,
                        color: _selectedWorkGroup == null ? Colors.grey[500] : Colors.white,
                      ),
                    ),
                    if (_selectedWorkGroup != null) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

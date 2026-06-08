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
    
    // Save selected workgroup securely for the dashboard to read
    const storage = FlutterSecureStorage();
    await storage.write(key: 'soms_selected_workgroup_id', value: _selectedWorkGroup!.id.toString());
    await storage.write(key: 'soms_selected_workgroup_name', value: _selectedWorkGroup!.name);

    // Redirect to ServiceOrderMain after selection
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
      appBar: AppBar(
        title: const Text('Select Workgroup'),
        backgroundColor: const Color.fromARGB(226, 16, 37, 89),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchWorkGroups,
                          child: const Text('Retry'),
                        )
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Text(
                          'Please select your Workgroup for processing Service Orders',
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DropdownButtonFormField2<WorkGroup>(
                              decoration: const InputDecoration(
                                labelText: 'Select Workgroup',
                                border: OutlineInputBorder(),
                              ),
                              isExpanded: true,
                              hint: const Text('Choose a workgroup'),
                              items: _workGroups
                                  .map((wg) => DropdownMenuItem<WorkGroup>(
                                        value: wg,
                                        child: Text(wg.name, style: GoogleFonts.poppins()),
                                      ))
                                  .toList(),
                              value: _selectedWorkGroup,
                              onChanged: (value) {
                                setState(() {
                                  _selectedWorkGroup = value;
                                });
                              },
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _selectedWorkGroup == null ? null : () => _onProceed(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(226, 16, 37, 89),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text('Proceed', style: GoogleFonts.poppins(fontSize: 16)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

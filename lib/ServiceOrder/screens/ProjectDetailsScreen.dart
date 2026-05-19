import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../service/ProjectService.dart';
import 'ServiceOrderDetailScreen.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final int projectId;
  final String projectName;
  final VoidCallback onBack;

  const ProjectDetailsScreen({
    super.key,
    required this.projectId,
    required this.projectName,
    required this.onBack,
  });

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  final ProjectService _projectService = ProjectService();
  bool _isLoading = true;
  bool _isSearching = false;
  Map<String, dynamic>? _projectDetails;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadProjectDetails();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty) {
        _performSearch(_searchController.text);
      } else {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isSearching = true);
    try {
      final results = await _projectService.searchServiceOrders(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _addSOToProject(int plannedEventId) async {
    final success = await _projectService.addSOToProject(widget.projectId, plannedEventId);
    if (success) {
      _searchController.clear();
      setState(() => _searchResults = []);
      _loadProjectDetails();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SO added to project successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add SO to project')),
      );
    }
  }

  Future<void> _loadProjectDetails() async {
    setState(() => _isLoading = true);
    try {
      final details = await _projectService.fetchProjectDetails(widget.projectId);
      setState(() {
        _projectDetails = details;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Project details load failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load project details: $e')),
      );
    }
  }

  void _loadMockData() {
    setState(() {
      _projectDetails = {
        'id': widget.projectId,
        'projectName': widget.projectName,
        'createdDate': '2025-10-31T10:00:00',
        'projectPEs': [
          {
            'id': 1,
            'plannedEvent': {
              'soId': 'BIA202410180037889',
              'customer': 'Tata Communications Lanka Limited',
              'woStartDate': null,
              'pendingTaskName': null,
            },
            'currentTask': null,
          },
          {
            'id': 2,
            'plannedEvent': {
              'soId': 'CEN20241223081818',
              'customer': 'Tata Communications Lanka Limited',
              'woStartDate': null,
              'pendingTaskName': null,
            },
            'currentTask': null,
          },
          {
            'id': 3,
            'plannedEvent': {
              'soId': 'CEN202504030023035',
              'customer': 'Tata Communications Lanka Limited',
              'woStartDate': null,
              'pendingTaskName': null,
            },
            'currentTask': null,
          },
          {
            'id': 4,
            'plannedEvent': {
              'soId': 'CEN20250410079342',
              'customer': 'Tata Communications Lanka Limited',
              'woStartDate': null,
              'pendingTaskName': null,
            },
            'currentTask': null,
          },
        ]
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        elevation: 0,
        
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1A237E), size: 20),
          onPressed: widget.onBack,
        ),
        title: Text(
          widget.projectName,
          style: GoogleFonts.poppins(
            color: const Color(0xFF1A237E),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Back to Projects'),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A237E)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildAddSOStep(),
                  const SizedBox(height: 24),
                  _buildAssignedSOsList(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    String createdDate = 'Unknown';
    if (_projectDetails?['createdDate'] != null) {
      try {
        DateTime dt = DateTime.parse(_projectDetails!['createdDate']);
        createdDate = DateFormat('MMM dd, yyyy').format(dt);
      } catch (_) {}
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _projectDetails?['projectName'] ?? widget.projectName,
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
        Text(
          'Created on $createdDate',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildAddSOStep() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add SOs to Project',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: const Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search SO by ID or customer...',
                border: InputBorder.none,
                icon: const Icon(Icons.search, color: Colors.grey, size: 20),
                suffixIcon: _isSearching 
                  ? const SizedBox(width: 20, height: 20, child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2))) 
                  : null,
              ),
            ),
          ),
          if (_searchResults.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final so = _searchResults[index];
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(so['soId'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(so['customer'] ?? 'Unknown Customer', maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: ElevatedButton(
                      onPressed: () => _addSOToProject(so['id']),
                      style: ElevatedButton.styleFrom(
                        
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: const Size(60, 30),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: Text('Add', style: TextStyle(color: Theme.of(context).cardColor, fontSize: 11)),
                    ),
                  );
                },
              ),
            ),
          ] else if (_searchController.text.isNotEmpty && !_isSearching) ...[
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text('No matching SOs found', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAssignedSOsList() {
    final List<dynamic> pes = _projectDetails?['projectPEs'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assigned SOs',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: const Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 12),
        if (pes.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Text('No SOs assigned to this project', style: GoogleFonts.poppins(color: Colors.grey)),
            ),
          )
        else
          ...pes.map((pe) => _buildSOCard(pe)).toList(),
      ],
    );
  }

  Widget _buildSOCard(dynamic pe) {
    final plannedEvent = pe['plannedEvent'];
    final String soId = plannedEvent['soId'] ?? 'N/A';
    final String customer = plannedEvent['customer'] ?? 'Unknown Customer';
    final String? woStartDate = plannedEvent['woStartDate'];
    final String currentTask = pe['currentTask'] ?? 'No Active Task';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      soId,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2196F3),
                        fontSize: 14,
                      ),
                    ),
                    _buildBadge('0%', Colors.grey),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  customer,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoItem('Start Date', woStartDate ?? '-'),
                    _buildInfoItem('Current Task', currentTask, isTask: true),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServiceOrderDetailScreen(pe: plannedEvent),
                      ),
                    );
                  },
                  icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                  label: const Text('View Details'),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF2196F3)),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Remove'),
                  style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, {bool isTask = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 4),
        if (isTask)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
            ),
          )
        else
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF2C3E50)),
          ),
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/WorkGroupModel.dart';
import '../service/WorkGroupService.dart';
import 'AddEditWorkGroupScreen.dart';

class WorkGroupScreen extends StatefulWidget {
  const WorkGroupScreen({super.key});

  @override
  _WorkGroupScreenState createState() => _WorkGroupScreenState();
}

class _WorkGroupScreenState extends State<WorkGroupScreen> {
  final WorkGroupService _service = WorkGroupService();
  late Future<List<WorkGroupDetails>> _workGroupsFuture;
  List<WorkGroupDetails> _workGroups = [];
  List<WorkGroupDetails> _filteredWorkGroups = [];
  String? _errorMessage;
  final int _recordsPerPage = 10;
  late PageController _pageController;
  int _currentPage = 0;
  final bool _isSearchBarExpanded = false; 

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _workGroupsFuture = _service.fetchWorkGroups().catchError((e) {
      print('Error in initState: $e');
      setState(() {
        _errorMessage = 'Failed to load work groups: $e';
      });
      return <WorkGroupDetails>[];
    });
    _workGroupsFuture.then((data) {
      setState(() {
        _workGroups = data;
        _filteredWorkGroups = data;
        _errorMessage = null;
      });
    }).catchError((e) {
      setState(() {
        _errorMessage = 'Failed to process work groups: $e';
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _filterWorkGroups(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredWorkGroups = _workGroups;
      } else {
        _filteredWorkGroups = _workGroups.where((workGroup) {
          final name = workGroup.workGroupName?.toLowerCase() ?? '';
          final id = workGroup.workGroupId?.toString() ?? '';
          return name.contains(query.toLowerCase()) || id.contains(query);
        }).toList();
      }
      _currentPage = 0;
      _pageController.jumpToPage(0);
    });
  }

  void _refreshWorkGroups() {
    setState(() {
      _workGroupsFuture = _service.fetchWorkGroups().catchError((e) {
        setState(() {
          _errorMessage = 'Failed to load work groups: $e';
        });
        return <WorkGroupDetails>[];
      });
      _workGroupsFuture.then((data) {
        setState(() {
          _workGroups = data;
          _filteredWorkGroups = data;
          _errorMessage = null;
        });
      });
    });
  }

  Future<void> _deleteWorkGroup(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this workgroup?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _service.deleteWorkGroup(id);
      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Workgroup deleted successfully'),
              backgroundColor: Colors.green),
        );
        _refreshWorkGroups();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to delete workgroup'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalPages =
        (_filteredWorkGroups.length / _recordsPerPage).ceil();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Workgroup Management',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage workgroups',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const AddEditWorkGroupScreen()),
                      );
                      if (result == true) {
                        _refreshWorkGroups();
                      }
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(
                      'Create New Workgroup',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 7, 69, 156),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              TextField(
                onChanged: _filterWorkGroups,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search workgroups...',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF1D4ED8)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.group, size: 16, color: Color(0xFF4B5563)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'WG_Name',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF374151),
                        ),
                      ),
                    ),
                    Text(
                      'Actions',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: FutureBuilder<List<WorkGroupDetails>>(
                  future: _workGroupsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (_errorMessage != null) {
                      return Center(child: Text(_errorMessage!));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No work groups found'));
                    }

                    final startIndex = _currentPage * _recordsPerPage;
                    final endIndex = (startIndex + _recordsPerPage)
                        .clamp(0, _filteredWorkGroups.length);
                    final pageRecords =
                        _filteredWorkGroups.sublist(startIndex, endIndex);

                    return Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            itemCount: pageRecords.length,
                            separatorBuilder: (context, index) => Divider(
                              color: Colors.grey.shade200,
                              height: 1,
                            ),
                            itemBuilder: (context, index) {
                              final workGroup = pageRecords[index];
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${workGroup.workGroupName}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: const Color(0xFF111827),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Edit Button
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 2),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.blue.shade200),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: InkWell(
                                            onTap: () async {
                                              final result =
                                                  await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        AddEditWorkGroupScreen(
                                                            workGroup:
                                                                workGroup)),
                                              );
                                              if (result == true) {
                                                _refreshWorkGroups();
                                              }
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.all(4),
                                              child: Icon(Icons.edit,
                                                  size: 16, color: Colors.blue),
                                            ),
                                          ),
                                        ),

                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 2),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.red.shade200),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              if (workGroup.workGroupId !=
                                                      null &&
                                                  workGroup.workGroupId! > 0) {
                                                _deleteWorkGroup(
                                                    workGroup.workGroupId!);
                                              }
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.all(4),
                                              child: Icon(Icons.delete_outline,
                                                  size: 16, color: Colors.red),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        
                        if (totalPages > 1)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(totalPages, (index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _currentPage == index
                                            ? const Color.fromARGB(
                                                255, 7, 69, 156)
                                            : Colors.grey.shade200,
                                        foregroundColor: _currentPage == index
                                            ? Colors.white
                                            : Colors.black87,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        minimumSize: const Size(36, 36),
                                        padding: EdgeInsets.zero,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _currentPage = index;
                                        });
                                      },
                                      child: Text(
                                        '${index + 1}',
                                        style:
                                            GoogleFonts.poppins(fontSize: 12),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

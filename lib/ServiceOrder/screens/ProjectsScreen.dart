import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../service/ProjectService.dart';
import 'ProjectDetailsScreen.dart';

class ProjectsScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback onBack;

  const ProjectsScreen({super.key, required this.user, required this.onBack});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final ProjectService _projectService = ProjectService();
  bool _isLoading = true;
  List<dynamic> _projects = [];
  List<dynamic> _filteredProjects = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProjects();
    _searchController.addListener(_filterProjects);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoading = true);
    try {
      final projects = await _projectService.fetchProjects();
      setState(() {
        _projects = projects;
        _filteredProjects = projects;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Projects load failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load projects from database: $e')),
      );
    }
  }

  void _loadMockData() {
    setState(() {
      _projects = [
        {'id': 1, 'projectName': 'TATA project', 'projectPEs': List.generate(17, (i) => i)},
        {'id': 2, 'projectName': 'Mobitel Project', 'projectPEs': List.generate(292, (i) => i)},
        {'id': 3, 'projectName': 'Sampath Bank Project', 'projectPEs': List.generate(149, (i) => i)},
        {'id': 4, 'projectName': 'Dialog Project', 'projectPEs': List.generate(57, (i) => i)},
        {'id': 5, 'projectName': 'Commercial Bank Project', 'projectPEs': List.generate(201, (i) => i)},
        {'id': 6, 'projectName': 'Toyota Project', 'projectPEs': List.generate(4, (i) => i)},
        {'id': 7, 'projectName': 'SIAM CITY CEMENT (LANKA) LTD Project', 'projectPEs': List.generate(21, (i) => i)},
      ];
      _filteredProjects = _projects;
    });
  }

  void _filterProjects() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProjects = _projects.where((p) {
        return p['projectName'].toString().toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _deleteProject(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Project', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete this project?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _projectService.deleteProject(id);
      if (success) {
        _loadProjects();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Project deleted')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete project')));
      }
    }
  }

  void _showCreateProjectDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Create New Project',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project Name',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Enter project name',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                final success = await _projectService.createProject(nameController.text.trim());
                if (success) {
                  Navigator.pop(context);
                  _loadProjects();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Project created successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to create project')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 7, 69, 156),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Create Project', style: GoogleFonts.poppins(color: Theme.of(context).cardColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1A237E), size: 20),
          onPressed: widget.onBack,
        ),
        title: Text(
          'Projects',
          style: GoogleFonts.poppins(
            color: const Color(0xFF1A237E),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF1A237E)),
            onPressed: _loadProjects,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'Manage your projects and SO assignments',
              style: GoogleFonts.poppins(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          _buildTopBar(),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A237E)))
              : _filteredProjects.isEmpty
                ? _buildEmptyState()
                : _buildProjectGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search projects...',
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showCreateProjectDialog,
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              label: Text(
                'Create New Project',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 7, 69, 156),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1, // List-like on mobile but cards
        mainAxisExtent: 140,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredProjects.length,
      itemBuilder: (context, index) {
        final project = _filteredProjects[index];
        return _buildProjectCard(project);
      },
    );
  }

  Widget _buildProjectCard(dynamic project) {
    int soCount = project['projectPEs']?.length ?? 0;
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    project['projectName'] ?? 'Unknown Project',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: const Color(0xFF2C3E50),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(
                  onTap: () => _deleteProject(project['id']),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.assignment_ind_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  '$soCount SOs assigned',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProjectDetailsScreen(
                        projectId: project['id'],
                        projectName: project['projectName'] ?? 'Unknown Project',
                        onBack: () => Navigator.pop(context),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.folder_open, size: 18, color: Colors.white),
                label: Text('View Project', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 7, 69, 156),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_off_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No projects found',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}


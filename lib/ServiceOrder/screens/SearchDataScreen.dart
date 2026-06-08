import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../service/DataManagementService.dart';

class SearchDataScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const SearchDataScreen({super.key, required this.user});

  @override
  State<SearchDataScreen> createState() => _SearchDataScreenState();
}

class _SearchDataScreenState extends State<SearchDataScreen> {
  final DataManagementService _dataManagementService = DataManagementService();
  String? _selectedEntity;
  String? _selectedQuickPick;
  final TextEditingController _roleController = TextEditingController();
  
  List<String> _dbEntities = [];
  bool _isLoadingEntities = true;
  bool _isSearching = false;
  bool _showResults = false;
  List<dynamic> _searchResults = [];
  String? _searchedEntity;
  bool _isCollapsed = false;
  List<dynamic> _quickPickRecords = [];
  bool _isLoadingQuickPick = false;

  @override
  void initState() {
    super.initState();
    _loadEntities();
  }

  Future<void> _loadEntities() async {
    setState(() => _isLoadingEntities = true);
    try {
      final entities = await _dataManagementService.fetchEntities();
      setState(() {
        _dbEntities = ['-- All Entities --', ...entities.map((e) => e['name'].toString())];
        _isLoadingEntities = false;
      });
    } catch (e) {
      print('Failed to load entities: $e');
      setState(() {
        _dbEntities = ['-- All Entities --'];
        _isLoadingEntities = false;
      });
    }
  }

  @override
  void dispose() {
    _roleController.dispose();
    super.dispose();
  }

  void _search() async {
    if (_selectedEntity == null || _selectedEntity == '-- All Entities --') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a specific entity to search')),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _showResults = false;
    });

    try {
      // Clean up the entity name if it has decoration
      final entityToFetch = _selectedEntity!.replaceAll('-- ', '').replaceAll(' --', '').trim();
      
      final records = await _dataManagementService.fetchTableRecords(entityToFetch);
      
      if (mounted) {
        setState(() {
          _isSearching = false;
          _showResults = true;
          _searchedEntity = _selectedEntity;
          _searchResults = records;
          _isCollapsed = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _showResults = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch data: $e')),
        );
      }
    }
  }

  Future<void> _loadQuickPickRecords(String entityName) async {
    setState(() {
      _isLoadingQuickPick = true;
      _quickPickRecords = [];
    });
    
    try {
      final entityToFetch = entityName.replaceAll('-- ', '').replaceAll(' --', '').trim();
      final records = await _dataManagementService.fetchTableRecords(entityToFetch);
      
      if (mounted) {
        setState(() {
          _quickPickRecords = records;
          _isLoadingQuickPick = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingQuickPick = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1A237E), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Search Data',
          style: GoogleFonts.poppins(
            color: const Color(0xFF1A237E),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8, bottom: 8),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, size: 16, color: Colors.white),
              label: Text('Back', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF07459C),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
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
                border: Border.all(color: Colors.grey.shade200),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Entity', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey.shade800)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: Text('-- Select entity --', style: GoogleFonts.poppins(color: Colors.grey.shade600)),
                        value: _selectedEntity,
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedEntity = newValue;
                            _selectedQuickPick = null;
                            _quickPickRecords = [];
                          });
                          if (newValue != null && newValue != '-- All Entities --') {
                            _loadQuickPickRecords(newValue);
                            _search();
                          }
                        },
                        items: _isLoadingEntities
                            ? [DropdownMenuItem(value: null, child: Text('Loading...', style: GoogleFonts.poppins(fontSize: 14)))]
                            : _dbEntities.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade800),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Text('Quick pick', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey.shade800)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: Text('Select a value...', style: GoogleFonts.poppins(color: Colors.grey.shade600)),
                        value: _selectedQuickPick,
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedQuickPick = newValue;
                          });
                          // When a quick pick is selected, we could scroll to it or filter
                          // For now, let's just update the selection
                        },
                        items: _isLoadingQuickPick
                            ? [DropdownMenuItem(value: null, child: Text('Loading...', style: GoogleFonts.poppins(fontSize: 14)))]
                            : _quickPickRecords.map((dynamic record) {
                                final String displayName = record is Map 
                                    ? (record['displayName']?.toString() ?? 'Unknown')
                                    : record.toString();
                                return DropdownMenuItem<String>(
                                  value: displayName,
                                  child: Text(
                                    displayName,
                                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade800),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Text('Role', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey.shade800)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _roleController,
                    decoration: InputDecoration(
                      hintText: 'Filter by user role',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                        borderSide: const BorderSide(color: Color(0xFF4C8DF5)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSearching ? null : _search,
                      icon: _isSearching 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.search, color: Colors.white, size: 18),
                      label: Text(
                        'Search',
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 7, 69, 156),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  Text(
                    'Tip: Select an entity and either enter free text or use Quick pick to choose a known value. You can also search by role name directly (e.g., type "admin", "manager") without selecting an entity. Alternatively, filter results by user role. Click Search to see related records and mappings.',
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // Results area
            if (_showResults) 
              _buildResultsCard()
            else
              Center(
                child: Text(
                  'No results to display. Try a different search term or entity.',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCard() {
    final entityName = _searchedEntity?.replaceAll('-- ', '').replaceAll(' --', '') ?? 'Data';
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Purple Header matching SS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF7E57C2), // Purple header
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.menu, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  '$entityName List',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _isCollapsed = !_isCollapsed),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isCollapsed ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isCollapsed ? 'Expand' : 'Collapse',
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          if (!_isCollapsed)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All $entityName',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF4C8DF5),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: _searchResults.length,
                      separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: index == 2 ? const Color(0xFFF0F7FF) : Colors.transparent, // Highlight 3rd item like SS
                            border: index == 2 
                              ? const Border(left: BorderSide(color: Color(0xFF4C8DF5), width: 3))
                              : null,
                          ),
                          child: Text(
                            _searchResults[index] is Map 
                                ? (_searchResults[index]['displayName']?.toString() ?? 'Unknown')
                                : _searchResults[index].toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: index == 2 ? const Color(0xFF4C8DF5) : Colors.grey.shade800,
                              fontWeight: index == 2 ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

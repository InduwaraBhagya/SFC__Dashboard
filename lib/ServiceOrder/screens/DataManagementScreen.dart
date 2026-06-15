import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../service/DataManagementService.dart';
import 'ManageEntitiesScreen.dart';
import 'SearchDataScreen.dart';
import 'ManageRelationshipsScreen.dart';

class DataManagementScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback onBack;

  const DataManagementScreen(
      {super.key, required this.user, required this.onBack});

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  final DataManagementService _dataManagementService = DataManagementService();
  String? _selectedRelationship;
  String? _selectedEntity;
  String? _sourceEntity;
  String? _targetEntity;
  bool _isLoadingRecords = false;
  List<dynamic> _availableRecords = [];
  dynamic _selectedRecord;
  bool _isSearching = false;
  Map<String, dynamic>? _recordDetails;
  List<String> _dbEntities = [];
  bool _isLoadingEntities = true;

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
        _dbEntities = entities.map((e) => e['name'].toString()).toList();
        _isLoadingEntities = false;
      });
    } catch (e) {
      print('Failed to load entities: $e');
      setState(() => _isLoadingEntities = false);
    }
  }

  Future<void> _findMappedEntity() async {
    if (_selectedEntity == null || _selectedRecord == null) return;

    setState(() {
      _isSearching = true;
      _recordDetails = null;
    });

    try {
      final entityName = _selectedEntity!.split(' (').first.trim();
      final String recordId = _selectedRecord is Map
          ? _selectedRecord['id'].toString()
          : _selectedRecord.toString().split(':').last.trim();

      final details =
          await _dataManagementService.fetchRecordDetails(entityName, recordId);
      setState(() {
        _recordDetails = details;
      });
    } catch (e) {
      print('Failed to find mapped entity: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _loadRecordsForEntity(String entityString) async {
    // Extract actual entity name (e.g., "Divisions (Source)" -> "Divisions")
    final entityName = entityString.split(' (').first.trim();

    setState(() {
      _isLoadingRecords = true;
      _availableRecords = [];
      _selectedRecord = null;
    });

    try {
      final records =
          await _dataManagementService.fetchTableRecords(entityName);
      setState(() {
        _availableRecords = records;
        if (records.isNotEmpty) {
          _selectedRecord = records.first;
        }
      });
    } catch (e) {
      print('Failed to load records: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRecords = false;
        });
      }
    }
  }

  void _updateEntitiesFromRelationship(String? relationship) {
    if (relationship == null) {
      _sourceEntity = null;
      _targetEntity = null;
      _selectedEntity = null;
      _selectedRecord = null;
      _availableRecords = [];
      _isSearching = false;
      _recordDetails = null;
      return;
    }

    final regex = RegExp(r'\((.*?)\s*\?\s*(.*?)\)');
    final match = regex.firstMatch(relationship);

    if (match != null && match.groupCount >= 2) {
      _sourceEntity = match.group(1)?.trim();
      _targetEntity = match.group(2)?.trim();

      if (_sourceEntity == '?') _sourceEntity = 'Unknown';
      if (_targetEntity == '?') _targetEntity = 'Unknown';
    } else {
      _sourceEntity = null;
      _targetEntity = null;
    }
    _selectedEntity = null;
    _selectedRecord = null;
    _availableRecords = [];
    _isSearching = false;
    _recordDetails = null;
  }

  final List<String> _relationships = [
    'Network - Province (Province ? Network)',
    'LEA - OPMC (OPMC ? LEA)',
    'User - Customer (Users ? Customer)',
    'User - Sections (Users ? Sections)',
    'User - Divisions (Users ? Divisions)',
    'User - Workgroup (Users ? Workgroups)',
    'User - Network (Users ? Network)',
    'User - OPMC (Users ? OPMC)',
    'User - Region (Users ? Region)',
    'User - Province (Users ? Province)',
    'Sections - Workgroup (Sections ? Workgroups)',
    'Divisions - Sections (Divisions ? Sections)',
    '_user_Work_user___3C34F16F (Users ? Network)',
    'Users_Province_Target (Users ? Province)',
    '_user_Work_WG_Id__3D2915A8 (Users ? Network)',
    'Customer_Users_922613 (Customer ? Users)',
    'Divisions_Sections_Source (Divisions ? Sections)',
    'Divisions_Sections_Target (Divisions ? Sections)',
    'Divisions_Users_146492 (Divisions ? Users)',
    'EmailLogs_so_record_SO_ID (so_record ? so_record)',
    'IssueMessages_report_report_id (report ? report)',
    'IssueMessages_urgent_records_urgent_id (urgent_records ? urgent_records)',
    'LEA_OPMC_910975 (LEA ? OPMC)',
    'Network_Province_1855 (Network ? Province)',
    'Network_Users_619308 (Network ? Users)',
    'ola_details_so_record_SO_ID (so_record ? ola_details)',
    'OPMC_LEA_Source (OPMC ? LEA)',
    'OPMC_LEA_Target (OPMC ? LEA)',
    'ProjectSOMappings_Projects_ProjectId (ProjectSOMappings ? Projects)',
    'ProjectSOMappings_so_record_SO_ID (so_record ? so_record)',
    'Province_Network_Source (Province ? Network)',
    'Province_Network_Target (Province ? Network)',
    'Province_Users_744816 (Province ? Users)',
    'Region_Users_19030 (Region ? Users)',
    'REL_Users_Customer_Src (? Users)',
    'REL_Users_Customer_Tgt (? Users)',
    'REL_Users_Region_Src (? Users)',
    'REL_Users_Region_Tgt (? Users)',
    'REL_Users_Sections_Src (? Users)',
    'REL_Users_Sections_Tgt (? Users)',
    'ReportReplyMessages_report_ReportId (report ? report)',
    'Sections_Divisions_441308 (Sections ? Divisions)',
    'Sections_Users_639198 (Sections ? Users)',
    'Sections_Workgroups_Source (Sections ? Workgroups)',
    'Sections_Workgroups_Target (Sections ? Workgroups)',
    'task_date_so_record_SO_ID (so_record ? task_date)',
    'Users_Customer_Source (Users ? Customer)',
    'Users_Customer_Target (Users ? Customer)',
    'Users_Divisions_Source (Users ? Divisions)',
    'Users_Divisions_Target (Users ? Divisions)',
    'Users_Network_Source (Users ? Network)',
    'Users_Network_Target (Users ? Network)',
    'Users_OPMC_Source (Users ? OPMC)',
    'Users_OPMC_Target (Users ? OPMC)',
    'Users_Province_Source (Users ? Province)',
    'Users_Province_Target (Users ? Province)',
    'Users_Region_Source (Users ? Region)',
    'Users_Region_Target (Users ? Region)',
    'Users_Roles_RoleId (Users ? Roles)',
    'Users_Sections_Source (Users ? Sections)',
    'Users_Sections_Target (Users ? Sections)',
    'Users_Workgroups_Source (Users ? Workgroups)',
    'Users_Workgroups_Target (Users ? Workgroups)',
    'work_log_so_record_SO_ID (so_record ? work_log)',
    'Workgroups_Sections_590599 (Workgroups ? Sections)',
    'Workgroups_Users_600280 (Workgroups ? Users)',
  ];

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
            color: Theme.of(context).cardColor,
            fontSize: 11,
            fontWeight: FontWeight.w600),
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
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF1A237E), size: 20),
          onPressed: widget.onBack,
        ),
        title: Text(
          'Data Management System',
          style: GoogleFonts.poppins(
            color: const Color(0xFF1A237E),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              children: [
                Icon(Icons.storage_rounded,
                    size: 36, color: Colors.grey.shade800),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Data Management System',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Text(
                        'Create and manage custom entities and their relationships',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Buttons Section
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ManageEntitiesScreen(user: widget.user),
                      ),
                    );
                  },
                  icon: Icon(Icons.table_chart,
                      color: Theme.of(context).cardColor, size: 18),
                  label: Text('Manage Entities',
                      style: GoogleFonts.poppins(
                          color: Theme.of(context).cardColor,
                          fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 7, 69, 156),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SearchDataScreen(user: widget.user),
                      ),
                    );
                  },
                  icon: Icon(Icons.search,
                      color: Theme.of(context).cardColor, size: 18),
                  label: Text('Search Data',
                      style: GoogleFonts.poppins(
                          color: Theme.of(context).cardColor,
                          fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF07459C),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ManageRelationshipsScreen(user: widget.user),
                      ),
                    );
                  },
                  icon: Icon(Icons.account_tree_outlined,
                      color: Theme.of(context).cardColor, size: 18),
                  label: Text('Manage Relationships',
                      style: GoogleFonts.poppins(
                          color: Theme.of(context).cardColor,
                          fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF07459C),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Card Section
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Card Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2196F3),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person_search,
                            color: Theme.of(context).cardColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Find Mapped Entity',
                          style: GoogleFonts.poppins(
                            color: Theme.of(context).cardColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Card Body
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.search,
                                color: Color(0xFF2196F3), size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Search Parameters',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF2196F3),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Select Relationship',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: Text(
                                '-- Select a Relationship --',
                                style: GoogleFonts.poppins(
                                    color: Colors.grey.shade600),
                              ),
                              value: _selectedRelationship,
                              icon: const Icon(Icons.keyboard_arrow_down,
                                  color: Colors.grey),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedRelationship = newValue;
                                  _updateEntitiesFromRelationship(newValue);
                                });
                              },
                              items: _relationships
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey.shade800),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        if (_selectedRelationship != null &&
                            _sourceEntity != null &&
                            _targetEntity != null) ...[
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Find: (From Entity)',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          hint: Text(
                                            '-- Select Entity --',
                                            style: GoogleFonts.poppins(
                                                color: Colors.grey.shade600),
                                          ),
                                          value: _selectedEntity,
                                          icon: const Icon(
                                              Icons.keyboard_arrow_down,
                                              color: Colors.grey),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              _selectedEntity = newValue;
                                            });
                                            if (newValue != null) {
                                              _loadRecordsForEntity(newValue);
                                            }
                                          },
                                          items: _isLoadingEntities
                                              ? [
                                                  DropdownMenuItem(
                                                      value: '',
                                                      child: Text('Loading...',
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  fontSize:
                                                                      14)))
                                                ]
                                              : [
                                                  DropdownMenuItem<String>(
                                                    value:
                                                        '$_sourceEntity (Source)',
                                                    child: Text(
                                                        '$_sourceEntity (Source)',
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .grey
                                                                    .shade800),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1),
                                                  ),
                                                  DropdownMenuItem<String>(
                                                    value:
                                                        '$_targetEntity (Target)',
                                                    child: Text(
                                                        '$_targetEntity (Target)',
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .grey
                                                                    .shade800),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1),
                                                  ),
                                                  // Also allow picking any other table from the DB
                                                  ..._dbEntities
                                                      .where((name) =>
                                                          name !=
                                                              _sourceEntity &&
                                                          name != _targetEntity)
                                                      .map((name) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: '$name (Other)',
                                                      child: Text(name,
                                                          style:
                                                              GoogleFonts.poppins(
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .grey
                                                                      .shade800),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1),
                                                    );
                                                  }),
                                                ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_selectedEntity != null) ...[
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Of: (Select Record)',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: _isLoadingRecords
                                            ? const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 12),
                                                child: SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                            strokeWidth: 2)),
                                              )
                                            : DropdownButtonHideUnderline(
                                                child: DropdownButton<dynamic>(
                                                  isExpanded: true,
                                                  hint: Text(
                                                    _availableRecords.isEmpty
                                                        ? 'No Records'
                                                        : '-- Select --',
                                                    style: GoogleFonts.poppins(
                                                        color: Colors
                                                            .grey.shade600),
                                                  ),
                                                  value: _selectedRecord,
                                                  icon: const Icon(
                                                      Icons.keyboard_arrow_down,
                                                      color: Colors.grey),
                                                  onChanged:
                                                      _availableRecords.isEmpty
                                                          ? null
                                                          : (dynamic newValue) {
                                                              setState(() {
                                                                _selectedRecord =
                                                                    newValue;
                                                              });
                                                            },
                                                  items: _availableRecords
                                                      .map((e) {
                                                    return DropdownMenuItem<
                                                        dynamic>(
                                                      value: e,
                                                      child: Text(
                                                          (e is Map
                                                                  ? e['displayName']
                                                                      ?.toString()
                                                                  : e
                                                                      .toString()) ??
                                                              'Unknown',
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .grey
                                                                      .shade800),
                                                          overflow: TextOverflow
                                                              .ellipsis),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],

                        // Selected Primary Key Box & Submit Button
                        if (_selectedEntity != null &&
                            _selectedRecord != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Selected Primary Key(s):',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1565C0), // Dark blue
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    (_selectedRecord is Map
                                                ? _selectedRecord['id']
                                                : _selectedRecord)
                                            ?.toString() ??
                                        'N/A',
                                    style: GoogleFonts.poppins(
                                      color: Theme.of(context).cardColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed:
                                  _isSearching ? null : _findMappedEntity,
                              icon: _isSearching
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          color: Theme.of(context).cardColor,
                                          strokeWidth: 2))
                                  : Icon(Icons.search,
                                      color: Theme.of(context).cardColor,
                                      size: 20),
                              label: Text(
                                _isSearching
                                    ? 'Searching...'
                                    : 'Find Mapped Entity',
                                style: GoogleFonts.poppins(
                                  color: Theme.of(context).cardColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 7, 69, 156),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),

                        // Result UI
                        if (_recordDetails != null) ...[
                          Row(
                            children: [
                              const Icon(Icons.check_circle_outline,
                                  color: Color(0xFF4CAF50), size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Result',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF4CAF50),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  Border.all(color: const Color(0xFF81C784)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2E7D32),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(7),
                                      topRight: Radius.circular(7),
                                    ),
                                  ),
                                  child: Text(
                                    'Mapped Entity Found',
                                    style: GoogleFonts.poppins(
                                      color: Theme.of(context).cardColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      // Entities side-by-side
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color:
                                                    Theme.of(context).cardColor,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade300),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(
                                                          Icons.arrow_right_alt,
                                                          color: Colors
                                                              .grey.shade400,
                                                          size: 16),
                                                      const SizedBox(width: 4),
                                                      Text('From Entity',
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade600,
                                                                  fontSize:
                                                                      12)),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    _selectedEntity!
                                                        .split(' (')
                                                        .first
                                                        .trim()
                                                        .toUpperCase(),
                                                    style: GoogleFonts.poppins(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                        color: Colors
                                                            .grey.shade800),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      _buildTag(
                                                          'Sid: ${_recordDetails!['Sid'] ?? 'N/A'}',
                                                          Colors.grey.shade600),
                                                      const SizedBox(width: 6),
                                                      _buildTag(
                                                          (_selectedRecord
                                                                      is Map
                                                                  ? _selectedRecord[
                                                                      'displayName']
                                                                  : _selectedRecord)
                                                              .toString(),
                                                          Colors.grey.shade600),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF1F8E9),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                    color: const Color(
                                                        0xFF81C784)),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                          Icons
                                                              .check_circle_outline,
                                                          color:
                                                              Color(0xFF4CAF50),
                                                          size: 16),
                                                      const SizedBox(width: 4),
                                                      Text('Mapped Entity',
                                                          style: GoogleFonts.poppins(
                                                              color: const Color(
                                                                  0xFF4CAF50),
                                                              fontSize: 12)),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    _selectedEntity!
                                                            .contains('Source')
                                                        ? _targetEntity!
                                                            .toUpperCase()
                                                        : _sourceEntity!
                                                            .toUpperCase(),
                                                    style: GoogleFonts.poppins(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                        color: Colors
                                                            .grey.shade900),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      _buildTag(
                                                          'Sid: ${_recordDetails!['Sid'] ?? 'N/A'}',
                                                          const Color(
                                                              0xFF2E7D32)),
                                                      const SizedBox(width: 6),
                                                      _buildTag(
                                                          'Id: ${_recordDetails!['id'] ?? 'N/A'}',
                                                          const Color(
                                                              0xFF2E7D32)),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),

                                      // Details Table
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.info_outline,
                                                      color:
                                                          Colors.grey.shade600,
                                                      size: 16),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    'Complete Record Details',
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 13,
                                                        color: Colors
                                                            .grey.shade700,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Divider(height: 1),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 10),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      flex: 2,
                                                      child: Text('Field',
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .grey
                                                                      .shade800))),
                                                  Expanded(
                                                      flex: 3,
                                                      child: Text('Value',
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .grey
                                                                      .shade800))),
                                                ],
                                              ),
                                            ),
                                            ..._recordDetails!.entries
                                                .map((entry) {
                                              bool isEven = _recordDetails!.keys
                                                          .toList()
                                                          .indexOf(entry.key) %
                                                      2 ==
                                                  0;
                                              return Container(
                                                color: isEven
                                                    ? Colors.grey.shade50
                                                    : Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 10),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                        flex: 2,
                                                        child: Text(entry.key,
                                                            style: GoogleFonts.poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 13,
                                                                color: Colors
                                                                    .grey
                                                                    .shade800))),
                                                    Expanded(
                                                        flex: 3,
                                                        child: Text(
                                                            entry.value
                                                                .toString(),
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        13,
                                                                    color: Colors
                                                                        .grey
                                                                        .shade700))),
                                                  ],
                                                ),
                                              );
                                            }),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const Divider(),
                      ],
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../model/RegularRecord.dart';
import '../service/RegularRecordService.dart';
import 'RegularRecordDetailsScreen.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RegularRecordScreen extends StatefulWidget {
  final String? workgroupName;
  final Map<String, dynamic> user;
  final VoidCallback? onBack;

  const RegularRecordScreen({super.key, this.workgroupName, required this.user, this.onBack});

  @override
  _RegularRecordScreenState createState() => _RegularRecordScreenState();
}

class _RegularRecordScreenState extends State<RegularRecordScreen> with SingleTickerProviderStateMixin {
  final _service = RegularRecordService();
  late Future<Map<String, dynamic>> _futureRecords;
  String? _workgroupName;
  int _page = 1;
  final int _pageSize = 1000; // Increased to fetch practically "all" records
  List<RegularRecord> _allRecords = [];
  int _totalPages = 1;
  int _totalCount = 0;
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // New state for search and filters
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _soSearchController = TextEditingController();
  String _selectedSearchType = 'SO ID';
  final List<String> _searchTypes = [
    'SO ID', 'WO ID', 'CCT ID', 'Fiber SO', 'Region', 'Province', 'RTOM', 'LEA', 'Service Type'
  ];
  bool _filterAll = true;
  bool _filterInProgress = false;
  bool _filterCompleted = false;

  @override
  void initState() {
    super.initState();
    _workgroupName = widget.workgroupName;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    _initializeAndFetch();
  }

  Future<void> _initializeAndFetch() async {
    if (_workgroupName == null) {
      _workgroupName = await _storage.read(key: 'soms_selected_workgroup_name');
    }
    _futureRecords = _fetchRecords();
  }

  Future<Map<String, dynamic>> _fetchRecords({int page = 1}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await _service.fetchRegularRecords(
        workgroupName: _workgroupName,
        page: page,
        pageSize: _pageSize,
      );
      final List<RegularRecord> newRecords = (result['records'] as List<dynamic>?)?.cast<RegularRecord>() ?? [];
      final int totalCount = result['totalCount'] as int? ?? 0;
      final int totalPages = result['totalPages'] as int? ?? 1;

      if (kDebugMode) {
        print('Fetched ${newRecords.length} records, page: $page, total: $totalCount, totalPages: $totalPages');
        print('Records: ${newRecords.map((r) => r.peNumber).toList()}');
      }

      setState(() {
        _allRecords = newRecords;
        _page = page;
        _totalCount = totalCount;
        _totalPages = totalPages;
        _isLoading = false;
        if (_allRecords.isNotEmpty) {
          _animationController.forward();
        }
      });

      return {
        'records': newRecords,
        'totalCount': totalCount,
        'totalPages': totalPages,
      };
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Fetch records failed: $e');
        print('StackTrace: $stackTrace');
      }
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      return {'records': [], 'totalCount': 0, 'totalPages': 1};
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<int> _getPageNumbers() {
    if (_totalPages <= 3) {
      return List.generate(_totalPages, (index) => index + 1);
    }
    List<int> pages = [1];
    int middlePage = _page.clamp(2, _totalPages - 1);
    if (_totalPages > 3) {
      pages.add(middlePage);
    }
    pages.add(_totalPages);
    return pages.toSet().toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      child: SafeArea(
        child: Column(
          children: [
            _buildTopGradientHeader(),
            _buildTealFilterBar(),
            Expanded(
              child: _isLoading && _allRecords.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _allRecords.isEmpty
                      ? _buildNoRecordsFound()
                      : _buildScrollableTable(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopGradientHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF004D40), Color(0xFF1A1F3D)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Image.network('https://www.slt.lk/sites/default/files/logo/slt-logo.png', height: 26, errorBuilder: (c, e, s) => const Icon(Icons.business_center, color: Colors.white70, size: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'SERVICE ORDER MANAGEMENT SYSTEM',
                  style: GoogleFonts.outfit(color: Theme.of(context).cardColor, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                ),
              ),
              IconButton(
                icon: Icon(Icons.menu, color: Theme.of(context).cardColor, size: 20),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
              _buildUserBadgeButton(),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 34,
                  decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(4)),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.grey.shade300))),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedSearchType,
                            icon: const Icon(Icons.keyboard_arrow_down, size: 14),
                            style: const TextStyle(fontSize: 11, color: Colors.black),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedSearchType = newValue!;
                              });
                            },
                            items: _searchTypes.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _soSearchController,
                          onChanged: (v) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Search $_selectedSearchType',
                            hintStyle: const TextStyle(fontSize: 11, color: Colors.grey),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _futureRecords = _fetchRecords(page: 1);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 7, 69, 156),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(80, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: const Row(children: [Icon(Icons.search, size: 14), SizedBox(width: 4), Text('Search', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserBadgeButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFF4DB6AC), borderRadius: BorderRadius.circular(4)),
      child: Text('User', style: TextStyle(color: Theme.of(context).cardColor, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildTealFilterBar() {
    return Container(
      color: const Color(0xFF4DB6AC),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'All Regular Records (${_getFilteredRecords().length} of $_totalCount Records)',
                  style: GoogleFonts.outfit(color: Theme.of(context).cardColor, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              _buildFilterIconOption(Icons.check_box_outlined, 'All', Colors.blue, _filterAll, (v) {
                setState(() {
                  _filterAll = true;
                  _filterInProgress = false;
                  _filterCompleted = false;
                });
              }),
              _buildFilterIconOption(Icons.play_circle_fill, 'In Progress', Colors.red, _filterInProgress, (v) {
                setState(() {
                  _filterAll = false;
                  _filterInProgress = true;
                  _filterCompleted = false;
                });
              }),
              _buildFilterIconOption(Icons.check_circle, 'Completed', Colors.green, _filterCompleted, (v) {
                setState(() {
                  _filterAll = false;
                  _filterInProgress = false;
                  _filterCompleted = true;
                });
              }),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 32,
                  decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(4)),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() {}), // Trigger UI update on search
                    decoration: const InputDecoration(
                      hintText: 'Search by Customer...',
                      hintStyle: TextStyle(fontSize: 11, color: Colors.grey),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _buildSmallButton('Clear', Colors.grey.shade700, () {
                setState(() {
                  _searchController.clear();
                  _soSearchController.clear();
                  _filterAll = true;
                  _filterInProgress = false;
                  _filterCompleted = false;
                });
              }),
              const SizedBox(width: 6),
              _buildSmallButton('Back', Colors.white, () {
                if (widget.onBack != null) {
                  widget.onBack!();
                } else {
                  Navigator.pop(context);
                }
              }, textColor: Colors.black, hasIcon: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterIconOption(IconData icon, String label, Color iconColor, bool value, Function(bool?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.scale(
            scale: 0.8,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              checkColor: Colors.blue,
              side: BorderSide(color: Theme.of(context).cardColor, width: 1.5),
              visualDensity: VisualDensity.compact,
            ),
          ),
          Icon(icon, size: 14, color: value ? iconColor : Colors.white70),
          const SizedBox(width: 2),
          Text(label, style: TextStyle(color: Theme.of(context).cardColor, fontSize: 10, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSmallButton(String label, Color color, VoidCallback onTap, {Color textColor = Colors.white, bool hasIcon = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        child: Row(
          children: [
            if (hasIcon) const Icon(Icons.arrow_back, size: 12, color: Colors.black),
            if (hasIcon) const SizedBox(width: 4),
            Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 1100, // Slightly wider for better breathing room
        child: Column(
          children: [
            _buildTableHeaderRow(),
            Expanded(child: _buildGroupedRecordList()),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeaderRow() {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          _buildHeaderCell('SO ID', flex: 2),
          _buildHeaderCell('Customer', flex: 3),
          _buildHeaderCell('Service Type', flex: 2),
          _buildHeaderCell('Order Type', flex: 2),
          _buildHeaderCell('Required Date', flex: 2),
          _buildHeaderCell('Pending Task', flex: 3),
          _buildHeaderCell('Pending WG', flex: 2),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String label, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black54, letterSpacing: 0.3),
      ),
    );
  }

  List<RegularRecord> _getFilteredRecords() {
    List<RegularRecord> filtered = List.from(_allRecords);

    // Filter by Customer search
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((r) => 
        (r.contractorName?.toLowerCase().contains(query) ?? false) ||
        (r.soNumber?.toLowerCase().contains(query) ?? false)
      ).toList();
    }

    // Filter by SO ID search (from white header)
    if (_soSearchController.text.isNotEmpty) {
      final query = _soSearchController.text.toLowerCase();
      filtered = filtered.where((r) => 
        r.soNumber?.toLowerCase().contains(query) ?? false
      ).toList();
    }

    // Filter by Status checkboxes
    if (!_filterAll) {
      if (_filterInProgress) {
        // Assume 'In Progress' is the default for this endpoint, 
        // but can filter by woStatus if available
        filtered = filtered.where((r) => r.woStatus?.contains('In Progress') ?? true).toList();
      } else if (_filterCompleted) {
        filtered = filtered.where((r) => r.woStatus?.contains('Completed') ?? false).toList();
      }
    }

    return filtered;
  }

  Widget _buildGroupedRecordList() {
    final filteredRecords = _getFilteredRecords();
    final Map<String, List<RegularRecord>> grouped = {};
    for (var record in filteredRecords) {
      final key = record.orderType ?? 'OTHER';
      if (!grouped.containsKey(key)) grouped[key] = [];
      grouped[key]!.add(record);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: grouped.keys.length,
      itemBuilder: (context, index) {
        final groupTitle = grouped.keys.elementAt(index);
        final records = grouped[groupTitle]!;
        return _buildRecordGroupSection(groupTitle, records);
      },
    );
  }

  Widget _buildRecordGroupSection(String title, List<RegularRecord> records) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(color: Color(0xFF1E88E5)),
          child: Row(
            children: [
              Icon(Icons.check_box_outline_blank, color: Theme.of(context).cardColor, size: 16),
              const SizedBox(width: 10),
              Text(
                '${title.toUpperCase()} ORDERS (${records.length} RECORDS)',
                style: TextStyle(color: Theme.of(context).cardColor, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
        ),
        ...records.map((r) => _buildDataRow(r)).toList(),
      ],
    );
  }

  Widget _buildDataRow(RegularRecord record) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => RegularRecordDetailsScreen(record: record)));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(bottom: BorderSide(color: Colors.grey.shade200), left: BorderSide(color: Colors.grey.shade300), right: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          children: [
            _buildInfoCell(record.soNumber ?? 'N/A', flex: 2, isPrimary: true),
            _buildInfoCell(record.contractorName ?? 'N/A', flex: 3),
            _buildInfoCell(record.serviceType ?? 'N/A', flex: 2),
            _buildInfoCell(record.orderType ?? 'N/A', flex: 2),
            _buildInfoCell(record.serviceRequiredDate ?? 'N/A', flex: 2),
            _buildInfoCell(record.pendingTaskName ?? 'N/A', flex: 3),
            _buildInfoCell(record.pendingWg ?? 'N/A', flex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCell(String value, {int flex = 1, bool isPrimary = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: GoogleFonts.outfit(fontSize: 11, fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w400, color: Colors.black87),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildNoRecordsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 70, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No regular records found for:', style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey.shade500)),
          Text(_workgroupName ?? 'All Workgroups', style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey.shade800, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _fetchRecords(page: 1),
            style: ElevatedButton.styleFrom( foregroundColor: Colors.white),
            child: const Text('Retry Search'),
          ),
        ],
      ),
    );
  }
}

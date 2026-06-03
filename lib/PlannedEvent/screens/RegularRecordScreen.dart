import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model/OLAViolateRecord.dart';
import '../service/RegularRecordService.dart';
import 'OLAViolateRecordDetailsScreen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class RegularRecordScreen extends StatefulWidget {
  final String? workgroupName;
  final Map<String, dynamic> user;
<<<<<<< HEAD
  final bool useRealData;

  const RegularRecordScreen({
    super.key,
    this.workgroupName,
    required this.user,
    this.useRealData = false,
  });
=======

  const RegularRecordScreen({super.key, this.workgroupName, required this.user});
>>>>>>> correct-repo/planned_event

  @override
  _RegularRecordScreenState createState() => _RegularRecordScreenState();
}

<<<<<<< HEAD
class _RegularRecordScreenState extends State<RegularRecordScreen>
    with SingleTickerProviderStateMixin {
=======
class _RegularRecordScreenState extends State<RegularRecordScreen> with SingleTickerProviderStateMixin {
>>>>>>> correct-repo/planned_event
  final service = RegularRecordService();
  const storage = FlutterSecureStorage();
  List<OLAViolateRecord> allRecords = [];
  bool isLoading = false;
  String? errorMessage;
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  int currentPage = 1;
  int totalPages0 = 1;
  int totalCount0 = 0;
  const int pageSize = 5;
  int? userId;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeIn),
    );
    initUserAndFetch();
  }

  Future<void> initUserAndFetch() async {
    try {
      final storedUserId = await storage.read(key: 'userId');
      if (storedUserId == null) throw Exception('UserId not found in storage');
      userId = int.tryParse(storedUserId);
      if (userId == null) throw Exception('Invalid UserId in storage');
      await fetchRecords(page: 1);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error fetching userId: $e');
        print('StackTrace: $stackTrace');
      }
      setState(() {
        errorMessage = 'Unable to fetch userId: $e';
        isLoading = false;
      });
    }
  }

  Future<void> fetchRecords({int page = 1}) async {
    if (userId == null) {
      setState(() {
        allRecords = [];
        totalCount0 = 0;
        totalPages0 = 1;
        isLoading = false;
      });
      return;
    }
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final result = await service.fetchRegularRecords(
        workgroupName: widget.workgroupName,
        page: page,
        pageSize: pageSize,
        //fetchMultiWorkgroup: widget.useRealData,
      );

      final List<OLAViolateRecord> newRecords =
          (result['records'] as List<dynamic>?)?.cast<OLAViolateRecord>() ?? [];
      final int totalCount = result['totalCount'] as int? ?? 0;
      final int totalPages = result['totalPages'] as int? ?? 1;

      if (kDebugMode) {
        print(
            'Fetched ${newRecords.length} regular records, page: $page, total: $totalCount, totalPages: $totalPages');
        print('Records: ${newRecords.map((r) => r.peNumber).toList()}');
      }

      setState(() {
        allRecords = newRecords;
        currentPage = result['currentPage'] as int? ?? page;
        totalCount0 = totalCount;
        totalPages0 = totalPages;
        isLoading = false;
        if (allRecords.isNotEmpty) animationController.forward();
      });
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Fetch regular records failed: $e');
        print('StackTrace: $stackTrace');
      }
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Regular Records',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(226, 16, 37, 89),
                Color.fromARGB(255, 8, 11, 66)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          if (errorMessage != null)
            Container(
              color: Colors.red[100],
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(
                          color: Colors.red, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: allRecords.isEmpty && isLoading
                ? const Center(child: CircularProgressIndicator())
                : CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: FadeTransition(
                          opacity: fadeAnimation,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 8.0),
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color.fromARGB(225, 82, 126, 238),
                                  Color.fromARGB(255, 7, 0, 99)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.list,
                                    size: 24, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  'Total Records: $_totalCount',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final record = allRecords[index];
                            return Card(
                              key: ValueKey(record.peNumber),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              child: ExpansionTile(
                                title: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  title: Text(
                                    'PE Number: ${record.peNumber ?? 'N/A'}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Task: ${record.taskName ?? 'N/A'}',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54),
                                      ),
                                      Text(
                                        'Customer: ${record.customer ?? 'N/A'}',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                                children: [
                                  _buildFieldRow(
                                      'Workgroup', record.taskWg ?? 'N/A'),
                                  _buildFieldRow(
                                      'Province', record.province ?? 'N/A'),
                                  _buildFieldRow('Contractor',
                                      record.contractorName ?? 'N/A'),
                                  _buildFieldRow(
                                      'PE Title', record.peTitle ?? 'N/A'),
                                  _buildFieldRow('PE Objective',
                                      record.peObjective ?? 'N/A'),
                                  _buildFieldRow('Service Type',
                                      record.serviceType ?? 'N/A'),
                                  _buildFieldRow(
                                      'Status', record.peStatus ?? 'N/A'),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8.0),
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green[600],
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          elevation: 2,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  OLAViolateRecordDetailsScreen(
                                                      record: record),
                                            ),
                                          );
                                        },
                                        child: const Text('View Full Details'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          childCount: allRecords.length,
                        ),
                      ),
                      if (totalPages0 > 1)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back),
                                  color: currentPage == 1 || isLoading
                                      ? Colors.grey
                                      : Colors.green[600],
                                  onPressed: _currentPage == 1 || _isLoading
                                      ? null
                                      : () => setState(() {
                                            _currentPage--;
                                            _fetchRecords(page: _currentPage);
                                          }),
                                ),
                                Text('Page $currentPage of $totalPages0'),
                                IconButton(
                                  icon: const Icon(Icons.arrow_forward),
                                  color:
                                      currentPage == totalPages0 || isLoading
                                          ? Colors.grey
                                          : Colors.green[600],
                                  onPressed: currentPage == totalPages0 ||
                                          isLoading
                                      ? null
                                      : () => setState(() {
                                            _currentPage++;
                                            _fetchRecords(page: _currentPage);
                                          }),
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
    );
  }

  Widget buildFieldRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: value == 'N/A' ? Colors.grey : Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../service/ProjectService.dart';

class ServiceOrderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> pe;

  const ServiceOrderDetailScreen({super.key, required this.pe});

  @override
  State<ServiceOrderDetailScreen> createState() => _ServiceOrderDetailScreenState();
}

class _ServiceOrderDetailScreenState extends State<ServiceOrderDetailScreen> {
  final ProjectService _projectService = ProjectService();
  bool _isLoadingTasks = true;
  List<dynamic> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final peNumber = widget.pe['peNumber'];
    if (peNumber == null) {
      setState(() => _isLoadingTasks = false);
      return;
    }

    try {
      final tasks = await _projectService.fetchPETasks(peNumber);
      setState(() {
        _tasks = tasks;
        _isLoadingTasks = false;
      });
    } catch (e) {
      setState(() => _isLoadingTasks = false);
      print('Error loading tasks: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        elevation: 0,
        
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Service Order Record Details',
          style: GoogleFonts.poppins(
            color: Theme.of(context).cardColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 7, 69, 156),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Back', style: TextStyle(color: Theme.of(context).cardColor, fontSize: 12)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProgressBar(),
            const SizedBox(height: 16),
            _buildInfoGrid(),
            const SizedBox(height: 16),
            _buildWorkingUserCard(),
            const SizedBox(height: 16),
            _buildTasksSection(),
            const SizedBox(height: 16),
            _buildEmptySection('Previous Report Log'),
            const SizedBox(height: 16),
            _buildEmptySection('Assignments'),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF64B5F6), Color(0xFF9575CD)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: 0.0,
            minHeight: 10,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.flag, color: Theme.of(context).cardColor, size: 14),
              const SizedBox(width: 4),
              Text(
                'Progress: 0%',
                style: GoogleFonts.poppins(color: Theme.of(context).cardColor, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    return Column(
      children: [
        _buildDetailCard('Service', const Color(0xFFFF8A65), [
          _buildRow('SO_ID', widget.pe['soId'] ?? '-', isEven: false),
          _buildRow('SERVICE_CATEGORY', widget.pe['serviceCategory'] ?? '-', isEven: true),
          _buildRow('SERVICE_TYPE', widget.pe['serviceType'] ?? '-', isEven: false),
          _buildRow('ORDER_TYPE', widget.pe['orderType'] ?? '-', isEven: true),
          _buildRow('SERVICE_REQUIRED_DATE', _formatDate(widget.pe['serviceRequiredDate']), isEven: false),
          _buildRow('SO_CREATE_DATE', _formatDate(widget.pe['soCreateDate']), isEven: true),
        ]),
        const SizedBox(height: 16),
        _buildDetailCard('Work', const Color(0xFF81C784), [
          _buildRow('WO_ID', widget.pe['woId'] ?? '-', isEven: false),
          _buildRow('WO_STATUS', widget.pe['woStatus'] ?? '-', isEven: true),
          _buildRow('PENDING_TASK_NAME', widget.pe['pendingTaskName'] ?? '-', isEven: false),
          _buildRow('PENDING_WG', widget.pe['pendingWg'] ?? '-', isEven: true),
          _buildRow('WO_START_DATE', _formatDate(widget.pe['woStartDate']), isEven: false),
          _buildRow('WO_COMMENTS', widget.pe['woComments'] ?? '-', isEven: true),
        ]),
        const SizedBox(height: 16),
        _buildDetailCard('Customer', const Color(0xFF90A4AE), [
          _buildRow('CUSTOMER', widget.pe['customer'] ?? '-', isEven: false),
          _buildRow('CUS_TYPE', widget.pe['cusType'] ?? '-', isEven: true),
          _buildRow('ACCOUNT_MANAGER', widget.pe['accountManager'] ?? '-', isEven: false),
          _buildRow('SECTION_HANDLED_BY', widget.pe['sectionHandledBy'] ?? '-', isEven: true),
        ]),
        const SizedBox(height: 16),
        _buildDetailCard('Location', const Color(0xFFCE93D8), [
          _buildRow('REGION', widget.pe['region'] ?? '-', isEven: false),
          _buildRow('PROVINCE', widget.pe['province'] ?? '-', isEven: true),
          _buildRow('LOCATION_A_ADDRESS', widget.pe['locationAAddress'] ?? '-', isEven: false),
          _buildRow('LOCATION_B_ADDRESS', widget.pe['locationBAddress'] ?? '-', isEven: true),
        ]),
      ],
    );
  }

  Widget _buildDetailCard(String title, Color color, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Text(
              title,
              style: GoogleFonts.poppins(color: Theme.of(context).cardColor, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(0),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isEven = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isEven ? Colors.grey.shade50 : Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.blueGrey.shade900,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingUserCard() {
    return _buildDetailCard('Working user', const Color(0xFF81C784), [
      _buildRow('Task Name', '-', isEven: false),
      _buildRow('Users Service Id', '-', isEven: true),
      _buildRow('Start Date and Time', '-', isEven: false),
      _buildRow('Finish Date and Time', '-', isEven: true),
      _buildRow('Time Spent', '-', isEven: false),
      _buildRow('Work Status', '-', isEven: true),
    ]);
  }

  Widget _buildTasksSection() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF00BCD4),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Text(
              'Tasks',
              style: GoogleFonts.poppins(color: Theme.of(context).cardColor, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          if (_isLoadingTasks)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(child: Text('No tasks found', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey))),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 40,
                dataRowMinHeight: 40,
                dataRowMaxHeight: 50,
                columns: const [
                  DataColumn(label: Text('TASK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('WORKGROUP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('OLA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                ],
                rows: _tasks.map((task) {
                  return DataRow(cells: [
                    DataCell(Text(task['task'] ?? '-', style: const TextStyle(fontSize: 10))),
                    DataCell(Text(task['taskWorkGroup'] ?? '-', style: const TextStyle(fontSize: 10))),
                    DataCell(Text(task['ola']?.toString() ?? '-', style: const TextStyle(fontSize: 10))),
                    DataCell(_buildStatusBadge(task['taskStatus'] ?? 'Assign')),
                  ]);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    String displayStatus = status;

    if (status.toUpperCase() == 'INPROGRESS') {
      color = Colors.blue;
      displayStatus = 'In Progress';
    } else if (status.toUpperCase() == 'COMPLETED') {
      color = Colors.green;
      displayStatus = 'Completed';
    } else if (status.toUpperCase() == 'ASSIGN') {
      color = Colors.blueGrey;
      displayStatus = 'Assign';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayStatus,
        style: TextStyle(color: Theme.of(context).cardColor, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEmptySection(String title) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF00BCD4),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Text(
              title,
              style: GoogleFonts.poppins(color: Theme.of(context).cardColor, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(4)),
                    child: const Text('No records found', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.cyan.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.cyan.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.cyan.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No records have been logged for this Service Order.',
                          style: TextStyle(fontSize: 11, color: Colors.cyan.shade800),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  String _formatDate(dynamic date) {
    if (date == null) return '-';
    try {
      DateTime dt = DateTime.parse(date.toString());
      return DateFormat('yyyy-MM-dd').format(dt);
    } catch (e) {
      return date.toString();
    }
  }
}


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/OLAViolateRecord.dart';
import 'PETaskScreen.dart';

class OLAViolateRecordDetailsScreen extends StatelessWidget {
  final OLAViolateRecord record;

  const OLAViolateRecordDetailsScreen({super.key, required this.record});

  void _navigateToPETasksScreen(BuildContext context) {
    if (record.peNumber != null && record.peNumber!.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PETaskScreen(peNumber: record.peNumber!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PE Number is not available'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SafeArea(
        child: Column(
          children: [
            _buildSomsHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildSubHeader(context),
                    const SizedBox(height: 12),
                    _buildInfoSection(
                      context,
                      'Service',
                      const [Color(0xFFFFD166), Color(0xFFFF5252)],
                      [
                        _Field('SO_ID', record.soId ?? 'N/A'),
                        _Field('SERVICE_CATEGORY', record.serviceCategory ?? 'N/A'),
                        _Field('SERVICE_TYPE', record.serviceType ?? 'N/A'),
                        _Field('ORDER_TYPE', record.orderType ?? 'N/A'),
                        _Field('SERVICE_REQUIRED_DATE', record.plannedEvent?.serviceRequiredDate ?? 'N/A'),
                        _Field('SO_CREATE_DATE', record.soCreateDate ?? 'N/A'),
                      ],
                      isFullWidth: true,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoSection(
                      context,
                      'Work',
                      const [Color(0xFF81C784), Color(0xFF4CAF50)],
                      [
                        _Field('WO_ID', record.woId ?? 'N/A'),
                        _Field('WO_STATUS', record.woStatus ?? 'N/A'),
                        _Field('PENDING_TASK_NAME', record.plannedEvent?.pendingTaskName ?? 'N/A'),
                        _Field('PENDING_WG', record.plannedEvent?.pendingWg ?? 'N/A'),
                        _Field('WO_START_DATE', record.woStartDate ?? 'N/A'),
                        _Field('WO_ACTUAL_START', record.woActualStartDate ?? 'N/A'),
                        _Field('WO_COMMENTS', record.plannedEvent?.woComments ?? 'N/A'),
                      ],
                      isFullWidth: true,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoSection(
                      context,
                      'Customer',
                      const [Color(0xFF37474F), Color(0xFF263238)],
                      [
                        _Field('CUSTOMER', record.customer ?? 'N/A'),
                        _Field('CUS_TYPE', record.cusType ?? 'N/A'),
                        _Field('ACCOUNT_MANAGER', record.accountManager ?? 'N/A'),
                      ],
                      isFullWidth: true,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoSection(
                      context,
                      'Location',
                      const [Color(0xFF9575CD), Color(0xFF673AB7)],
                      [
                        _Field('REGION', record.region ?? 'N/A'),
                        _Field('PROVINCE', record.province ?? 'N/A'),
                        _Field('RTOM', record.rtom ?? 'N/A'),
                        _Field('LOCATION_A_ADDRESS', record.locationAAddress ?? 'N/A'),
                      ],
                      isFullWidth: true,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoSection(
                      context,
                      'Working user',
                      const [Color(0xFF81C784), Color(0xFFAED581)],
                      [
                        _Field('Task Name', record.peTask?.task ?? '-'),
                        _Field('Users Service Id', '-'),
                        _Field('Start Date and Time', record.peTask?.actualTaskCreatedDate ?? '-'),
                        _Field('Finish Date and Time', record.peTask?.aCtualTaskCompleteDate ?? '-'),
                        _Field('Time Spent', record.peTask?.estimatedTime ?? '-'),
                        _Field('Work Status', record.peTask?.taskStatus ?? '-'),
                      ],
                      isFullWidth: true,
                    ),
                    const SizedBox(height: 12),
                    _buildTaskTableSection(context),
                    const SizedBox(height: 12),
                    _buildEmptySection(context, 'Previous Report Log', 'No records found'),
                    const SizedBox(height: 12),
                    _buildEmptySection(context, 'Assignments', 'No assignments found'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSomsHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF003366), Color(0xFF006633)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          Image.network(
            'https://www.slt.lk/sites/default/files/logo/slt-logo.png',
            height: 30,
            errorBuilder: (c, e, s) => const Icon(Icons.business, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'SERVICE ORDER MANAGEMENT SYSTEM',
              style: GoogleFonts.outfit(
                color: Theme.of(context).cardColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1.0,
              ),
            ),
          ),
          _buildTopSearchBar(context),
          const SizedBox(width: 8),
          _buildUserBadge(context),
        ],
      ),
    );
  }

  Widget _buildTopSearchBar(BuildContext context) {
    return Container(
      height: 32,
      width: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: const Row(
              children: [
                Text('SO ID', style: TextStyle(fontSize: 10, color: Colors.black)),
                Icon(Icons.arrow_drop_down, size: 14),
              ],
            ),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search SO ID',
                  hintStyle: TextStyle(fontSize: 10),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF4A69BD),
              borderRadius: BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
            ),
            child: Center(
              child: Icon(Icons.search, color: Theme.of(context).cardColor, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2ECC71),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'User',
        style: TextStyle(color: Theme.of(context).cardColor, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSubHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3498DB), Color(0xFF9B59B6)],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Service Order Record Details',
              style: GoogleFonts.outfit(
                color: Theme.of(context).cardColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.flag, color: Theme.of(context).cardColor, size: 12),
                const SizedBox(width: 4),
                Text('Progress: 0%', style: TextStyle(color: Theme.of(context).cardColor, fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                children: [
                  Icon(Icons.arrow_back, size: 12, color: Colors.blue),
                  SizedBox(width: 4),
                  Text('Back', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, List<Color> headerColors, List<_Field> fields, {bool isFullWidth = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: headerColors),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Text(
              title,
              style: GoogleFonts.poppins(color: Theme.of(context).cardColor, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(1.2),
              },
              border: TableBorder.all(color: Colors.grey.shade200, width: 0.5),
              children: fields.map((f) => TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(f.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.black54)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(f.value, style: const TextStyle(fontSize: 10, color: Colors.black87)),
                  ),
                ],
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTableSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF00BCD4),
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Text(
              'Tasks',
              style: GoogleFonts.poppins(color: Theme.of(context).cardColor, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 30,
              dataRowMinHeight: 30,
              dataRowMaxHeight: 40,
              headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.black54),
              columns: const [
                DataColumn(label: Text('TASK')),
                DataColumn(label: Text('WORKGROUP')),
                DataColumn(label: Text('OLA')),
                DataColumn(label: Text('STATUS')),
                DataColumn(label: Text('CREATED DATE')),
                DataColumn(label: Text('TARGET DATE')),
                DataColumn(label: Text('FINISH DATE')),
                DataColumn(label: Text('TIME SPENT')),
              ],
              rows: [
                DataRow(cells: [
                  DataCell(Text(record.peTask?.task ?? 'confirm w/ customer', style: const TextStyle(fontSize: 10))),
                  const DataCell(Text('-', style: TextStyle(fontSize: 10))),
                  const DataCell(Text('-', style: TextStyle(fontSize: 10))),
                  DataCell(Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(12)),
                    child: Text('Pending', style: TextStyle(color: Theme.of(context).cardColor, fontSize: 9, fontWeight: FontWeight.bold)),
                  )),
                  const DataCell(Text('-', style: TextStyle(fontSize: 10))),
                  const DataCell(Text('-', style: TextStyle(fontSize: 10))),
                  const DataCell(Text('-', style: TextStyle(fontSize: 10))),
                  const DataCell(Text('-', style: TextStyle(fontSize: 10))),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySection(BuildContext context, String title, String emptyMsg) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF00BCD4),
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(color: Theme.of(context).cardColor, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFFFC107), borderRadius: BorderRadius.circular(4)),
                  child: Text(emptyMsg, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.cyan, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No information available for this $title.',
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
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


class _Field {
  final String label;
  final String value;

  _Field(this.label, this.value);
}


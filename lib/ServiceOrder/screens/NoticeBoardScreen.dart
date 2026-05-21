import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../service/NoticesService.dart';
import 'AddNoticeScreen.dart';

class NoticeBoardScreen extends StatefulWidget {
  final Map<String, dynamic>? user;
  final VoidCallback onBack;

  const NoticeBoardScreen({
    super.key,
    this.user,
    required this.onBack,
  });

  @override
  State<NoticeBoardScreen> createState() => _NoticeBoardScreenState();
}

class _NoticeBoardScreenState extends State<NoticeBoardScreen> {
  final NoticesService _noticesService = NoticesService();
  List<dynamic> _notices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotices();
  }

  Future<void> _fetchNotices() async {
    setState(() => _isLoading = true);
    final notices = await _noticesService.fetchNotices();
    setState(() {
      _notices = notices;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: Text(
          'Notice Board',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A237E),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A237E)),
          onPressed: widget.onBack,
        ),
        
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: ElevatedButton(
                onPressed: () => _navigateToAddNotice(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text('Add New Notice'),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildStatsSection(),
                Expanded(
                  child: _notices.isEmpty
                      ? _buildEmptyState()
                      : _buildNoticeList(),
                ),
              ],
            ),
    );
  }

  Widget _buildStatsSection() {
    final activeCount = _notices.where((n) => n['isActive'] == true).length;
    final pinnedCount = _notices.where((n) => n['isPinned'] == true).length;
    final today = DateFormat('MMM dd').format(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.8,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildStatCard(_notices.length.toString(), 'Total Notices'),
          _buildStatCard(activeCount.toString(), 'Active Notices'),
          _buildStatCard(pinnedCount.toString(), 'Pinned Notices'),
          _buildStatCard(today, 'Today'),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.assignment_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No Active Notices',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'There are currently no active notices to display.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _navigateToAddNotice(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text('Create First Notice'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _notices.length,
      itemBuilder: (context, index) {
        final notice = _notices[index];
        return _buildNoticeCard(notice);
      },
    );
  }

  Widget _buildNoticeCard(Map<String, dynamic> notice) {
    String dateRange = '';
    if (notice['startDate'] != null) {
      dateRange = DateFormat('MMM dd').format(DateTime.parse(notice['startDate']));
      if (notice['expireDate'] != null) {
        dateRange += ' - ' + DateFormat('MMM dd').format(DateTime.parse(notice['expireDate']));
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notice['title'] ?? 'No Title',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) => _handleAction(value, notice),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 150),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'view',
                          child: Text('View Details', style: TextStyle(fontSize: 13)),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit', style: TextStyle(fontSize: 13)),
                        ),
                        PopupMenuItem(
                          value: 'pin',
                          child: Text(
                            notice['isPinned'] == true ? 'Unpin Notice' : 'Pin Notice',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Delete',
                            style: TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  notice['description'] ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateRange,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      notice['createdUserName'] ?? 'Admin',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (notice['isPinned'] == true)
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFCA28),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: const Icon(Icons.push_pin, size: 10, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  void _handleAction(String action, Map<String, dynamic> notice) async {
    final userId = widget.user?['UserId'] ?? 0;
    final userName = widget.user?['Name'] ?? 'Admin';

    if (action == 'pin') {
      final success = await _noticesService.togglePin(
        notice['id'],
        !(notice['isPinned'] ?? false),
        userId,
        userName,
      );
      bool isSuccess = false;
      if (success is bool) isSuccess = success;
      else if (success is Map) isSuccess = success['success'] == true;
      
      if (isSuccess) _fetchNotices();
    } else if (action == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Notice'),
          content: const Text('Are you sure you want to delete this notice?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        final success = await _noticesService.deleteNotice(notice['id'], userId, userName);
        bool isSuccess = false;
        if (success is bool) isSuccess = success;
        else if (success is Map) isSuccess = success['success'] == true;
        
        if (isSuccess) _fetchNotices();
      }
    } else if (action == 'edit') {
      _navigateToAddNotice(notice: notice);
    }
  }

  void _navigateToAddNotice({Map<String, dynamic>? notice}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNoticeScreen(
          user: widget.user,
          notice: notice,
        ),
      ),
    );

    // Refresh unconditionally when returning from the add screen
    _fetchNotices();
  }
}


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../service/SomsDashboardService.dart';
import '../service/NotificationService.dart';
import 'SelectWorkgroupScreen.dart';
import 'NoticeBoardScreen.dart';
import 'NotificationScreen.dart';
import '../service/UrgentRecordService.dart';
import '../model/OLAViolateRecord.dart';
import '../service/NoticesService.dart';
import '../components/DraggableChatBot.dart';

class DashboardHome extends StatefulWidget {
  final Map<String, dynamic>? user;
  final Function(int)? onNavigate;
  const DashboardHome({super.key, this.user, this.onNavigate});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  final SomsDashboardService _dashboardService = SomsDashboardService();
  final NoticesService _noticesService = NoticesService();
  final NotificationService _notificationService = NotificationService();

  bool _isLoading = true;
  String? _errorMessage;
  String _workgroupName = 'Loading...';
  final UrgentRecordService _urgentRecordService = UrgentRecordService();
  List<dynamic> _notices = [];
  List<OLAViolateRecord> _urgentInbox = [];
  Map<String, dynamic> _metrics = {
    'urgent': 0,
    'inProgress': 0,
    'olaViolated': 0,
    'hold': 0,
    'dormant': 0,
  };

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final wgNameFuture = _dashboardService.getSelectedWorkgroupName();
      final metricsFuture = _dashboardService.fetchMetrics();
      final noticesFuture = _noticesService.fetchNotices();

      final wgName = await wgNameFuture;
      final metrics = await metricsFuture;
      final notices = await noticesFuture;

      final inboxResult = await _urgentRecordService.fetchUrgentRecords(
          page: 1, pageSize: 10, workgroupId: wgName);
      final urgentInbox = inboxResult['records'] as List<OLAViolateRecord>;

      if (mounted) {
        setState(() {
          _workgroupName = wgName ?? 'All Workgroups';
          _metrics = metrics;
          _notices = notices;
          _urgentInbox = urgentInbox;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF0F4F8), // Soft background matching web apps
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _fetchDashboardData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildErrorBanner(),
                        _buildWorkgroupFilterBanner(),
                        const SizedBox(height: 16),
                        _buildKPISection(),
                        const SizedBox(height: 16),
                        _buildActionCardsSection(),
                      ],
                    ),
                  ),
                ),
          DraggableChatBot(user: widget.user),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    if (_errorMessage == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(8),
      color: Colors.red.shade100,
      child: Text(
        'Error loading metrics: $_errorMessage',
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildWorkgroupFilterBanner() {
    return InkWell(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const SelectWorkgroupScreen()),
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF6C5CE7), Color(0xFF8E44AD)]),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF6C5CE7).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.domain, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Active Workgroup',
                      style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w500)),
                  Text(_workgroupName,
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  Text('Change',
                      style: GoogleFonts.poppins(
                          color: const Color(0xFF6C5CE7),
                          fontWeight: FontWeight.bold,
                          fontSize: 11)),
                  const SizedBox(width: 4),
                  const Icon(Icons.swap_horiz,
                      size: 14, color: Color(0xFF6C5CE7)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKPISection() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildKPICard('Urgent\nRequests', '${_metrics['urgent']} Tasks',
            const Color(0xFFFFA07A), Icons.warning_rounded, Colors.red, () {
          if (widget.onNavigate != null)
            widget.onNavigate!(2); 
        }),
        _buildKPICard(
            'In Progress',
            '${_metrics['inProgress']} Tasks',
            const Color(0xFF98FB98),
            Icons.check_circle_outline,
            Colors.teal, () {
          if (widget.onNavigate != null)
            widget.onNavigate!(1); 
        }),
        _buildKPICard(
            'OLA Violated',
            '${_metrics['olaViolated']} Tasks',
            const Color(0xFFA9CCE3),
            Icons.access_time_filled,
            Colors.redAccent, () {
          if (widget.onNavigate != null)
            widget.onNavigate!(4); 
        }),
        _buildKPICard(
            'Hold\nRecords',
            '${_metrics['hold']} Tasks',
            const Color(0xFFF5DEB3),
            Icons.pause_circle_filled,
            Colors.orange, () {
          if (widget.onNavigate != null)
            widget.onNavigate!(3); 
        }),
        _buildKPICard('Dormant', '${_metrics['dormant']} Tasks',
            const Color(0xFFE5E7E9), Icons.delete_outline, Colors.black54, () {
          if (widget.onNavigate != null)
            widget.onNavigate!(5); 
        }),
      ],
    );
  }

  Widget _buildKPICard(String title, String subtitle, Color bgColor,
      IconData iconData, Color iconColor, VoidCallback onTap) {

    final width = (MediaQuery.of(context).size.width / 2) - 18;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.black87)),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12)),
                  child: Text(subtitle,
                      style: GoogleFonts.poppins(
                          color: Colors.red,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                )
              ],
            ),
            Icon(iconData, size: 36, color: iconColor),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCardsSection() {
    return Column(
      children: [
        _buildInboxCard(),
        const SizedBox(height: 12),
        _buildNoticeBoardCard()
      ],
    );
  }

  Widget _buildInboxCard() {
    final inboxCount = _urgentInbox.length;
    final latestTask = inboxCount > 0 ? _urgentInbox.first : null;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (widget.onNavigate != null) widget.onNavigate!(2);
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.inbox_rounded,
                              color: Color(0xFF1E88E5), size: 22),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'My Inbox',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF102559),
                          ),
                        ),
                      ],
                    ),
                    if (inboxCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '$inboxCount Urgent',
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                if (latestTask != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF5F5), // Light red tint
                      border: Border.all(color: const Color(0xFFFFEBEB)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'LATEST RECORD',
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          latestTask.customer ?? 'Urgent record',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Service: ${latestTask.serviceType ?? 'N/A'}',
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            _buildMiniTag('SO: ${latestTask.soId ?? '-'}'),
                            _buildMiniTag('PE: ${latestTask.peNumber ?? '-'}'),
                          ],
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Icon(Icons.done_all_rounded,
                            size: 40, color: Colors.green.shade300),
                        const SizedBox(height: 8),
                        Text(
                          'You\'re all caught up!',
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54),
                        ),
                        Text(
                          'No urgent records available.',
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'View Inbox Details',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E88E5),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded,
                        color: Color(0xFF1E88E5), size: 16),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: GoogleFonts.outfit(
            fontSize: 10,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildNoticeBoardCard() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
                color: Color(0xFFFFCA28),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
            child: Row(
              children: [
                const Icon(Icons.note_alt, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('Notice Board',
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoticeBoardScreen(
                          user: widget.user,
                          onBack: () => Navigator.pop(context),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _notices.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.assignment,
                            color: Colors.grey, size: 30),
                        const SizedBox(height: 8),
                        const Text('No Active Notices',
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold)),
                        const Text('Check back later for updates',
                            style: TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: _notices.length > 2 ? 2 : _notices.length,
                    itemBuilder: (context, index) {
                      final notice = _notices[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                                notice['isPinned'] == true
                                    ? Icons.push_pin
                                    : Icons.circle,
                                size: notice['isPinned'] == true ? 16 : 10,
                                color: notice['isPinned'] == true
                                    ? Colors.amber
                                    : Colors.blue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notice['title'] ?? 'Notice',
                                    style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    notice['description'] ?? '',
                                    style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: Colors.grey.shade600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}

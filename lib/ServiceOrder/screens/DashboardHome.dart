import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../service/SomsDashboardService.dart';
// If these screens don't exist yet, we will just use placeholders for onTap
import 'SelectWorkgroupScreen.dart';
import 'NoticeBoardScreen.dart';
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
  
  bool _isLoading = true;
  String? _errorMessage;
  String _workgroupName = 'Loading...';
  List<dynamic> _notices = [];
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
      final wgName = await _dashboardService.getSelectedWorkgroupName();
      final metrics = await _dashboardService.fetchMetrics();
      final notices = await _noticesService.fetchNotices();
      
      if (mounted) {
        setState(() {
          _workgroupName = wgName ?? 'All Workgroups';
          _metrics = metrics;
          _notices = notices;
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
      backgroundColor: const Color(0xFFF0F4F8), // Soft background matching web apps
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
          MaterialPageRoute(builder: (context) => const SelectWorkgroupScreen()),
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF8E44AD)]),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: const Color(0xFF6C5CE7).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.domain, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Active Workgroup', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w500)),
                  Text(_workgroupName, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  Text('Change', style: GoogleFonts.poppins(color: const Color(0xFF6C5CE7), fontWeight: FontWeight.bold, fontSize: 11)),
                  const SizedBox(width: 4),
                  const Icon(Icons.swap_horiz, size: 14, color: Color(0xFF6C5CE7)),
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
        _buildKPICard('Urgent\nRequests', '${_metrics['urgent']} Tasks', const Color(0xFFFFA07A), Icons.warning_rounded, Colors.red, () {
          if (widget.onNavigate != null) widget.onNavigate!(2); // Sidebar index for Urgent
        }),
        _buildKPICard('In Progress', '${_metrics['inProgress']} Tasks', const Color(0xFF98FB98), Icons.check_circle_outline, Colors.teal, () {
          if (widget.onNavigate != null) widget.onNavigate!(1); // Sidebar index for Regular
        }),
        _buildKPICard('OLA Violated', '${_metrics['olaViolated']} Tasks', const Color(0xFFA9CCE3), Icons.access_time_filled, Colors.redAccent, () {
          if (widget.onNavigate != null) widget.onNavigate!(4); // Sidebar index for OLA
        }),
        _buildKPICard('Hold\nRecords', '${_metrics['hold']} Tasks', const Color(0xFFF5DEB3), Icons.pause_circle_filled, Colors.orange, () {
          if (widget.onNavigate != null) widget.onNavigate!(3); // Sidebar index for Hold
        }),
        _buildKPICard('Dormant', '${_metrics['dormant']} Tasks', const Color(0xFFE5E7E9), Icons.delete_outline, Colors.black54, () {
          if (widget.onNavigate != null) widget.onNavigate!(5); // Sidebar index for Dormant
        }),
      ],
    );
  }

  Widget _buildKPICard(String title, String subtitle, Color bgColor, IconData iconData, Color iconColor, VoidCallback onTap) {
    // Determine card width to loosely fit 2 per row on average mobile screens
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
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Text(subtitle, style: GoogleFonts.poppins(color: Colors.red, fontSize: 11, fontWeight: FontWeight.w600)),
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
    return Container(
      height: 250,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Color(0xFF63C2DE), borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
            child: Row(children: [const Icon(Icons.mail_outline, color: Colors.white, size: 20), const SizedBox(width:8), Text('My Inbox', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold))]),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInboxTab('Unread', true),
                _buildInboxTab('Read 2', false),
                _buildInboxTab('All 2', false),
              ],
            ),
          ),
          const Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mark_email_unread_outlined, color: Colors.grey, size: 40),
                  SizedBox(height: 8),
                  Text('No unread messages', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInboxTab(String title, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? Colors.blue.shade100 : Colors.transparent,
        borderRadius: BorderRadius.circular(12)
      ),
      child: Text(title, style: TextStyle(color: active ? Colors.blue : Colors.grey, fontSize: 11, fontWeight: active ? FontWeight.bold : FontWeight.normal)),
    );
  }


  Widget _buildNoticeBoardCard() {
      return Container(
      height: 150,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(color: Color(0xFFFFCA28), borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
            child: Row(
              children: [
                const Icon(Icons.note_alt, color: Colors.white, size: 20),
                const SizedBox(width:8),
                Text('Notice Board', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
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
                      const Icon(Icons.assignment, color: Colors.grey, size: 30),
                      const SizedBox(height: 8),
                      const Text('No Active Notices', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      const Text('Check back later for updates', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                          Icon(notice['isPinned'] == true ? Icons.push_pin : Icons.circle, 
                               size: notice['isPinned'] == true ? 16 : 10, 
                               color: notice['isPinned'] == true ? Colors.amber : Colors.blue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notice['title'] ?? 'Notice',
                                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  notice['description'] ?? '',
                                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../service/SomsDashboardService.dart';
import '../service/UrgentRecordService.dart';
import '../model/OLAViolateRecord.dart';
import 'OLAViolateRecordDetailsScreen.dart';

class ChatBotScreen extends StatefulWidget {
  final Map<String, dynamic>? user;
  const ChatBotScreen({super.key, this.user});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SomsDashboardService _dashboardService = SomsDashboardService();
  final UrgentRecordService _urgentRecordService = UrgentRecordService();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Welcome message
    _addMessage(
        "Hello! I'm your SOMS AI Assistant. How can I help you today?", false);
  }

  void _addMessage(String text, bool isUser,
      {List<OLAViolateRecord>? records}) {
    setState(() {
      _messages.add({
        'text': text,
        'isUser': isUser,
        'time': DateTime.now(),
        'type': records != null ? 'records' : 'text',
        'records': records,
      });
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    _addMessage(text, true);

    setState(() => _isTyping = true);

    // Simulate AI thinking
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isTyping = false);
        _generateBotResponse(text);
      }
    });
  }

  Future<List<OLAViolateRecord>> _performCustomerSearch(
      String searchTerm) async {
    setState(() => _isTyping = true);
    try {
      final categories = [
        "urgent",
        "inprogress",
        "olaviolated",
        "hold",
        "dormant"
      ];
      final results = await Future.wait(
          categories.map((cat) => _dashboardService.fetchRecords(cat)));

      final List<OLAViolateRecord> allRecords = [];
      final Set<String> seenIds = {};

      for (var result in results) {
        for (var item in result) {
          if (item is Map<String, dynamic>) {
            try {
              final record = OLAViolateRecord.fromJson(item);
              final id = record.soId ?? record.peNumber ?? '';
              if (id.isNotEmpty && !seenIds.contains(id)) {
                seenIds.add(id);
                allRecords.add(record);
              }
            } catch (e) {
              print('Error parsing record in chatbot search: $e');
            }
          }
        }
      }

      final filtered = allRecords.where((r) {
        final cust = r.customer?.toLowerCase() ?? '';
        return cust.contains(searchTerm.toLowerCase());
      }).toList();

      return filtered;
    } catch (e) {
      print('Error performing customer search: $e');
      return [];
    } finally {
      if (mounted) {
        setState(() => _isTyping = false);
      }
    }
  }

  Future<void> _generateBotResponse(String userText) async {
    String response = "";
    List<OLAViolateRecord>? records;
    final query = userText.toLowerCase().trim();

    try {
      if (query.contains("urgent") || query.contains("show record")) {
        setState(() => _isTyping = true);
        final result =
            await _urgentRecordService.fetchUrgentRecords(pageSize: 5);
        records = result['records'] as List<OLAViolateRecord>?;

        if (records != null && records.isNotEmpty) {
          response =
              "I found ${records.length} urgent records in your selected workgroup. Here are the top ones:";
        } else {
          response =
              "There are currently no urgent records in your selected workgroup.";
        }
      } else if (query.contains("metric") ||
          query.contains("stat") ||
          query.contains("total")) {
        final metrics = await _dashboardService.fetchMetrics();
        final total = (metrics['urgent'] ?? 0) +
            (metrics['inProgress'] ?? 0) +
            (metrics['hold'] ?? 0);
        response =
            "Your current dashboard metrics show $total total active tasks, with ${metrics['urgent']} urgent and ${metrics['olaViolated']} OLA violated records.";
      } else if (query.contains("team") || query.contains("member")) {
        final metrics = await _dashboardService.fetchMetrics();
        final members = metrics['activeTeamMembers'] ?? 0;
        response =
            "There are currently $members active team members working in your assigned workgroup.";
      } else if (query.contains("workgroup")) {
        final wg = await _dashboardService.getSelectedWorkgroupName();
        response =
            "You are currently viewing data for the '$wg' workgroup. You can switch workgroups from the home screen filter.";
      } else if (query.contains("search") || query.contains("customer")) {
        // Extract search term
        String searchTerm = "";
        if (query.startsWith("search customer ")) {
          searchTerm = userText.substring("search customer ".length).trim();
        } else if (query.startsWith("customer ")) {
          searchTerm = userText.substring("customer ".length).trim();
        } else if (query.startsWith("search ")) {
          searchTerm = userText.substring("search ".length).trim();
        } else {
          final index = query.indexOf("search customer");
          if (index != -1 &&
              userText.length > index + "search customer".length + 1) {
            searchTerm =
                userText.substring(index + "search customer".length).trim();
          } else {
            final custIndex = query.indexOf("customer");
            if (custIndex != -1 &&
                userText.length > custIndex + "customer".length + 1) {
              searchTerm =
                  userText.substring(custIndex + "customer".length).trim();
            }
          }
        }

        if (searchTerm.isEmpty) {
          response =
              "Which customer would you like to search for? Please type: **search customer <name>** (e.g., *search customer Peoples Bank*).";
        } else {
          final filtered = await _performCustomerSearch(searchTerm);
          if (filtered.isNotEmpty) {
            records = filtered;
            response =
                "I searched for customer **'$searchTerm'** and found ${filtered.length} matching record(s) in your active workgroup:";
          } else {
            response =
                "I couldn't find any records matching the customer **'$searchTerm'** in your active workgroup. Please double check the name and try again.";
          }
        }
      } else if (query.contains("hello") || query.contains("hi")) {
        response =
            "Hi there! I'm your real-time SOMS assistant. Ask me about your urgent tasks, team stats, or metrics!";
      } else {
        // Fallback search term check
        final filtered = await _performCustomerSearch(userText.trim());
        if (filtered.isNotEmpty) {
          records = filtered;
          response =
              "I found ${filtered.length} matching record(s) for the customer **'${userText.trim()}'** in your active workgroup:";
        }
      }
    } catch (e) {
      response =
          "I'm having trouble connecting to the live server right now, but I can still help you with navigation! Try asking about how to search or where to find reports.";
    }

    // Creative default responses if none of the keywords match
    if (response.isEmpty) {
      final defaultResponses = [
        "That's an interesting question! While I'm specialized in SOMS data like urgent tasks and metrics, I'd love to help you find that. Try asking about 'urgent records' or 'team stats'!",
        "I'm here to assist with your SOMS operations. I can show you urgent tasks, current metrics, or active team members. What would you like to see?",
        "I'm continuously learning! Currently, I can help you with workgroup data, urgent records, and dashboard analytics. How can I assist your workflow today?",
        "I'm on it! Though I primarily handle SOMS record management and team metrics. You can ask me to 'show urgent records' for a quick update.",
      ];
      response = (defaultResponses..shuffle()).first;
    }

    _addMessage(response, false, records: records);
  }

  void _handleQuickAction(String query) {
    _messageController.text = query;
    _handleSend();
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final text = message['text'] as String;
    final isUser = message['isUser'] as bool;
    final type = message['type'] as String?;
    final records = message['records'] as List<OLAViolateRecord>?;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFA855F7).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 18,
                    child: Icon(Icons.smart_toy_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: isUser
                        ? const LinearGradient(
                            colors: [Color(0xFF07459C), Color(0xFF1D4ED8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isUser ? null : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isUser
                            ? const Color(0xFF07459C).withOpacity(0.2)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    text,
                    style: GoogleFonts.poppins(
                      color: isUser ? Colors.white : const Color(0xFF1E293B),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              if (isUser) const SizedBox(width: 10),
              if (isUser)
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Color(0xFF07459C),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          if (!isUser && type == 'records' && records != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 46),
              child: Column(
                children:
                    records.map((record) => _buildRecordCard(record)).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecordCard(OLAViolateRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    OLAViolateRecordDetailsScreen(record: record)),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      record.soId ?? record.peNumber ?? 'N/A',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4F46E5),
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.priority_high_rounded,
                            size: 12, color: Color(0xFFEF4444)),
                        const SizedBox(width: 4),
                        Text(
                          'URGENT',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                record.customer ?? 'Unnamed Customer',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.category_outlined,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${record.serviceType ?? "N/A"} • ${record.orderType ?? "N/A"}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pending Task',
                        style: GoogleFonts.poppins(
                            fontSize: 10, color: Colors.grey.shade500),
                      ),
                      Text(
                        record.plannedEvent?.pendingTaskName ?? 'N/A',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: Color(0xFFCBD5E1)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'label': '🚀 Urgent Tasks', 'query': 'urgent records'},
      {'label': '🔍 Search Customer', 'query': 'search customer'},
      {'label': '📊 Metrics', 'query': 'show metrics'},
      {'label': '💡 Help', 'query': 'help'},
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () => _handleQuickAction(actions[index]['query']!),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: index % 2 == 0
                        ? [const Color(0xFFF1F5F9), Colors.white]
                        : [const Color(0xFFEEF2FF), Colors.white],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    actions[index]['label']!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF07459C).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome_rounded,
                      size: 18,
                      color: const Color(0xFF6366F1).withOpacity(0.6)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: const Color(0xFF1E293B)),
                      decoration: InputDecoration(
                        hintText: 'Ask SOMS AI anything...',
                        hintStyle: GoogleFonts.poppins(
                            color: const Color(0xFF94A3B8), fontSize: 14),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.mic_none_rounded,
                        size: 20, color: Color(0xFF64748B)),
                    onPressed: () {}, // Placeholder for future feature
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF07459C), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F46E5).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _handleSend,
                borderRadius: BorderRadius.circular(30),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child:
                      Icon(Icons.send_rounded, color: Colors.white, size: 22),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF07459C), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          elevation: 0,
          title: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white38),
                  ),
                  child: const CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 18,
                    child: Icon(Icons.smart_toy_rounded,
                        color: Color(0xFF07459C), size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'SOMS AI Assistant',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF34D399),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Online & Ready to Help',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          leading: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: Image.asset(
                'assets/pattern.png',
                repeat: ImageRepeat.repeat,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.grid_4x4, size: 100),
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageBubble(_messages[index]);
                  },
                ),
              ),
              if (_isTyping)
                Padding(
                  padding: const EdgeInsets.only(left: 64, bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF6366F1))),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Thinking...',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              _buildQuickActions(),
              _buildInputArea(),
            ],
          ),
        ],
      ),
    );
  }
}

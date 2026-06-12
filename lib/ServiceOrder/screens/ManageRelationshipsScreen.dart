import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../service/DataManagementService.dart';

class ManageRelationshipsScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const ManageRelationshipsScreen({super.key, required this.user});

  @override
  State<ManageRelationshipsScreen> createState() => _ManageRelationshipsScreenState();
}

class _ManageRelationshipsScreenState extends State<ManageRelationshipsScreen> {
  final DataManagementService _service = DataManagementService();
  List<dynamic> _relationships = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRelationships();
  }

  Future<void> _loadRelationships() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.fetchRelationships();
      setState(() {
        _relationships = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading relationships: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1A237E), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Relationships',
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
         
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.link, size: 28, color: Color(0xFF2C3E50)),
                        const SizedBox(width: 12),
                        Text(
                          'Relationships',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C3E50),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Define and manage relationships between entities',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, size: 16),
                      label: Text('Back', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add, size: 18),
                      label: Text('Create Relationship', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF07459C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

           
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
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
                children: [
               
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text('Name', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade700))),
                        Expanded(flex: 2, child: Text('Source Entity', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade700))),
                        Expanded(flex: 2, child: Text('Target Entity', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade700))),
                        Expanded(flex: 2, child: Text('Created', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade700))),
                        Expanded(flex: 3, child: Text('Actions', textAlign: TextAlign.right, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade700))),
                      ],
                    ),
                  ),
                 
                  _isLoading 
                      ? const Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : _relationships.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Center(
                                child: Text(
                                  'No relationships found in the database.',
                                  style: GoogleFonts.poppins(color: Colors.grey),
                                ),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _relationships.length,
                              separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
                              itemBuilder: (context, index) {
                                final rel = _relationships[index];
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          rel['name']?.toString() ?? 'N/A',
                                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1A237E)),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          rel['sourceEntity']?.toString() ?? 'N/A',
                                          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          rel['targetEntity']?.toString() ?? 'N/A',
                                          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          rel['created']?.toString() ?? 'Recent',
                                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {},
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF07459C),
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                                elevation: 0,
                                                minimumSize: Size.zero,
                                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              ),
                                              child: Text('Manage Mappings', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600)),
                                            ),
                                            const SizedBox(width: 8),
                                            ElevatedButton(
                                              onPressed: () {},
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFFD9534F),
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                                elevation: 0,
                                                minimumSize: Size.zero,
                                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              ),
                                              child: Text('Delete', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
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

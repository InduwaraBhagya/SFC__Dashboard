import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import '../service/NoticesService.dart';

class AddNoticeScreen extends StatefulWidget {
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? notice;

  const AddNoticeScreen({
    super.key,
    this.user,
    this.notice,
  });

  @override
  State<AddNoticeScreen> createState() => _AddNoticeScreenState();
}

class _AddNoticeScreenState extends State<AddNoticeScreen> {
  final NoticesService _noticesService = NoticesService();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isPinned = false;
  bool _isActive = true;
  DateTime _startDate = DateTime.now();
  DateTime? _expireDate;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.notice != null) {
      _titleController.text = widget.notice!['title'] ?? '';
      _messageController.text = widget.notice!['description'] ?? '';
      _isPinned = widget.notice!['isPinned'] ?? false;
      _isActive = widget.notice!['isActive'] ?? true;
      if (widget.notice!['startDate'] != null) {
        _startDate = DateTime.parse(widget.notice!['startDate']);
      }
      if (widget.notice!['expireDate'] != null) {
        _expireDate = DateTime.parse(widget.notice!['expireDate']);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : (_expireDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _expireDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final userId = int.tryParse(widget.user?['UserId']?.toString() ?? '0') ?? 0;
    final userName = widget.user?['Name'] ?? 'Admin';

    dynamic success;
    try {
      if (widget.notice == null) {
        success = await _noticesService.createNotice(
          title: _titleController.text,
          description: _messageController.text,
          createdBy: userId,
          createdUserName: userName,
          isPinned: _isPinned,
          startDate: _startDate,
          expireDate: _expireDate,
          isActive: _isActive,
        );
      } else {
        success = await _noticesService.updateNotice(
          id: widget.notice!['id'],
          title: _titleController.text,
          description: _messageController.text,
          updatedBy: userId,
          updatedUserName: userName,
          startDate: _startDate,
          expireDate: _expireDate,
          isActive: _isActive,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Network error: $e'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    if (mounted) {
      setState(() => _isSubmitting = false);

      bool isSuccess = false;
      String errorMsg = 'Failed to save notice';

      if (success is bool) {
        isSuccess = success;
      } else if (success is Map) {
        isSuccess = success['success'] == true;
        if (!isSuccess) {
          if (success['message'] != null) {
            errorMsg = success['message'];
            if (success['detail'] != null) {
              errorMsg += ': ' + success['detail'];
            }
          } else if (success['title'] != null) {
            errorMsg = success['title'];
            if (success['errors'] != null) {
              errorMsg += ': ${success['errors']}';
            }
          } else {
            errorMsg = 'Failed to save notice: $success';
          }
        }
      }

      if (isSuccess) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.notice != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Update Notice' : 'Create New Notice',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLabel('Notice Title *'),
                  const SizedBox(height: 8),
                  _buildTextField(_titleController, 'Enter notice title', 1),
                  const SizedBox(height: 20),
                  _buildLabel('Notice Message *'),
                  const SizedBox(height: 8),
                  _buildTextField(
                      _messageController, 'Enter notice message', 5),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Start Date *'),
                            const SizedBox(height: 8),
                            _buildDatePickerField(
                                _startDate, () => _selectDate(context, true)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('End Date (Optional)'),
                            const SizedBox(height: 8),
                            _buildDatePickerField(
                                _expireDate, () => _selectDate(context, false),
                                isOptional: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          title: const Text('Pin this notice',
                              style: TextStyle(fontSize: 13)),
                          subtitle: const Text(
                              'Pinned notices appear at the top',
                              style: TextStyle(fontSize: 11)),
                          value: _isPinned,
                          onChanged: (val) =>
                              setState(() => _isPinned = val ?? false),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          title: const Text('Active',
                              style: TextStyle(fontSize: 13)),
                          subtitle: const Text(
                              'Active notices are visible to users',
                              style: TextStyle(fontSize: 11)),
                          value: _isActive,
                          onChanged: (val) =>
                              setState(() => _isActive = val ?? true),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: const Text('Back to List'),
                      ),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                        child: _isSubmitting
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Theme.of(context).cardColor,
                                    strokeWidth: 2))
                            : Text(isEdit ? 'Update Notice' : 'Create Notice'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF2C3E50),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hint, int maxLines) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Field required' : null,
    );
  }

  Widget _buildDatePickerField(DateTime? date, VoidCallback onTap,
      {bool isOptional = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(6),
          color: Theme.of(context).cardColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date != null
                  ? intl.DateFormat('MM/dd/yyyy').format(date)
                  : (isOptional ? 'mm/dd/yyyy' : ''),
              style:
                  TextStyle(color: date != null ? Colors.black : Colors.grey),
            ),
            const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

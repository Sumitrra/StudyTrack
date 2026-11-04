
import 'package:flutter/material.dart';
import 'session_database.dart';

class SessionFormPage extends StatefulWidget {
  final Map<String, dynamic>? session;

  const SessionFormPage({super.key, this.session});

  @override
  State<SessionFormPage> createState() => _SessionFormPageState();
}

class _SessionFormPageState extends State<SessionFormPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController =
      TextEditingController();

  final TextEditingController _durationController =
      TextEditingController();

  final TextEditingController _notesController =
      TextEditingController();

  final TextEditingController _otherSubjectController =
      TextEditingController();

  String? _selectedSubject;
  DateTime _selectedDate = DateTime.now();

  bool _isSaving = false;

  final List<String> _subjects = [
    'Programming',
    'Mathematics',
    'Cybersecurity',
    'Software Engineering',
    'Data Structures',
    'Other',
  ];

  bool get _isEditing => widget.session != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      _titleController.text = widget.session!['title'];
      _durationController.text =
          widget.session!['duration'].toString();

      String existingSubject = widget.session!['subject'];

      if (_subjects.contains(existingSubject)) {
        _selectedSubject = existingSubject;
      } else {
        _selectedSubject = 'Other';
        _otherSubjectController.text = existingSubject;
      }

      _selectedDate = DateTime.tryParse(
            widget.session!['date'] ?? '',
          ) ??
          DateTime.now();

      _notesController.text =
          widget.session!['notes'] ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    _otherSubjectController.dispose();

    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _chooseDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _confirmSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            _isEditing ? 'Confirm Changes' : 'Save Study Session',
          ),
          content: Text(
            _isEditing
                ? 'Are you sure you want to update this study session?'
                : 'Are you sure you want to save this study session?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(_isEditing ? 'Update' : 'Save'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _saveSession();
    }
  }

  Future<void> _saveSession() async {
    setState(() {
      _isSaving = true;
    });

    try {
      String subject = _selectedSubject == 'Other'
          ? _otherSubjectController.text.trim()
          : _selectedSubject!;

      Map<String, dynamic> sessionData = {
        'title': _titleController.text.trim(),
        'subject': subject,
        'duration': int.parse(_durationController.text.trim()),
        'date': _formatDate(_selectedDate),
        'notes': _notesController.text.trim(),
      };

      if (_isEditing) {
        await SessionDatabase.instance.updateSession(
          widget.session!['id'],
          sessionData,
        );
      } else {
        sessionData['created_at'] =
            DateTime.now().toIso8601String();

        await SessionDatabase.instance.insertSession(
          sessionData,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Study session updated successfully!'
                : 'Study session saved successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save study session: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Study Session' : 'New Study Session',
        ),
        backgroundColor: const Color(0xFF14213D),
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                'Session Information',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF14213D),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Record your learning progress and study activities.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 25),

              // Session title
              const Text(
                'Session Title *',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'e.g. Java Programming Revision',
                  prefixIcon: const Icon(Icons.edit_note),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a session title';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Subject dropdown
              const Text(
                'Subject *',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                initialValue: _selectedSubject,
                decoration: InputDecoration(
                  hintText: 'Select subject',
                  prefixIcon: const Icon(Icons.menu_book),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: _subjects.map((subject) {
                  return DropdownMenuItem(
                    value: subject,
                    child: Text(subject),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSubject = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a subject';
                  }
                  return null;
                },
              ),

              // Show text box only when Other is selected
              if (_selectedSubject == 'Other') ...[
                const SizedBox(height: 15),

                const Text(
                  'Enter Your Subject *',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _otherSubjectController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Database Management',
                    prefixIcon: const Icon(Icons.edit),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (_selectedSubject == 'Other' &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Please enter your subject';
                    }
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 20),

              // Duration
              const Text(
                'Study Duration (minutes) *',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g. 60',
                  prefixIcon: const Icon(Icons.timer),
                  suffixText: 'minutes',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter study duration';
                  }

                  int? duration = int.tryParse(value.trim());

                  if (duration == null || duration <= 0) {
                    return 'Enter a valid duration greater than 0';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Study date
              const Text(
                'Study Date *',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 8),

              InkWell(
                onTap: _chooseDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.calendar_month),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  child: Text(_formatDate(_selectedDate)),
                ),
              ),

              const SizedBox(height: 20),

              // Optional notes
              const Text(
                'Notes (Optional)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Write additional study notes here...',
                  alignLabelWithHint: true,
                  prefixIcon: const Icon(Icons.notes),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              const SizedBox(height: 30),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _confirmSave,
                  icon: Icon(
                    _isEditing ? Icons.update : Icons.save,
                  ),
                  label: Text(
                    _isSaving
                        ? 'Saving...'
                        : _isEditing
                            ? 'Update Session'
                            : 'Save Session',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF14213D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Cancel button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _isSaving
                      ? null
                      : () {
                          Navigator.pop(context, false);
                        },
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


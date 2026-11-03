import 'package:flutter/material.dart';
import 'session_database.dart';
import 'newsession.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Map<String, dynamic>> _sessions = [];

  bool _isLoading = true;
  bool _loadFailed = false;

  int _currentPage = 1;
  int _totalPages = 0;

  final int _recordsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  // Load study sessions from SQLite
  Future<void> _loadSessions({bool resetPage = false}) async {
    if (resetPage) {
      _currentPage = 1;
    }

    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });

    try {
      int totalRecords =
          await SessionDatabase.instance.getSessionCount();

      _totalPages = (totalRecords / _recordsPerPage).ceil();

      if (_totalPages == 0) {
        _currentPage = 1;
      } else if (_currentPage > _totalPages) {
        _currentPage = _totalPages;
      }

      int offset = (_currentPage - 1) * _recordsPerPage;

      List<Map<String, dynamic>> data =
          await SessionDatabase.instance.getSessions(
        limit: _recordsPerPage,
        offset: offset,
      );

      if (!mounted) return;

      setState(() {
        _sessions = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadFailed = true;
        _isLoading = false;
      });
    }
  }

  // Open the form to add or edit a session
  Future<void> _openSessionForm({
    Map<String, dynamic>? session,
  }) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => SessionFormPage(
          session: session,
        ),
      ),
    );

    if (result == true) {
      _loadSessions(resetPage: true);
    }
  }

  // Show session details
  Future<void> _showSessionDetails(
    Map<String, dynamic> session,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Study Session Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailRow('Title', session['title']),
                _detailRow('Subject', session['subject']),
                _detailRow(
                  'Duration',
                  '${session['duration']} minutes',
                ),
                _detailRow(
                  'Study Date',
                  _formatDate(session['date']),
                ),
                _detailRow(
                  'Notes',
                  session['notes'] ?? 'No notes',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      _openSessionForm(session: session);
    }
  }

  // Display a row in the details dialog
  Widget _detailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Delete a study session after confirmation
  Future<void> _deleteSession(
    Map<String, dynamic> session,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Session?'),
          content: const Text(
            'Are you sure you want to delete this study session?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await SessionDatabase.instance.deleteSession(
          session['id'],
        );

        await _loadSessions();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Study session deleted successfully!'),
          ),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to delete study session.'),
          ),
        );
      }
    }
  }

  // Format the study date
  String _formatDate(dynamic date) {
    if (date == null) return 'Not available';

    DateTime? parsedDate = DateTime.tryParse(date.toString());

    if (parsedDate == null) return date.toString();

    return '${parsedDate.day.toString().padLeft(2, '0')}/'
        '${parsedDate.month.toString().padLeft(2, '0')}/'
        '${parsedDate.year}';
  }

  // Display one study session card
  Widget _buildSessionCard(Map<String, dynamic> session) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFE8EFFB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.menu_book_rounded,
            color: Color(0xFF2456A6),
            size: 26,
          ),
        ),
        title: Text(
          session['title'].toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(session['subject'].toString()),
              const SizedBox(height: 5),
              Text(
                '${session['duration']} minutes  •  '
                '${_formatDate(session['date'])}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: () => _showSessionDetails(session),
        onLongPress: () => _deleteSession(session),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF14213D),
        foregroundColor: Colors.white,
        title: const Text(
          'StudyTrack',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => _loadSessions(resetPage: true),
          ),
        ],
      ),

      body: Column(
        children: [
          // Welcome section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF14213D),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back!',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Manage Your Study Sessions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Keep track of your learning progress.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Session list heading
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Study Sessions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF14213D),
                  ),
                ),
                Text(
                  '${_sessions.length} records',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _loadFailed
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Unable to load study sessions.',
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () => _loadSessions(),
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      )
                    : _sessions.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.menu_book_outlined,
                                  size: 65,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'No study sessions yet',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Tap + to add your first session.',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () =>
                                _loadSessions(resetPage: true),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: _sessions.length,
                              itemBuilder: (context, index) {
                                return _buildSessionCard(
                                  _sessions[index],
                                );
                              },
                            ),
                          ),
          ),

          // Pagination controls and Add Session button
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _currentPage > 1 && !_isLoading
                          ? () {
                              setState(() {
                                _currentPage--;
                              });
                              _loadSessions();
                            }
                          : null,
                      icon: const Icon(Icons.arrow_back_ios),
                    ),
                    Text(
                      'Page $_currentPage of $_totalPages',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: _currentPage < _totalPages &&
                              !_isLoading
                          ? () {
                              setState(() {
                                _currentPage++;
                              });
                              _loadSessions();
                            }
                          : null,
                      icon: const Icon(Icons.arrow_forward_ios),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openSessionForm(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2456A6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Session'),
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

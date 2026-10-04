import 'package:flutter/material.dart';
import '../services/failed_search_repository.dart';

/// Developer-facing screen: shows every search (voice or typed) that
/// returned zero product matches, grouped by query text with a count
/// and last-seen date. Use this periodically to find which real
/// phrases the client is saying that aren't matching any product —
/// then go add those as aliases on the relevant products.
class FailedSearchesScreen extends StatefulWidget {
  const FailedSearchesScreen({super.key});

  @override
  State<FailedSearchesScreen> createState() => _FailedSearchesScreenState();
}

class _FailedSearchesScreenState extends State<FailedSearchesScreen> {
  static const List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatDate(DateTime date) {
    return '${_monthNames[date.month - 1]} ${date.day}, ${date.year}';
  }

  List<_GroupedQuery> _groupEntries() {
    final entries = FailedSearchRepository().getAll();
    final Map<String, _GroupedQuery> grouped = {};

    for (final entry in entries) {
      final key = entry.query.toLowerCase();
      if (grouped.containsKey(key)) {
        grouped[key]!.count++;
        if (entry.searchedAt.isAfter(grouped[key]!.lastSearched)) {
          grouped[key]!.lastSearched = entry.searchedAt;
        }
      } else {
        grouped[key] = _GroupedQuery(
          displayText: entry.query,
          count: 1,
          lastSearched: entry.searchedAt,
        );
      }
    }

    final list = grouped.values.toList();
    list.sort((a, b) => b.count.compareTo(a.count));
    return list;
  }

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Search Log'),
        content: const Text(
          'This will permanently delete the failed-search log. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FailedSearchRepository().clearAll();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupEntries();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Issues'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: grouped.isEmpty ? null : _confirmClear,
            tooltip: 'Clear log',
          ),
        ],
      ),
      body: grouped.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No failed searches logged yet.\nThis is a good sign — '
                  'searches are matching products successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: grouped.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = grouped[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '"${item.displayText}"',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Last searched: ${_formatDate(item.lastSearched)}',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${item.count}x',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _GroupedQuery {
  final String displayText;
  int count;
  DateTime lastSearched;

  _GroupedQuery({
    required this.displayText,
    required this.count,
    required this.lastSearched,
  });
}
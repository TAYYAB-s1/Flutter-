// lib/screens/history_screen.dart

import 'package:flutter/material.dart';
import '../models/conversion_model.dart';
import '../services/storage_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ConversionModel> _allHistory      = [];
  List<ConversionModel> _filteredHistory = [];
  bool                  _isLoading       = true;
  String                _searchQuery     = '';

  final TextEditingController _searchCtrl = TextEditingController();

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Data ──────────────────────────────────────────────────────────────────

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final history = await StorageService.instance.loadHistory();
    if (!mounted) return;
    setState(() {
      _allHistory      = history;
      _filteredHistory = history;
      _isLoading       = false;
    });
  }

  void _filterHistory(String query) {
    setState(() {
      _searchQuery     = query;
      _filteredHistory = query.isEmpty
          ? _allHistory
          : _allHistory
              .where((c) =>
                  c.outputFileName
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  c.toolName
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  c.inputFileName
                      .toLowerCase()
                      .contains(query.toLowerCase()))
              .toList();
    });
  }

  Future<void> _deleteItem(ConversionModel item) async {
    await StorageService.instance.deleteConversion(item.id);
    setState(() {
      _allHistory.removeWhere((c) => c.id == item.id);
      _filteredHistory.removeWhere((c) => c.id == item.id);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Conversion deleted'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              await StorageService.instance.saveConversion(item);
              _loadHistory();
            },
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear All History',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        content: const Text(
          'This will permanently delete all your conversion history. This cannot be undone.',
          style: TextStyle(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await StorageService.instance.clearHistory();
      _searchCtrl.clear();
      setState(() {
        _allHistory      = [];
        _filteredHistory = [];
        _searchQuery     = '';
      });
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversion History'),
        actions: [
          if (_allHistory.isNotEmpty)
            IconButton(
              icon    : const Icon(Icons.delete_outline_rounded),
              tooltip : 'Clear all history',
              onPressed: _clearAll,
            ),
          const SizedBox(width: 4),
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ── Search bar ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged : _filterHistory,
                    decoration: InputDecoration(
                      hintText  : 'Search by filename or tool...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                _filterHistory('');
                              },
                            )
                          : null,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ── Count row ───────────────────────────────────────
                if (_allHistory.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _searchQuery.isEmpty
                            ? '${_allHistory.length} conversion${_allHistory.length == 1 ? '' : 's'}'
                            : '${_filteredHistory.length} result${_filteredHistory.length == 1 ? '' : 's'}',
                        style: TextStyle(
                          fontSize: 12,
                          color   : isDark
                              ? const Color(0xFF888888)
                              : const Color(0xFFAAAAAA),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                // ── List or empty state ─────────────────────────────
                Expanded(
                  child: _filteredHistory.isEmpty
                      ? _EmptyState(
                          isSearch: _searchQuery.isNotEmpty,
                          isDark  : isDark,
                        )
                      : RefreshIndicator(
                          onRefresh: _loadHistory,
                          child    : ListView.builder(
                            padding   : const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            itemCount : _filteredHistory.length,
                            itemBuilder: (_, i) {
                              final item = _filteredHistory[i];
                              return _HistoryItem(
                                key       : ValueKey(item.id),
                                item      : item,
                                isDark    : isDark,
                                onDelete  : () => _deleteItem(item),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// History Item — swipeable list tile
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({
    super.key,
    required this.item,
    required this.isDark,
    required this.onDelete,
  });

  final ConversionModel item;
  final bool            isDark;
  final VoidCallback    onDelete;

  String _formatDate(DateTime dt) {
    final now  = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1)  return 'Just now';
    if (diff.inHours < 1)    return '${diff.inMinutes}m ago';
    if (diff.inDays < 1)     return '${diff.inHours}h ago';
    if (diff.inDays == 1)    return 'Yesterday';
    if (diff.inDays < 7)     return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key             : ValueKey(item.id),
      direction       : DismissDirection.endToStart,
      onDismissed     : (_) => onDelete(),
      background: Container(
        margin       : const EdgeInsets.only(bottom: 10),
        decoration   : BoxDecoration(
          color        : Colors.red,
          borderRadius : BorderRadius.circular(14),
        ),
        alignment  : Alignment.centerRight,
        padding    : const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_rounded,
            color: Colors.white, size: 22),
      ),
      child: Container(
        margin    : const EdgeInsets.only(bottom: 10),
        padding   : const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color       : isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color     : Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                  )
                ],
        ),
        child: Row(
          children: [
            // ── Tool color icon ───────────────────────────────────
            Container(
              width     : 46,
              height    : 46,
              decoration: BoxDecoration(
                color       : item.toolColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.insert_drive_file_rounded,
                  color: item.toolColor, size: 22),
            ),

            const SizedBox(width: 12),

            // ── File info ─────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Output filename
                  Text(
                    item.outputFileName,
                    style: TextStyle(
                      fontSize  : 13,
                      fontWeight: FontWeight.w700,
                      color     : isDark
                          ? Colors.white
                          : const Color(0xFF212121),
                    ),
                    maxLines : 1,
                    overflow : TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 3),

                  // Tool name + size
                  Text(
                    '${item.toolName} • ${item.formattedSize}',
                    style: TextStyle(
                      fontSize: 11,
                      color   : isDark
                          ? const Color(0xFF888888)
                          : const Color(0xFF757575),
                    ),
                  ),

                  const SizedBox(height: 3),

                  // Date
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 11,
                          color: isDark
                              ? const Color(0xFF666666)
                              : const Color(0xFFBBBBBB)),
                      const SizedBox(width: 3),
                      Text(
                        _formatDate(item.convertedAt),
                        style: TextStyle(
                          fontSize: 10,
                          color   : isDark
                              ? const Color(0xFF666666)
                              : const Color(0xFFBBBBBB),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.timer_outlined,
                          size: 11,
                          color: isDark
                              ? const Color(0xFF666666)
                              : const Color(0xFFBBBBBB)),
                      const SizedBox(width: 3),
                      Text(
                        item.formattedDuration,
                        style: TextStyle(
                          fontSize: 10,
                          color   : isDark
                              ? const Color(0xFF666666)
                              : const Color(0xFFBBBBBB),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ── Delete button ─────────────────────────────────────
            GestureDetector(
              onTap: onDelete,
              child: Container(
                width     : 32,
                height    : 32,
                decoration: BoxDecoration(
                  color       : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: Colors.red, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isSearch, required this.isDark});
  final bool isSearch;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSearch
                ? Icons.search_off_rounded
                : Icons.folder_open_rounded,
            size : 72,
            color: isDark
                ? const Color(0xFF444444)
                : const Color(0xFFCCCCCC),
          ),
          const SizedBox(height: 16),
          Text(
            isSearch ? 'No results found' : 'No conversions yet',
            style: TextStyle(
              fontSize  : 16,
              fontWeight: FontWeight.w600,
              color     : isDark
                  ? const Color(0xFF888888)
                  : const Color(0xFFAAAAAA),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isSearch
                ? 'Try a different search term'
                : 'Your converted files will appear here',
            style: TextStyle(
              fontSize: 13,
              color   : isDark
                  ? const Color(0xFF666666)
                  : const Color(0xFFBBBBBB),
            ),
          ),
        ],
      ),
    );
  }
}
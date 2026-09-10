// lib/screens/all_tools_screen.dart

import 'package:flutter/material.dart';
import '../constants/tools_data.dart';
import '../models/tool_model.dart';
import '../widgets/tool_card.dart';
import 'tool_detail_screen.dart';

class AllToolsScreen extends StatefulWidget {
  const AllToolsScreen({super.key});

  @override
  State<AllToolsScreen> createState() => _AllToolsScreenState();
}

class _AllToolsScreenState extends State<AllToolsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery    = '';
  String _selectedFilter = 'All';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Filter logic ──────────────────────────────────────────────────────────

  List<ToolModel> get _filteredTools {
    return kAllTools.where((tool) {
      final matchesSearch = _searchQuery.isEmpty ||
          tool.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tool.description.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesFilter =
          _selectedFilter == 'All' || tool.category == _selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredTools;
    final categories = kToolCategories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Tools'),
        leading: IconButton(
          icon     : const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ── Search bar ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller  : _searchCtrl,
              onChanged   : (v) => setState(() => _searchQuery = v),
              decoration  : InputDecoration(
                hintText     : 'Search tools...',
                prefixIcon   : const Icon(Icons.search_rounded, size: 20),
                suffixIcon   : _searchQuery.isNotEmpty
                    ? IconButton(
                        icon     : const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Filter chips (horizontal scroll) ──────────────────────────
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection : Axis.horizontal,
              padding         : const EdgeInsets.symmetric(horizontal: 16),
              itemCount       : categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder     : (_, i) {
                final cat      = categories[i];
                final selected = cat == _selectedFilter;

                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = cat),
                  child: AnimatedContainer(
                    duration : const Duration(milliseconds: 200),
                    padding  : const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color        : selected
                          ? Theme.of(context).colorScheme.primary
                          : isDark
                              ? const Color(0xFF1E1E1E)
                              : Colors.white,
                      borderRadius : BorderRadius.circular(20),
                      border: selected
                          ? null
                          : Border.all(
                              color: isDark
                                  ? const Color(0xFF2C2C2C)
                                  : const Color(0xFFE0E0E0),
                            ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize   : 13,
                        fontWeight : FontWeight.w600,
                        color      : selected
                            ? Colors.white
                            : isDark
                                ? const Color(0xFFAAAAAA)
                                : const Color(0xFF555555),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // ── Results count ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${filtered.length} tool${filtered.length == 1 ? '' : 's'} found',
                style: TextStyle(
                  fontSize : 12,
                  color    : isDark
                      ? const Color(0xFF888888)
                      : const Color(0xFFAAAAAA),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── Grid or empty state ────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? _EmptyState(query: _searchQuery)
                : GridView.builder(
                    padding    : const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount  : filtered.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount   : 2,
                      crossAxisSpacing : 12,
                      mainAxisSpacing  : 12,
                      childAspectRatio : 0.88,
                    ),
                    itemBuilder: (_, i) => ToolCard(
                      tool  : filtered[i],
                      onTap : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ToolDetailScreen(tool: filtered[i]),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state widget
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size  : 64,
            color : isDark
                ? const Color(0xFF444444)
                : const Color(0xFFCCCCCC),
          ),
          const SizedBox(height: 16),
          Text(
            query.isNotEmpty
                ? 'No tools found for "$query"'
                : 'No tools in this category',
            style: TextStyle(
              fontSize   : 15,
              fontWeight : FontWeight.w600,
              color      : isDark
                  ? const Color(0xFF888888)
                  : const Color(0xFFAAAAAA),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try a different search or filter',
            style: TextStyle(
              fontSize : 12,
              color    : isDark
                  ? const Color(0xFF666666)
                  : const Color(0xFFBBBBBB),
            ),
          ),
        ],
      ),
    );
  }
}
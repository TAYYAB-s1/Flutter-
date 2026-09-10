// lib/widgets/tool_card.dart

import 'package:flutter/material.dart';
import '../models/tool_model.dart';

class ToolCard extends StatelessWidget {
  const ToolCard({
    super.key,
    required this.tool,
    required this.onTap,
  });

  final ToolModel    tool;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color        : isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius : BorderRadius.circular(16),
          boxShadow    : isDark
              ? []
              : [
                  BoxShadow(
                    color      : Colors.black.withOpacity(0.07),
                    blurRadius : 10,
                    offset     : const Offset(0, 4),
                  ),
                ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icon circle ──────────────────────────────────────────────
            Container(
              width      : 46,
              height     : 46,
              decoration : BoxDecoration(
                color        : tool.accentColor.withOpacity(0.15),
                borderRadius : BorderRadius.circular(12),
              ),
              child: Icon(
                tool.icon,
                color : tool.accentColor,
                size  : 24,
              ),
            ),

            const SizedBox(height: 12),

            // ── Tool name ────────────────────────────────────────────────
            Text(
              tool.name,
              style: TextStyle(
                fontSize   : 14,
                fontWeight : FontWeight.w700,
                color      : isDark ? Colors.white : const Color(0xFF212121),
              ),
              maxLines  : 1,
              overflow  : TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // ── Description ──────────────────────────────────────────────
            Expanded(
              child: Text(
                tool.description,
                style: TextStyle(
                  fontSize : 11,
                  color    : isDark
                      ? const Color(0xFFAAAAAA)
                      : const Color(0xFF757575),
                  height   : 1.4,
                ),
                maxLines  : 2,
                overflow  : TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 10),

            // ── Format badge + arrow ─────────────────────────────────────
            Row(
              children: [
                // Input → Output badge
                Container(
                  padding    : const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration : BoxDecoration(
                    color        : tool.accentColor.withOpacity(0.12),
                    borderRadius : BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${tool.inputFormat.toUpperCase()} → ${tool.outputFormat.toUpperCase()}',
                    style: TextStyle(
                      fontSize   : 10,
                      fontWeight : FontWeight.w600,
                      color      : tool.accentColor,
                    ),
                  ),
                ),

                const Spacer(),

                // Arrow icon
                Container(
                  width      : 26,
                  height     : 26,
                  decoration : BoxDecoration(
                    color        : tool.accentColor.withOpacity(0.12),
                    borderRadius : BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size  : 14,
                    color : tool.accentColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
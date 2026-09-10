// lib/widgets/file_upload_area.dart

import 'package:flutter/material.dart';

class FileUploadArea extends StatelessWidget {
  const FileUploadArea({
    super.key,
    required this.accentColor,
    required this.acceptedFiles,
    required this.onTap,
    this.isMultiFile = false,
  });

  final Color        accentColor;
  final String       acceptedFiles; // e.g. "pdf" or "jpg,jpeg,png"
  final VoidCallback onTap;
  final bool         isMultiFile;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width  : double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        decoration: BoxDecoration(
          color        : isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius : BorderRadius.circular(16),
          border: Border.all(
            color : accentColor.withOpacity(0.5),
            width : 2,
            // Dashed effect via custom painter below
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Upload icon circle
            Container(
              width      : 72,
              height     : 72,
              decoration : BoxDecoration(
                color        : accentColor.withOpacity(0.12),
                borderRadius : BorderRadius.circular(36),
              ),
              child: Icon(
                Icons.cloud_upload_rounded,
                size  : 36,
                color : accentColor,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              isMultiFile ? 'Tap to select files' : 'Tap to select a file',
              style: TextStyle(
                fontSize   : 16,
                fontWeight : FontWeight.w700,
                color      : isDark ? Colors.white : const Color(0xFF212121),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Accepted: .${acceptedFiles.replaceAll(',', ', .')}',
              style: TextStyle(
                fontSize : 12,
                color    : isDark
                    ? const Color(0xFF888888)
                    : const Color(0xFFAAAAAA),
              ),
            ),

            const SizedBox(height: 20),

            // Browse button
            ElevatedButton.icon(
              onPressed  : onTap,
              style      : ElevatedButton.styleFrom(
                backgroundColor : accentColor,
                foregroundColor : Colors.white,
                padding         : const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon : const Icon(Icons.folder_open_rounded, size: 18),
              label: Text(
                isMultiFile ? 'Browse Files' : 'Browse File',
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// File Info Card — shown after a file is selected
// ─────────────────────────────────────────────────────────────────────────────

class FileInfoCard extends StatelessWidget {
  const FileInfoCard({
    super.key,
    required this.fileName,
    required this.fileSize,
    required this.accentColor,
    required this.onRemove,
  });

  final String       fileName;
  final String       fileSize;   // pre-formatted e.g. "1.4 MB"
  final Color        accentColor;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ext    = fileName.split('.').last.toUpperCase();

    return Container(
      width  : double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color        : isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius : BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color      : Colors.black.withOpacity(0.05),
                  blurRadius : 8,
                ),
              ],
      ),
      child: Row(
        children: [
          // File type badge
          Container(
            width      : 50,
            height     : 56,
            decoration : BoxDecoration(
              color        : accentColor.withOpacity(0.12),
              borderRadius : BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.insert_drive_file_rounded,
                    color: accentColor, size: 22),
                const SizedBox(height: 2),
                Text(
                  ext,
                  style: TextStyle(
                    fontSize   : 9,
                    fontWeight : FontWeight.w800,
                    color      : accentColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          // File name + size
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: TextStyle(
                    fontSize   : 14,
                    fontWeight : FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF212121),
                  ),
                  maxLines : 2,
                  overflow : TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 13, color: const Color(0xFF43A047)),
                    const SizedBox(width: 4),
                    Text(
                      '$fileSize • Ready to convert',
                      style: TextStyle(
                        fontSize : 12,
                        color    : isDark
                            ? const Color(0xFF888888)
                            : const Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Remove button
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width      : 32,
              height     : 32,
              decoration : BoxDecoration(
                color        : Colors.red.withOpacity(0.12),
                borderRadius : BorderRadius.circular(8),
              ),
              child: const Icon(Icons.close_rounded,
                  color: Colors.red, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Multi-File List Item — used by Merge PDFs and Image to PDF
// ─────────────────────────────────────────────────────────────────────────────

class MultiFileItem extends StatelessWidget {
  const MultiFileItem({
    super.key,
    required this.index,
    required this.fileName,
    required this.fileSize,
    required this.accentColor,
    required this.onRemove,
  });

  final int          index;
  final String       fileName;
  final String       fileSize;
  final Color        accentColor;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin : const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color        : isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius : BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2C2C2C)
              : const Color(0xFFE0E0E0),
        ),
      ),
      child: Row(
        children: [
          // Number badge
          Container(
            width      : 28,
            height     : 28,
            decoration : BoxDecoration(
              color        : accentColor.withOpacity(0.15),
              borderRadius : BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize   : 12,
                  fontWeight : FontWeight.bold,
                  color      : accentColor,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: TextStyle(
                    fontSize   : 13,
                    fontWeight : FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF212121),
                  ),
                  maxLines : 1,
                  overflow : TextOverflow.ellipsis,
                ),
                Text(
                  fileSize,
                  style: TextStyle(
                    fontSize : 11,
                    color    : isDark
                        ? const Color(0xFF888888)
                        : const Color(0xFFAAAAAA),
                  ),
                ),
              ],
            ),
          ),

          // Remove
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width      : 28,
              height     : 28,
              decoration : BoxDecoration(
                color        : Colors.red.withOpacity(0.1),
                borderRadius : BorderRadius.circular(6),
              ),
              child: const Icon(Icons.close_rounded,
                  color: Colors.red, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}
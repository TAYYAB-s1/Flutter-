// lib/screens/tool_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/tool_model.dart';
import '../widgets/file_upload_area.dart';
import '../widgets/conversion_options.dart';
import 'converting_screen.dart';

class ToolDetailScreen extends StatefulWidget {
  const ToolDetailScreen({super.key, required this.tool});
  final ToolModel tool;

  @override
  State<ToolDetailScreen> createState() => _ToolDetailScreenState();
}

class _ToolDetailScreenState extends State<ToolDetailScreen> {
  // Single-file tools
  PlatformFile? _selectedFile;

  // Multi-file tools (Merge PDFs, Image to PDF)
  final List<PlatformFile> _selectedFiles = [];

  // Conversion options (passed from ConversionOptions widget)
  Map<String, dynamic> _options = {};

  bool get _isMulti   => widget.tool.needsMultiFile;
  bool get _canConvert =>
      _isMulti ? _selectedFiles.length >= (_isMergeTool ? 2 : 1)
               : _selectedFile != null;
  bool get _isMergeTool => widget.tool.id == 'merge_pdfs';

  // ── File picking ──────────────────────────────────────────────────────────

  Future<void> _pickFile() async {
    try {
      final exts = widget.tool.acceptedFiles.split(',');

      if (_isMulti) {
        final result = await FilePicker.platform.pickFiles(
          allowMultiple    : true,
          type             : FileType.custom,
          allowedExtensions: exts,
        );
        if (result != null && result.files.isNotEmpty) {
          setState(() => _selectedFiles.addAll(result.files));
        }
      } else {
        final result = await FilePicker.platform.pickFiles(
          type             : FileType.custom,
          allowedExtensions: exts,
        );
        if (result != null && result.files.isNotEmpty) {
          setState(() => _selectedFile = result.files.first);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open file picker: $e')),
        );
      }
    }
  }

  void _removeFile()                => setState(() => _selectedFile = null);
  void _removeMultiFile(int index)  =>
      setState(() => _selectedFiles.removeAt(index));

  // ── Format helpers ────────────────────────────────────────────────────────

  String _formatBytes(int? bytes) {
    if (bytes == null) return 'Unknown size';
    if (bytes < 1024)        return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // ── Convert action ────────────────────────────────────────────────────────

  void _startConversion() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConvertingScreen(
          tool       : widget.tool,
          file       : _isMulti ? null : _selectedFile,
          files      : _isMulti ? _selectedFiles : null,
          options    : _options,
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tool   = widget.tool;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title           : Text(tool.name),
        backgroundColor : tool.accentColor,
        foregroundColor : Colors.white,
        iconTheme       : const IconThemeData(color: Colors.white),
        titleTextStyle  : const TextStyle(
          color      : Colors.white,
          fontSize   : 18,
          fontWeight : FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Conversion banner ────────────────────────────────────────
            _ConversionBanner(tool: tool),
            const SizedBox(height: 20),

            // ── File section header ──────────────────────────────────────
            Text(
              _isMulti ? 'Select Files' : 'Select File',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // ── Single file: upload area or file info card ───────────────
            if (!_isMulti) ...[
              if (_selectedFile == null)
                FileUploadArea(
                  accentColor   : tool.accentColor,
                  acceptedFiles : tool.acceptedFiles,
                  onTap         : _pickFile,
                )
              else
                FileInfoCard(
                  fileName    : _selectedFile!.name,
                  fileSize    : _formatBytes(_selectedFile!.size),
                  accentColor : tool.accentColor,
                  onRemove    : _removeFile,
                ),
            ],

            // ── Multi-file: list + add button ────────────────────────────
            if (_isMulti) ...[
              if (_selectedFiles.isEmpty)
                FileUploadArea(
                  accentColor   : tool.accentColor,
                  acceptedFiles : tool.acceptedFiles,
                  onTap         : _pickFile,
                  isMultiFile   : true,
                )
              else ...[
                // File list
                ..._selectedFiles.asMap().entries.map((e) => MultiFileItem(
                  index       : e.key,
                  fileName    : e.value.name,
                  fileSize    : _formatBytes(e.value.size),
                  accentColor : tool.accentColor,
                  onRemove    : () => _removeMultiFile(e.key),
                )),

                const SizedBox(height: 8),

                // Add more files button
                GestureDetector(
                  onTap: _pickFile,
                  child: Container(
                    width  : double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E1E1E)
                          : Colors.white,
                      borderRadius : BorderRadius.circular(12),
                      border: Border.all(
                        color: tool.accentColor.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline_rounded,
                            color: tool.accentColor, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Add More Files',
                          style: TextStyle(
                            fontSize   : 14,
                            fontWeight : FontWeight.w600,
                            color      : tool.accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Merge minimum validation hint
                if (_isMergeTool && _selectedFiles.length < 2)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 14, color: tool.accentColor),
                        const SizedBox(width: 6),
                        Text(
                          'Add at least 2 PDF files to merge',
                          style: TextStyle(
                            fontSize : 12,
                            color    : tool.accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],

            const SizedBox(height: 24),

            // ── Tool-specific options ────────────────────────────────────
            // (hidden for Merge PDFs — no extra options needed)
            if (tool.id != 'merge_pdfs') ...[
              const Text(
                'Options',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ConversionOptions(
                tool            : tool,
                onOptionsChanged: (opts) => setState(() => _options = opts),
              ),
              const SizedBox(height: 24),
            ],

            // ── Convert Now button ───────────────────────────────────────
            SizedBox(
              width : double.infinity,
              height: 54,
              child : ElevatedButton(
                onPressed  : _canConvert ? _startConversion : null,
                style      : ElevatedButton.styleFrom(
                  backgroundColor       : _canConvert
                      ? tool.accentColor
                      : (Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF2A2A2A)
                          : const Color(0xFFE0E0E0)),
                  foregroundColor       : _canConvert
                      ? Colors.white
                      : Colors.grey,
                  elevation             : _canConvert ? 2 : 0,
                  shadowColor           : tool.accentColor.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _canConvert
                          ? Icons.bolt_rounded
                          : Icons.lock_outline_rounded,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _canConvert
                          ? 'Convert Now →'
                          : (_isMulti && _isMergeTool
                              ? 'Select at least 2 files'
                              : 'Select a file first'),
                      style: const TextStyle(
                        fontSize   : 16,
                        fontWeight : FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Security note
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_rounded,
                    size: 12,
                    color: isDark
                        ? const Color(0xFF666666)
                        : const Color(0xFFBBBBBB)),
                const SizedBox(width: 4),
                Text(
                  'Files are encrypted and auto-deleted after 24 hours',
                  style: TextStyle(
                    fontSize : 11,
                    color    : isDark
                        ? const Color(0xFF666666)
                        : const Color(0xFFBBBBBB),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Conversion Banner — source icon → arrow → target icon
// ─────────────────────────────────────────────────────────────────────────────

class _ConversionBanner extends StatelessWidget {
  const _ConversionBanner({required this.tool});
  final ToolModel tool;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width  : double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color      : Colors.black.withOpacity(0.05),
                  blurRadius : 8,
                ),
              ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Input format
              _FormatCircle(
                label: tool.inputFormat.toUpperCase(),
                icon : tool.icon,
                color: tool.accentColor,
              ),

              // Arrow
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Icon(Icons.arrow_forward_rounded,
                        color: tool.accentColor, size: 28),
                    const SizedBox(height: 4),
                    Text(
                      'converts to',
                      style: TextStyle(
                        fontSize : 10,
                        color    : isDark
                            ? const Color(0xFF888888)
                            : const Color(0xFFAAAAAA),
                      ),
                    ),
                  ],
                ),
              ),

              // Output format
              _FormatCircle(
                label     : tool.outputFormat.toUpperCase(),
                icon      : Icons.insert_drive_file_rounded,
                color     : tool.accentColor,
                isOutput  : true,
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            tool.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize : 13,
              color    : isDark
                  ? const Color(0xFF888888)
                  : const Color(0xFF757575),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormatCircle extends StatelessWidget {
  const _FormatCircle({
    required this.label,
    required this.icon,
    required this.color,
    this.isOutput = false,
  });

  final String   label;
  final IconData icon;
  final Color    color;
  final bool     isOutput;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width      : 64,
          height     : 64,
          decoration : BoxDecoration(
            color        : isOutput
                ? color.withOpacity(0.08)
                : color.withOpacity(0.15),
            borderRadius : BorderRadius.circular(20),
            border: isOutput
                ? Border.all(
                    color : color.withOpacity(0.3),
                    width : 1.5,
                  )
                : null,
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize   : 13,
            fontWeight : FontWeight.w800,
            color      : color,
          ),
        ),
      ],
    );
  }
}
// lib/screens/result_screen.dart

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import '../models/tool_model.dart';
import '../models/conversion_model.dart';
import '../services/cloudconvert_service.dart';
import '../services/storage_service.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.tool,
    required this.outputFileName,
    required this.downloadUrl,
    required this.fileSizeBytes,
    required this.durationSeconds,
    required this.inputFileName,
  });

  final ToolModel tool;
  final String    outputFileName;
  final String    downloadUrl;
  final int       fileSizeBytes;
  final int       durationSeconds;
  final String    inputFileName;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {

  // ── State ─────────────────────────────────────────────────────────────────
  bool    _isDownloading   = false;
  bool    _isDownloaded    = false;
  String? _localFilePath;
  double  _downloadProgress = 0;
  bool    _historySaved    = false;

  // ── Check-mark animation ──────────────────────────────────────────────────
  late final AnimationController _checkCtrl;
  late final Animation<double>   _checkScale;
  late final Animation<double>   _checkFade;

  @override
  void initState() {
    super.initState();

    _checkCtrl = AnimationController(
      vsync   : this,
      duration: const Duration(milliseconds: 600),
    );

    _checkScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut),
    );

    _checkFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkCtrl, curve: Curves.easeIn),
    );

    // Play animation after frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCtrl.forward();
    });

    // Save to history once
    _saveToHistory();
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    super.dispose();
  }

  // ── Save to history ───────────────────────────────────────────────────────

  Future<void> _saveToHistory() async {
    if (_historySaved) return;
    _historySaved = true;

    final conversion = ConversionModel(
      id             : DateTime.now().millisecondsSinceEpoch.toString(),
      toolId         : widget.tool.id,
      toolName       : widget.tool.name,
      inputFileName  : widget.inputFileName,
      outputFileName : widget.outputFileName,
      outputFilePath : _localFilePath ?? '',
      downloadUrl    : widget.downloadUrl,
      fileSizeBytes  : widget.fileSizeBytes,
      convertedAt    : DateTime.now(),
      durationSeconds: widget.durationSeconds,
      toolColor      : widget.tool.accentColor,
    );

    await StorageService.instance.saveConversion(conversion);
  }

  // ── Download ──────────────────────────────────────────────────────────────

  Future<void> _downloadFile() async {
    if (_isDownloading || _isDownloaded) return;

    setState(() {
      _isDownloading    = true;
      _downloadProgress = 0;
    });

    String? savedPath;

    if (kIsWeb) {
      // On web: open the download URL in a new browser tab
      // The browser handles the actual file save
      final url = widget.downloadUrl;
      if (url.startsWith('data:') || url.startsWith('http')) {
        // Use url_launcher or just mark as downloaded on web
        savedPath = url;
      } else {
        savedPath = url;
      }
      setState(() {
        _isDownloading = false;
        _isDownloaded  = true;
        _localFilePath = savedPath;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('File ready — tap Open to download'),
              ],
            ),
            backgroundColor: const Color(0xFF43A047),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    // Mobile path
    final isLocalPath = widget.downloadUrl.startsWith('/') ||
        widget.downloadUrl.startsWith('file://') ||
        widget.downloadUrl.startsWith('data:');

    if (isLocalPath) {
      savedPath = widget.downloadUrl.startsWith('data:')
          ? null
          : widget.downloadUrl;
    } else {
      savedPath = await CloudConvertService.instance.downloadFile(
        downloadUrl: widget.downloadUrl,
        fileName   : widget.outputFileName,
        onProgress : (received, total) {
          if (total > 0 && mounted) {
            setState(() => _downloadProgress = received / total);
          }
        },
      );
    }

    if (!mounted) return;

    if (savedPath != null) {
      setState(() {
        _isDownloading  = false;
        _isDownloaded   = true;
        _localFilePath  = savedPath;
      });

      // Update history with local path
      await _updateHistoryPath(savedPath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Saved to Downloads: ${widget.outputFileName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF43A047),
          behavior       : SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label    : 'Open',
            textColor: Colors.white,
            onPressed: _openFile,
          ),
        ),
      );
    } else {
      setState(() => _isDownloading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Download failed. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _updateHistoryPath(String path) async {
    // Re-save the conversion with the local file path
    final conversion = ConversionModel(
      id             : DateTime.now().millisecondsSinceEpoch.toString(),
      toolId         : widget.tool.id,
      toolName       : widget.tool.name,
      inputFileName  : widget.inputFileName,
      outputFileName : widget.outputFileName,
      outputFilePath : path,
      downloadUrl    : widget.downloadUrl,
      fileSizeBytes  : widget.fileSizeBytes,
      convertedAt    : DateTime.now(),
      durationSeconds: widget.durationSeconds,
      toolColor      : widget.tool.accentColor,
    );
    await StorageService.instance.saveConversion(conversion);
  }

  // ── Open file ─────────────────────────────────────────────────────────────

  Future<void> _openFile() async {
    if (_localFilePath == null) return;
    try {
      await OpenFilex.open(_localFilePath!);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open file — no app installed for this format.'),
          ),
        );
      }
    }
  }

  // ── Share ─────────────────────────────────────────────────────────────────

  Future<void> _shareFile() async {
    try {
      if (_localFilePath != null && await File(_localFilePath!).exists()) {
        // Share local file
        await Share.shareXFiles(
          [XFile(_localFilePath!)],
          subject: widget.outputFileName,
        );
      } else {
        // Share download link
        await Share.share(
          'Download my converted file: ${widget.downloadUrl}',
          subject: widget.outputFileName,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not share file: $e')),
        );
      }
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatBytes(int bytes) {
    if (bytes <= 0)        return 'Unknown size';
    if (bytes < 1024)      return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    return '${seconds ~/ 60}m ${seconds % 60}s';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tool   = widget.tool;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Conversion Complete'),
        actions: [
          IconButton(
            icon     : const Icon(Icons.close_rounded),
            onPressed: () =>
                Navigator.popUntil(context, (r) => r.isFirst),
            tooltip: 'Back to Home',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 16),

            // ── Animated checkmark ────────────────────────────────────
            FadeTransition(
              opacity: _checkFade,
              child: ScaleTransition(
                scale: _checkScale,
                child: Container(
                  width     : 96,
                  height    : 96,
                  decoration: const BoxDecoration(
                    color      : Color(0xFF43A047),
                    shape      : BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size : 54,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Headline ──────────────────────────────────────────────
            const Text(
              'Conversion Complete!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 6),

            Text(
              'Your file is ready to download',
              style: TextStyle(
                fontSize: 14,
                color   : isDark
                    ? const Color(0xFF888888)
                    : const Color(0xFF757575),
              ),
            ),

            const SizedBox(height: 28),

            // ── File card ─────────────────────────────────────────────
            Container(
              width  : double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color       : isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF43A047).withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color     : Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                        )
                      ],
              ),
              child: Row(
                children: [
                  // File type icon
                  Container(
                    width     : 56,
                    height    : 64,
                    decoration: BoxDecoration(
                      color       : tool.accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(tool.icon, color: tool.accentColor, size: 24),
                        const SizedBox(height: 4),
                        Text(
                          widget.outputFileName.split('.').last.toUpperCase(),
                          style: TextStyle(
                            fontSize  : 9,
                            fontWeight: FontWeight.w800,
                            color     : tool.accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 14),

                  // File details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.outputFileName,
                          style: TextStyle(
                            fontSize  : 14,
                            fontWeight: FontWeight.w700,
                            color     : isDark
                                ? Colors.white
                                : const Color(0xFF212121),
                          ),
                          maxLines : 2,
                          overflow : TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12,
                          children: [
                            _MetaChip(
                              icon  : Icons.data_usage_rounded,
                              label : _formatBytes(widget.fileSizeBytes),
                              isDark: isDark,
                            ),
                            _MetaChip(
                              icon  : Icons.timer_outlined,
                              label : _formatDuration(widget.durationSeconds),
                              isDark: isDark,
                            ),
                            _MetaChip(
                              icon  : Icons.check_circle_outline_rounded,
                              label : tool.name,
                              isDark: isDark,
                              color : const Color(0xFF43A047),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Download button ───────────────────────────────────────
            SizedBox(
              width : double.infinity,
              height: 54,
              child : ElevatedButton.icon(
                onPressed: _isDownloading ? null : _downloadFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isDownloaded
                      ? const Color(0xFF388E3C)
                      : const Color(0xFF43A047),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation  : 2,
                  shadowColor: const Color(0xFF43A047).withValues(alpha: 0.4),
                ),
                icon: _isDownloading
                    ? SizedBox(
                        width : 18,
                        height: 18,
                        child : CircularProgressIndicator(
                          value      : _downloadProgress > 0
                              ? _downloadProgress
                              : null,
                          strokeWidth: 2,
                          color      : Colors.white,
                        ),
                      )
                    : Icon(
                        _isDownloaded
                            ? Icons.check_rounded
                            : Icons.download_rounded,
                        size: 20,
                      ),
                label: Text(
                  _isDownloading
                      ? (_downloadProgress > 0
                          ? 'Downloading ${(_downloadProgress * 100).toInt()}%...'
                          : 'Downloading...')
                      : (_isDownloaded
                          ? 'Downloaded ✓'
                          : 'Download File'),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Open file button (visible after download) ─────────────
            if (_isDownloaded) ...[
              SizedBox(
                width : double.infinity,
                height: 50,
                child : OutlinedButton.icon(
                  onPressed: _openFile,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF43A047),
                    side: const BorderSide(
                        color: Color(0xFF43A047), width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon : const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text('Open File',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // ── Share button ──────────────────────────────────────────
            SizedBox(
              width : double.infinity,
              height: 50,
              child : OutlinedButton.icon(
                onPressed: _shareFile,
                style: OutlinedButton.styleFrom(
                  foregroundColor: tool.accentColor,
                  side: BorderSide(color: tool.accentColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon : const Icon(Icons.share_rounded, size: 18),
                label: const Text('Share File',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),

            const SizedBox(height: 24),

            // ── Divider ───────────────────────────────────────────────
            Divider(
              color    : isDark
                  ? const Color(0xFF2C2C2C)
                  : const Color(0xFFE0E0E0),
            ),

            const SizedBox(height: 16),

            // ── Convert Another File ──────────────────────────────────
            SizedBox(
              width : double.infinity,
              height: 48,
              child : TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon : Icon(Icons.refresh_rounded,
                    color: tool.accentColor, size: 18),
                label: Text(
                  'Convert Another File',
                  style: TextStyle(
                    fontSize  : 15,
                    fontWeight: FontWeight.w600,
                    color     : tool.accentColor,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── Footer note ───────────────────────────────────────────
            Text(
              'File will be available on the server for 24 hours',
              style: TextStyle(
                fontSize: 11,
                color   : isDark
                    ? const Color(0xFF555555)
                    : const Color(0xFFBBBBBB),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Metadata chip ─────────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.isDark,
    this.color,
  });

  final IconData icon;
  final String   label;
  final bool     isDark;
  final Color?   color;

  @override
  Widget build(BuildContext context) {
    final textColor = color ??
        (isDark ? const Color(0xFF888888) : const Color(0xFF757575));

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: textColor),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(
                fontSize: 11, color: textColor, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
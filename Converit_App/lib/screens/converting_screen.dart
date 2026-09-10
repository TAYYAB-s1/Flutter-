// lib/screens/converting_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import '../models/tool_model.dart';
import '../services/cloudconvert_service.dart';
import 'result_screen.dart';

class ConvertingScreen extends StatefulWidget {
  const ConvertingScreen({
    super.key,
    required this.tool,
    this.file,
    this.files,
    this.options = const {},
  });

  final ToolModel            tool;
  final PlatformFile?        file;
  final List<PlatformFile>?  files;
  final Map<String, dynamic> options;

  @override
  State<ConvertingScreen> createState() => _ConvertingScreenState();
}

class _ConvertingScreenState extends State<ConvertingScreen>
    with TickerProviderStateMixin {

  int      _percent      = 0;
  String   _statusText   = 'Preparing your file...';
  bool     _isCancelled  = false;
  bool     _isNavigating = false;
  DateTime? _startTime;

  late final AnimationController _pulseCtrl;
  late final Animation<double>   _pulseAnim;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync   : this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.93, end: 1.07).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _startTime = DateTime.now();

    // addPostFrameCallback ensures context is ready before any async work
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startConversion();
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  String _messageFor(int pct) {
    if (pct >= 100) return 'Done!';
    if (pct >= 90)  return 'Finalising output file...';
    if (pct >= 60)  return 'Almost done...';
    if (pct >= 25)  return 'Conversion in progress...';
    if (pct >= 10)  return 'Uploading to server...';
    return 'Preparing your file...';
  }

  // ── Web helper — get bytes from PlatformFile ──────────────────────────────
  // On web: file.bytes is populated, file.path is null
  // On mobile: file.path is populated, file.bytes may be null

  Future<void> _startConversion() async {
    final tool = widget.tool;

    void updateProgress(int pct) {
      if (!mounted || _isCancelled) return;
      setState(() {
        _percent    = pct;
        _statusText = _messageFor(pct);
      });
    }

    try {
      ConversionResult result;
      final file = widget.file ?? widget.files?.first;

      if (file == null) {
        _showErrorDialog('No file selected.'); return;
      }

      // On web, path is null — use bytes
      // On mobile, use path (more memory efficient for large files)
      final fileBytes = kIsWeb ? file.bytes : null;
      final filePath  = kIsWeb ? null : file.path;

      if (kIsWeb && fileBytes == null) {
        _showErrorDialog(
          'Could not read file bytes.\n'
          'Please select the file again.',
        );
        return;
      }

      if (!kIsWeb && filePath == null) {
        _showErrorDialog(
          'Could not access file path.\n'
          'Please select the file again.',
        );
        return;
      }

      if (tool.isLocalConversion) {
        // JPG ↔ PNG — local, no API
        result = await CloudConvertService.instance.convertImageLocally(
          fileName     : file.name,
          outputFormat : tool.outputFormat,
          filePath     : filePath,
          fileBytes    : fileBytes,
          options      : widget.options,
          onProgress   : updateProgress,
        );
      } else {
        // CloudConvert API
        result = await CloudConvertService.instance.convert(
          toolId       : tool.id,
          inputFormat  : tool.inputFormat,
          outputFormat : tool.outputFormat,
          fileName     : file.name,
          filePath     : filePath,
          fileBytes    : fileBytes,
          options      : widget.options,
          onProgress   : updateProgress,
        );
      }

      if (_isCancelled || !mounted) return;

      if (!result.success) {
        _showErrorDialog(result.errorMessage ?? 'Conversion failed.');
        return;
      }

      final duration = DateTime.now().difference(_startTime!).inSeconds;

      if (!mounted || _isNavigating) return;
      _isNavigating = true;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            tool           : tool,
            outputFileName : result.outputFileName!,
            downloadUrl    : result.downloadUrl!,
            fileSizeBytes  : result.fileSizeBytes ?? 0,
            durationSeconds: duration,
            inputFileName  : file.name,
          ),
        ),
      );

    } catch (e) {
      if (mounted && !_isCancelled) {
        _showErrorDialog('Unexpected error: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog(
        context           : context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.red, size: 22),
              SizedBox(width: 8),
              Text('Conversion Failed',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(message,
              style: const TextStyle(fontSize: 13, height: 1.5)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _safeNavigateBack();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.tool.accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _percent     = 0;
                  _statusText  = 'Preparing your file...';
                  _isCancelled = false;
                  _isNavigating = false;
                });
                _startTime = DateTime.now();
                _startConversion();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    });
  }

  void _safeNavigateBack() {
    if (!mounted || _isNavigating) return;
    _isNavigating = true;
    _isCancelled  = true;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tool   = widget.tool;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fileName = widget.file?.name ??
        '${widget.files?.length ?? 0} files';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Converting ${tool.name}',
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600)),
        actions: [
          TextButton(
            onPressed: _safeNavigateBack,
            child: Text('Cancel',
                style: TextStyle(
                    color     : tool.accentColor,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // Progress ring
              SizedBox(
                width : 160,
                height: 160,
                child : Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 160, height: 160,
                      child: CircularProgressIndicator(
                        value      : 1.0,
                        strokeWidth: 8,
                        color      : tool.accentColor.withValues(alpha: 0.12),
                      ),
                    ),
                    SizedBox(
                      width: 160, height: 160,
                      child: CircularProgressIndicator(
                        value      : _percent / 100,
                        strokeWidth: 8,
                        color      : tool.accentColor,
                        strokeCap  : StrokeCap.round,
                      ),
                    ),
                    ScaleTransition(
                      scale: _pulseAnim,
                      child: Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                          color       : tool.accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(tool.icon,
                            color: tool.accentColor, size: 44),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              Text('$_percent%',
                  style: TextStyle(
                    fontSize  : 52,
                    fontWeight: FontWeight.w800,
                    color     : tool.accentColor,
                    height    : 1,
                  )),

              const SizedBox(height: 12),

              Text(_statusText,
                  style: TextStyle(
                    fontSize  : 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF212121),
                  ),
                  textAlign: TextAlign.center),

              const SizedBox(height: 8),

              Text(fileName,
                  style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFF888888)
                          : const Color(0xFFAAAAAA)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center),

              const SizedBox(height: 4),

              Text('This usually takes a few seconds',
                  style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFF666666)
                          : const Color(0xFFBBBBBB))),

              const SizedBox(height: 32),

              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value          : _percent / 100,
                  minHeight      : 6,
                  backgroundColor:
                      tool.accentColor.withValues(alpha: 0.12),
                  valueColor:
                      AlwaysStoppedAnimation(tool.accentColor),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StepDot(label: 'Upload',  done: _percent >= 10,
                      color: tool.accentColor, isDark: isDark),
                  _StepDot(label: 'Convert', done: _percent >= 40,
                      color: tool.accentColor, isDark: isDark),
                  _StepDot(label: 'Export',  done: _percent >= 90,
                      color: tool.accentColor, isDark: isDark),
                  _StepDot(label: 'Done',    done: _percent >= 100,
                      color: tool.accentColor, isDark: isDark),
                ],
              ),

              const SizedBox(height: 48),

              TextButton.icon(
                onPressed: _safeNavigateBack,
                icon : Icon(Icons.close_rounded,
                    size: 16, color: tool.accentColor),
                label: Text('Cancel Conversion',
                    style: TextStyle(
                        color     : tool.accentColor,
                        fontSize  : 14,
                        fontWeight: FontWeight.w600)),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_rounded,
                      size: 11,
                      color: isDark
                          ? const Color(0xFF555555)
                          : const Color(0xFFCCCCCC)),
                  const SizedBox(width: 4),
                  Text('Files are encrypted and processed securely',
                      style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? const Color(0xFF555555)
                              : const Color(0xFFCCCCCC))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.label,
    required this.done,
    required this.color,
    required this.isDark,
  });
  final String label;
  final bool   done;
  final Color  color;
  final bool   isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: 10, height: 10,
          decoration: BoxDecoration(
            color: done
                ? color
                : (isDark
                    ? const Color(0xFF333333)
                    : const Color(0xFFDDDDDD)),
            borderRadius: BorderRadius.circular(5),
            boxShadow: done
                ? [BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 6)]
                : [],
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
              fontSize  : 10,
              fontWeight: done ? FontWeight.w600 : FontWeight.normal,
              color     : done
                  ? color
                  : (isDark
                      ? const Color(0xFF555555)
                      : const Color(0xFFBBBBBB)),
            )),
      ],
    );
  }
}
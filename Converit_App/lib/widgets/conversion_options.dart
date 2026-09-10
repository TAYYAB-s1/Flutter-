// lib/widgets/conversion_options.dart

import 'package:flutter/material.dart';
import '../models/tool_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ConversionOptions — renders the right options panel for each tool
// ─────────────────────────────────────────────────────────────────────────────

class ConversionOptions extends StatefulWidget {
  const ConversionOptions({
    super.key,
    required this.tool,
    required this.onOptionsChanged,
  });

  final ToolModel                    tool;
  final ValueChanged<Map<String, dynamic>> onOptionsChanged;

  @override
  State<ConversionOptions> createState() => _ConversionOptionsState();
}

class _ConversionOptionsState extends State<ConversionOptions> {
  // Shared options
  bool _ocrEnabled       = true;
  bool _preserveFormat   = true;
  bool _autoDelete       = true;
  bool _removeMetadata   = false;
  bool _transparentBg    = false;
  bool _fitToPage        = true;

  // PDF to Image
  String _imageFormat    = 'JPG';
  String _imageQuality   = 'High';
  String _pageRange      = 'All Pages';
  final TextEditingController _customRangeCtrl = TextEditingController();

  // Compress PDF
  double _compressionLevel = 1; // 0=Low 1=Medium 2=High

  // Split PDF
  int    _splitRadio     = 0; // 0=all separate 1=range 2=every N
  final TextEditingController _splitRangeCtrl = TextEditingController();
  final TextEditingController _splitNCtrl     = TextEditingController();

  // Image to PDF
  String _pageSize       = 'A4';
  String _orientation    = 'Portrait';

  // Image quality
  String _imgQuality     = 'High';

  @override
  void dispose() {
    _customRangeCtrl.dispose();
    _splitRangeCtrl.dispose();
    _splitNCtrl.dispose();
    super.dispose();
  }

  void _notify() {
    widget.onOptionsChanged({
      'ocrEnabled'       : _ocrEnabled,
      'preserveFormat'   : _preserveFormat,
      'autoDelete'       : _autoDelete,
      'removeMetadata'   : _removeMetadata,
      'transparentBg'    : _transparentBg,
      'fitToPage'        : _fitToPage,
      'imageFormat'      : _imageFormat,
      'imageQuality'     : _imageQuality,
      'pageRange'        : _pageRange,
      'customRange'      : _customRangeCtrl.text,
      'compressionLevel' : _compressionLevel,
      'splitRadio'       : _splitRadio,
      'splitRange'       : _splitRangeCtrl.text,
      'splitN'           : _splitNCtrl.text,
      'pageSize'         : _pageSize,
      'orientation'      : _orientation,
      'imgQuality'       : _imgQuality,
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    switch (widget.tool.id) {
      case 'pdf_to_word':
        return _pdfToWordOptions();
      case 'word_to_pdf':
        return _wordToPdfOptions();
      case 'image_to_pdf':
        return _imageToPdfOptions();
      case 'pdf_to_image':
        return _pdfToImageOptions();
      case 'compress_pdf':
        return _compressPdfOptions();
      case 'split_pdf':
        return _splitPdfOptions();
      case 'jpg_to_png':
      case 'png_to_jpg':
        return _imageConvertOptions();
      default:
        // word_to_pdf, pdf_to_ppt, ppt_to_pdf, excel_to_pdf, merge_pdfs
        return _genericOptions();
    }
  }

  // ── Option Panels ─────────────────────────────────────────────────────────

  Widget _pdfToWordOptions() {
    return _OptionsCard(
      accentColor: widget.tool.accentColor,
      children: [
        _SwitchTile(
          label     : 'OCR Enabled',
          subtitle  : 'Extract text from scanned PDFs',
          value     : _ocrEnabled,
          color     : widget.tool.accentColor,
          onChanged : (v) { setState(() => _ocrEnabled = v); _notify(); },
        ),
        _SwitchTile(
          label    : 'Secure SSL',
          subtitle : 'Encrypted transfer (always on)',
          value    : true,
          color    : widget.tool.accentColor,
          locked   : true,
          onChanged: (_) {},
        ),
        _SwitchTile(
          label     : 'Auto-delete after 1h',
          subtitle  : 'Remove file from server after download',
          value     : _autoDelete,
          color     : widget.tool.accentColor,
          onChanged : (v) { setState(() => _autoDelete = v); _notify(); },
        ),
      ],
    );
  }

  Widget _wordToPdfOptions() {
    return _OptionsCard(
      accentColor: widget.tool.accentColor,
      children: [
        _SwitchTile(
          label     : 'Preserve Formatting',
          subtitle  : 'Keep fonts, styles and layout',
          value     : _preserveFormat,
          color     : widget.tool.accentColor,
          onChanged : (v) { setState(() => _preserveFormat = v); _notify(); },
        ),
        _SwitchTile(
          label    : 'Secure SSL',
          subtitle : 'Encrypted transfer (always on)',
          value    : true,
          color    : widget.tool.accentColor,
          locked   : true,
          onChanged: (_) {},
        ),
        _SwitchTile(
          label     : 'Auto-delete after 1h',
          subtitle  : 'Remove file from server after download',
          value     : _autoDelete,
          color     : widget.tool.accentColor,
          onChanged : (v) { setState(() => _autoDelete = v); _notify(); },
        ),
      ],
    );
  }

  Widget _imageToPdfOptions() {
    return _OptionsCard(
      accentColor: widget.tool.accentColor,
      children: [
        _DropdownTile(
          label   : 'Page Size',
          value   : _pageSize,
          options : const ['A4', 'Letter', 'Auto'],
          color   : widget.tool.accentColor,
          onChanged: (v) { setState(() => _pageSize = v!); _notify(); },
        ),
        _DropdownTile(
          label   : 'Orientation',
          value   : _orientation,
          options : const ['Portrait', 'Landscape'],
          color   : widget.tool.accentColor,
          onChanged: (v) { setState(() => _orientation = v!); _notify(); },
        ),
        _SwitchTile(
          label     : 'Fit image to page',
          subtitle  : 'Scale image to fill the page',
          value     : _fitToPage,
          color     : widget.tool.accentColor,
          onChanged : (v) { setState(() => _fitToPage = v); _notify(); },
        ),
        _SwitchTile(
          label     : 'Auto-delete after 1h',
          subtitle  : 'Remove file from server after download',
          value     : _autoDelete,
          color     : widget.tool.accentColor,
          onChanged : (v) { setState(() => _autoDelete = v); _notify(); },
        ),
      ],
    );
  }

  Widget _pdfToImageOptions() {
    return _OptionsCard(
      accentColor: widget.tool.accentColor,
      children: [
        _DropdownTile(
          label   : 'Output Format',
          value   : _imageFormat,
          options : const ['JPG', 'PNG', 'WEBP'],
          color   : widget.tool.accentColor,
          onChanged: (v) { setState(() => _imageFormat = v!); _notify(); },
        ),
        _DropdownTile(
          label   : 'Quality',
          value   : _imageQuality,
          options : const ['Low', 'Medium', 'High', 'Ultra'],
          color   : widget.tool.accentColor,
          onChanged: (v) { setState(() => _imageQuality = v!); _notify(); },
        ),
        _DropdownTile(
          label   : 'Pages',
          value   : _pageRange,
          options : const ['All Pages', 'Custom Range'],
          color   : widget.tool.accentColor,
          onChanged: (v) { setState(() => _pageRange = v!); _notify(); },
        ),
        if (_pageRange == 'Custom Range')
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller  : _customRangeCtrl,
              onChanged   : (_) => _notify(),
              decoration  : InputDecoration(
                hintText     : 'e.g. 1-3, 5, 7',
                prefixIcon   : const Icon(Icons.pages_rounded, size: 18),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide  : BorderSide(
                      color: widget.tool.accentColor, width: 1.5),
                ),
              ),
              keyboardType: TextInputType.text,
            ),
          ),
      ],
    );
  }

  Widget _compressPdfOptions() {
    final labels = ['Low', 'Medium', 'High'];
    final label  = labels[_compressionLevel.toInt()];

    return _OptionsCard(
      accentColor: widget.tool.accentColor,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Compression Level',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  Container(
                    padding    : const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration : BoxDecoration(
                      color        : widget.tool.accentColor.withOpacity(0.15),
                      borderRadius : BorderRadius.circular(20),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize   : 12,
                        fontWeight : FontWeight.bold,
                        color      : widget.tool.accentColor,
                      ),
                    ),
                  ),
                ],
              ),
              Slider(
                value    : _compressionLevel,
                min      : 0,
                max      : 2,
                divisions: 2,
                onChanged: (v) {
                  setState(() => _compressionLevel = v);
                  _notify();
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['Low', 'Medium', 'High']
                    .map((l) => Text(l,
                        style: TextStyle(
                            fontSize: 11,
                            color: widget.tool.accentColor
                                .withOpacity(0.7))))
                    .toList(),
              ),
              const SizedBox(height: 4),
              Text(
                label == 'Low'
                    ? '🟢 Estimated reduction: ~20%'
                    : label == 'Medium'
                        ? '🟡 Estimated reduction: ~50%'
                        : '🔴 Estimated reduction: ~75%',
                style: const TextStyle(
                    fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        _SwitchTile(
          label     : 'Remove Metadata',
          subtitle  : 'Strip author, keywords, etc.',
          value     : _removeMetadata,
          color     : widget.tool.accentColor,
          onChanged : (v) { setState(() => _removeMetadata = v); _notify(); },
        ),
        _SwitchTile(
          label     : 'Auto-delete after 1h',
          subtitle  : 'Remove file from server after download',
          value     : _autoDelete,
          color     : widget.tool.accentColor,
          onChanged : (v) { setState(() => _autoDelete = v); _notify(); },
        ),
      ],
    );
  }

  Widget _splitPdfOptions() {
    return _OptionsCard(
      accentColor: widget.tool.accentColor,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: const Text('Split Method',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ),

        // Radio options
        ...[
          'Extract all pages separately',
          'Split by page range',
          'Split every N pages',
        ].asMap().entries.map((e) {
          return RadioListTile<int>(
            value      : e.key,
            groupValue : _splitRadio,
            activeColor: widget.tool.accentColor,
            title: Text(e.value,
                style: const TextStyle(fontSize: 13)),
            onChanged: (v) {
              setState(() => _splitRadio = v!);
              _notify();
            },
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16),
            dense: true,
          );
        }),

        if (_splitRadio == 1)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              controller: _splitRangeCtrl,
              onChanged : (_) => _notify(),
              decoration: InputDecoration(
                hintText : 'e.g. 1-3, 5, 7',
                prefixIcon: const Icon(Icons.pages_rounded, size: 18),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide  : BorderSide(
                      color: widget.tool.accentColor, width: 1.5),
                ),
              ),
            ),
          ),

        if (_splitRadio == 2)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              controller  : _splitNCtrl,
              onChanged   : (_) => _notify(),
              keyboardType: TextInputType.number,
              decoration  : InputDecoration(
                hintText : 'Number of pages e.g. 2',
                prefixIcon: const Icon(Icons.filter_none_rounded, size: 18),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide  : BorderSide(
                      color: widget.tool.accentColor, width: 1.5),
                ),
              ),
            ),
          ),

        const SizedBox(height: 4),
      ],
    );
  }

  Widget _imageConvertOptions() {
    final isPngOutput = widget.tool.id == 'jpg_to_png';

    return _OptionsCard(
      accentColor: widget.tool.accentColor,
      children: [
        _DropdownTile(
          label   : 'Quality',
          value   : _imgQuality,
          options : const ['Lossless', 'High', 'Medium'],
          color   : widget.tool.accentColor,
          onChanged: (v) { setState(() => _imgQuality = v!); _notify(); },
        ),
        if (isPngOutput)
          _SwitchTile(
            label     : 'Transparent Background',
            subtitle  : 'Remove white background (PNG only)',
            value     : _transparentBg,
            color     : widget.tool.accentColor,
            onChanged : (v) {
              setState(() => _transparentBg = v);
              _notify();
            },
          ),
      ],
    );
  }

  Widget _genericOptions() {
    return _OptionsCard(
      accentColor: widget.tool.accentColor,
      children: [
        _SwitchTile(
          label     : 'Preserve Formatting',
          subtitle  : 'Keep fonts, styles and layout',
          value     : _preserveFormat,
          color     : widget.tool.accentColor,
          onChanged : (v) { setState(() => _preserveFormat = v); _notify(); },
        ),
        _SwitchTile(
          label    : 'Secure SSL',
          subtitle : 'Encrypted transfer (always on)',
          value    : true,
          color    : widget.tool.accentColor,
          locked   : true,
          onChanged: (_) {},
        ),
        _SwitchTile(
          label     : 'Auto-delete after 1h',
          subtitle  : 'Remove file from server after download',
          value     : _autoDelete,
          color     : widget.tool.accentColor,
          onChanged : (v) { setState(() => _autoDelete = v); _notify(); },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helper widgets
// ─────────────────────────────────────────────────────────────────────────────

class _OptionsCard extends StatelessWidget {
  const _OptionsCard({
    required this.accentColor,
    required this.children,
  });

  final Color         accentColor;
  final List<Widget>  children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width      : double.infinity,
      decoration : BoxDecoration(
        color        : isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius : BorderRadius.circular(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Icon(Icons.tune_rounded, size: 16, color: accentColor),
                const SizedBox(width: 6),
                Text(
                  'Conversion Options',
                  style: TextStyle(
                    fontSize   : 14,
                    fontWeight : FontWeight.bold,
                    color      : accentColor,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.label,
    required this.value,
    required this.color,
    required this.onChanged,
    this.subtitle,
    this.locked = false,
  });

  final String            label;
  final String?           subtitle;
  final bool              value;
  final Color             color;
  final bool              locked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title    : Text(label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      subtitle : subtitle != null
          ? Text(subtitle!,
              style: const TextStyle(fontSize: 11, color: Colors.grey))
          : null,
      value    : value,
      activeColor: color,
      onChanged  : locked ? null : onChanged,
      dense      : true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}

class _DropdownTile extends StatelessWidget {
  const _DropdownTile({
    required this.label,
    required this.value,
    required this.options,
    required this.color,
    required this.onChanged,
  });

  final String                  label;
  final String                  value;
  final List<String>            options;
  final Color                   color;
  final ValueChanged<String?>   onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          Container(
            padding    : const EdgeInsets.symmetric(
                horizontal: 12, vertical: 4),
            decoration : BoxDecoration(
              color        : isDark
                  ? const Color(0xFF2A2A2A)
                  : const Color(0xFFF5F5F5),
              borderRadius : BorderRadius.circular(10),
              border: Border.all(
                color: color.withOpacity(0.3),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value     : value,
                isDense   : true,
                icon      : Icon(Icons.keyboard_arrow_down_rounded,
                    size: 16, color : color),
                style     : TextStyle(
                    fontSize   : 13,
                    fontWeight : FontWeight.w600,
                    color      : isDark ? Colors.white : const Color(0xFF212121)),
                items     : options
                    .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                    .toList(),
                onChanged : onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// lib/constants/tools_data.dart

import 'package:flutter/material.dart';
import '../models/tool_model.dart';
import 'app_colors.dart';

/// Complete list of all 12 conversion tools.
/// Order matters — the first 6 appear on the Home screen grid.
const List<ToolModel> kAllTools = [

  // ── 1. PDF to Word ────────────────────────────────────────────────────────
  ToolModel(
    id            : 'pdf_to_word',
    name          : 'PDF to Word',
    description   : 'Convert PDF documents into editable Word files',
    icon          : Icons.picture_as_pdf_rounded,
    accentColor   : AppColors.pdfToWord,
    inputFormat   : 'pdf',
    outputFormat  : 'docx',
    inputLabel    : 'Select a PDF file',
    acceptedFiles : 'pdf',
    category      : 'PDF',
  ),

  // ── 2. Word to PDF ────────────────────────────────────────────────────────
  ToolModel(
    id            : 'word_to_pdf',
    name          : 'Word to PDF',
    description   : 'Turn Word documents into shareable PDF files',
    icon          : Icons.description_rounded,
    accentColor   : AppColors.wordToPdf,
    inputFormat   : 'docx',
    outputFormat  : 'pdf',
    inputLabel    : 'Select a Word file',
    acceptedFiles : 'docx,doc',
    category      : 'Word',
  ),

  // ── 3. Image to PDF ───────────────────────────────────────────────────────
  ToolModel(
    id            : 'image_to_pdf',
    name          : 'Image to PDF',
    description   : 'Combine one or more images into a single PDF',
    icon          : Icons.image_rounded,
    accentColor   : AppColors.imageToPdf,
    inputFormat   : 'jpg,png',
    outputFormat  : 'pdf',
    inputLabel    : 'Select image(s)',
    acceptedFiles : 'jpg,jpeg,png',
    needsMultiFile: true,
    category      : 'Image',
  ),

  // ── 4. PDF to Image ───────────────────────────────────────────────────────
  ToolModel(
    id            : 'pdf_to_image',
    name          : 'PDF to Image',
    description   : 'Extract pages from a PDF as JPG or PNG images',
    icon          : Icons.photo_library_rounded,
    accentColor   : AppColors.pdfToImage,
    inputFormat   : 'pdf',
    outputFormat  : 'jpg',
    inputLabel    : 'Select a PDF file',
    acceptedFiles : 'pdf',
    category      : 'Image',
  ),

  // ── 5. Compress PDF ───────────────────────────────────────────────────────
  ToolModel(
    id            : 'compress_pdf',
    name          : 'Compress PDF',
    description   : 'Reduce PDF file size without losing quality',
    icon          : Icons.compress_rounded,
    accentColor   : AppColors.compressPdf,
    inputFormat   : 'pdf',
    outputFormat  : 'pdf',
    inputLabel    : 'Select a PDF file',
    acceptedFiles : 'pdf',
    category      : 'Compress',
  ),

  // ── 6. Merge PDFs ─────────────────────────────────────────────────────────
  ToolModel(
    id            : 'merge_pdfs',
    name          : 'Merge PDFs',
    description   : 'Combine multiple PDF files into one document',
    icon          : Icons.merge_rounded,
    accentColor   : AppColors.mergePdfs,
    inputFormat   : 'pdf',
    outputFormat  : 'pdf',
    inputLabel    : 'Select PDF files (min 2)',
    acceptedFiles : 'pdf',
    needsMultiFile: true,
    category      : 'Merge',
  ),

  // ── 7. Split PDF ──────────────────────────────────────────────────────────
  ToolModel(
    id            : 'split_pdf',
    name          : 'Split PDF',
    description   : 'Extract pages or split a PDF into multiple files',
    icon          : Icons.call_split_rounded,
    accentColor   : AppColors.splitPdf,
    inputFormat   : 'pdf',
    outputFormat  : 'pdf',
    inputLabel    : 'Select a PDF file',
    acceptedFiles : 'pdf',
    category      : 'PDF',
  ),

  // ── 8. JPG to PNG ─────────────────────────────────────────────────────────
  ToolModel(
    id                : 'jpg_to_png',
    name              : 'JPG to PNG',
    description       : 'Convert JPG images to lossless PNG format',
    icon              : Icons.photo_rounded,
    accentColor       : AppColors.jpgToPng,
    inputFormat       : 'jpg',
    outputFormat      : 'png',
    inputLabel        : 'Select a JPG file',
    acceptedFiles     : 'jpg,jpeg',
    category          : 'Image',
    isLocalConversion : true,
  ),

  // ── 9. PNG to JPG ─────────────────────────────────────────────────────────
  ToolModel(
    id                : 'png_to_jpg',
    name              : 'PNG to JPG',
    description       : 'Convert PNG images to compressed JPG format',
    icon              : Icons.image_rounded,
    accentColor       : AppColors.pngToJpg,
    inputFormat       : 'png',
    outputFormat      : 'jpg',
    inputLabel        : 'Select a PNG file',
    acceptedFiles     : 'png',
    category          : 'Image',
    isLocalConversion : true,
  ),

  // ── 10. PDF to PPT ────────────────────────────────────────────────────────
  ToolModel(
    id            : 'pdf_to_ppt',
    name          : 'PDF to PPT',
    description   : 'Convert PDF slides into editable PowerPoint files',
    icon          : Icons.slideshow_rounded,
    accentColor   : AppColors.pdfToPpt,
    inputFormat   : 'pdf',
    outputFormat  : 'pptx',
    inputLabel    : 'Select a PDF file',
    acceptedFiles : 'pdf',
    category      : 'PDF',
  ),

  // ── 11. PPT to PDF ────────────────────────────────────────────────────────
  ToolModel(
    id            : 'ppt_to_pdf',
    name          : 'PPT to PDF',
    description   : 'Convert PowerPoint presentations to PDF format',
    icon          : Icons.present_to_all_rounded,
    accentColor   : AppColors.pptToPdf,
    inputFormat   : 'pptx',
    outputFormat  : 'pdf',
    inputLabel    : 'Select a PowerPoint file',
    acceptedFiles : 'pptx,ppt',
    category      : 'Word',
  ),

  // ── 12. Excel to PDF ──────────────────────────────────────────────────────
  ToolModel(
    id            : 'excel_to_pdf',
    name          : 'Excel to PDF',
    description   : 'Turn Excel spreadsheets into PDF documents',
    icon          : Icons.table_chart_rounded,
    accentColor   : AppColors.excelToPdf,
    inputFormat   : 'xlsx',
    outputFormat  : 'pdf',
    inputLabel    : 'Select an Excel file',
    acceptedFiles : 'xlsx,xls',
    category      : 'Word',
  ),
];

/// Quick lookup by tool ID.
ToolModel? toolById(String id) {
  try {
    return kAllTools.firstWhere((t) => t.id == id);
  } catch (_) {
    return null;
  }
}

/// All unique category labels (for filter chips).
List<String> get kToolCategories {
  final seen = <String>{};
  return ['All', ...kAllTools.map((t) => t.category).where(seen.add)];
}
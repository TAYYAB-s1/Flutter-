// lib/models/tool_model.dart

import 'package:flutter/material.dart';

class ToolModel {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color accentColor;
  final String inputFormat;   // e.g. "pdf"
  final String outputFormat;  // e.g. "docx"
  final String inputLabel;    // e.g. "Select a PDF file"
  final String acceptedFiles; // e.g. ".pdf"
  final bool needsMultiFile;  // true for Merge PDFs
  final String category;      // "PDF" | "Word" | "Image" | "Compress" | "Merge"
  final bool isLocalConversion; // true = uses dart image pkg, false = CloudConvert

  const ToolModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.inputFormat,
    required this.outputFormat,
    required this.inputLabel,
    required this.acceptedFiles,
    this.needsMultiFile     = false,
    required this.category,
    this.isLocalConversion  = false,
  });
}
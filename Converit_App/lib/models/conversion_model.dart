// lib/models/conversion_model.dart

import 'dart:convert';
import 'package:flutter/material.dart';

class ConversionModel {
  final String id;
  final String toolId;
  final String toolName;
  final String inputFileName;
  final String outputFileName;
  final String outputFilePath;  // local path after download
  final String downloadUrl;     // CloudConvert URL (valid 24 h)
  final int fileSizeBytes;
  final DateTime convertedAt;
  final int durationSeconds;
  final Color toolColor;

  const ConversionModel({
    required this.id,
    required this.toolId,
    required this.toolName,
    required this.inputFileName,
    required this.outputFileName,
    required this.outputFilePath,
    required this.downloadUrl,
    required this.fileSizeBytes,
    required this.convertedAt,
    required this.durationSeconds,
    required this.toolColor,
  });

  // ── Serialisation ─────────────────────────────────────────────────────────

  Map<String, dynamic> toMap() => {
    'id'             : id,
    'toolId'         : toolId,
    'toolName'       : toolName,
    'inputFileName'  : inputFileName,
    'outputFileName' : outputFileName,
    'outputFilePath' : outputFilePath,
    'downloadUrl'    : downloadUrl,
    'fileSizeBytes'  : fileSizeBytes,
    'convertedAt'    : convertedAt.toIso8601String(),
    'durationSeconds': durationSeconds,
    'toolColor'      : toolColor.value,
  };

  factory ConversionModel.fromMap(Map<String, dynamic> map) => ConversionModel(
    id             : map['id']              as String,
    toolId         : map['toolId']          as String,
    toolName       : map['toolName']        as String,
    inputFileName  : map['inputFileName']   as String,
    outputFileName : map['outputFileName']  as String,
    outputFilePath : map['outputFilePath']  as String,
    downloadUrl    : map['downloadUrl']     as String,
    fileSizeBytes  : map['fileSizeBytes']   as int,
    convertedAt    : DateTime.parse(map['convertedAt'] as String),
    durationSeconds: map['durationSeconds'] as int,
    toolColor      : Color(map['toolColor'] as int),
  );

  String toJson()                          => jsonEncode(toMap());
  factory ConversionModel.fromJson(String source) =>
      ConversionModel.fromMap(jsonDecode(source) as Map<String, dynamic>);

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Human-readable file size  e.g. "1.4 MB"
  String get formattedSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Human-readable duration  e.g. "3s" or "1m 12s"
  String get formattedDuration {
    if (durationSeconds < 60) return '${durationSeconds}s';
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return '${m}m ${s}s';
  }
}
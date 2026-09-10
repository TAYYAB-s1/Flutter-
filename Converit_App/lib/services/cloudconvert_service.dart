// lib/services/cloudconvert_service.dart

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

// ─────────────────────────────────────────────────────────────────────────────
// ⚠️  REPLACE WITH YOUR CLOUDCONVERT API KEY
//     Get free key: https://cloudconvert.com/dashboard/api/v2/keys
// ─────────────────────────────────────────────────────────────────────────────
const String kCloudConvertApiKey = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiZDQxOTlkOGU0OWM2YTMwZGQxNzBmNmRlOWFkYmQxMDNjMWIzZTMzYjEzYjk3NTYxNTEzYmU1ZjM3MzAxYzdmZTZmNjBjYTQ0MjM5NzgwMGQiLCJpYXQiOjE3ODM4NzU3NDEuODg0MTgyLCJuYmYiOjE3ODM4NzU3NDEuODg0MTg0LCJleHAiOjQ5Mzk1NDkzNDEuODc2MDM5LCJzdWIiOiI3NjI3OTMzOCIsInNjb3BlcyI6WyJ1c2VyLnJlYWQiLCJ1c2VyLndyaXRlIiwidGFzay5yZWFkIiwidGFzay53cml0ZSIsIndlYmhvb2sucmVhZCIsIndlYmhvb2sud3JpdGUiLCJwcmVzZXQucmVhZCIsInByZXNldC53cml0ZSJdfQ.he6TKJ0AIcxkFCScdb3vHBXNk4y7iP2IK2wH14s7S1AkHltp65p-WLfhEifkukYyA_6p9GXsBth6_eXS_1g68KXlMpbtl_YpPVm2gEittAHjqEGzjA1OcSofCgdMaacR-TzY5YO9CHCuN64YsdQSKLC__6z0XlPd40NsAoxr5Ci_L96XWQCyNQ15DN-dtCSEdVAXZ0Hj6JD4wvVXYK_lGwo0dab_wcg9STbRecPZ6EaBnpVZDztdCTEDdQNI3V--mOzC-bZcG6R_r0N_cplD5F85LtuSEtYX1JA7lBTBCqUHl02Ao40deahvDCJljz0Nwge1bq6gE2aUsKQUKLlQGPBkMaOEg9wQ6viPSthcopGda0Ydu_HrDiUDxMQC84dguwPW0exRKvDkLQwiQgBN4U31__ULCIgC3hC0dYXh4JYMXUUpnw3f9ZkSGdPyOK6kwAm6xrCo0xO0ZryeRCRzSjNL-cw5-dhRHpI8vCF4btftfQCkzrsCvSRDXrF5FN-zEzyZ3-iuO2z7G0Jf6RbYH_orBtPb7_SBK8oPg0sr0nxmdp7cnY_QBbipMOnZ_MWQMkosGUEpKRUBXJR3nSguJHMFTwf5lgN6XF0ZBV4S0R6_h95nqBxq-q7xlCtM4lKFicAEVzvMlrlhzXWl8A6n6tD4caBxiAWKvJU6B80hZgI';
const String kBaseUrl            = 'https://api.cloudconvert.com/v2';

// ─────────────────────────────────────────────────────────────────────────────
// ConversionResult
// ─────────────────────────────────────────────────────────────────────────────

class ConversionResult {
  final bool    success;
  final String? downloadUrl;
  final String? outputFileName;
  final int?    fileSizeBytes;
  final String? errorMessage;

  const ConversionResult._({
    required this.success,
    this.downloadUrl,
    this.outputFileName,
    this.fileSizeBytes,
    this.errorMessage,
  });

  factory ConversionResult.ok({
    required String downloadUrl,
    required String outputFileName,
    required int    fileSizeBytes,
  }) => ConversionResult._(
    success        : true,
    downloadUrl    : downloadUrl,
    outputFileName : outputFileName,
    fileSizeBytes  : fileSizeBytes,
  );

  factory ConversionResult.fail(String message) =>
      ConversionResult._(success: false, errorMessage: message);
}

// ─────────────────────────────────────────────────────────────────────────────
// CloudConvertService — singleton
// ─────────────────────────────────────────────────────────────────────────────

class CloudConvertService {
  CloudConvertService._();
  static final CloudConvertService instance = CloudConvertService._();

  final _client = http.Client();
  final _dio    = Dio();

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $kCloudConvertApiKey',
    'Content-Type' : 'application/json',
  };

  // ═══════════════════════════════════════════════════════════════════════════
  // PUBLIC — convert() — works on both web and mobile
  // Accepts either filePath (mobile) or fileBytes (web)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<ConversionResult> convert({
    required String              toolId,
    required String              inputFormat,
    required String              outputFormat,
    required String              fileName,
    String?                      filePath,   // mobile only
    Uint8List?                   fileBytes,  // web only
    Map<String, dynamic>         options    = const {},
    void Function(int percent)?  onProgress,
  }) async {
    if (kCloudConvertApiKey == 'YOUR_CLOUDCONVERT_API_KEY_HERE') {
      return ConversionResult.fail(
        'CloudConvert API key is not set.\n'
        'Open lib/services/cloudconvert_service.dart and replace '
        'kCloudConvertApiKey with your real key from cloudconvert.com.',
      );
    }

    // Get file bytes — from path on mobile, directly on web
    Uint8List bytes;
    try {
      if (fileBytes != null) {
        bytes = fileBytes;
      } else if (filePath != null && !kIsWeb) {
        bytes = await File(filePath).readAsBytes();
      } else {
        return ConversionResult.fail(
            'No file data available. Please select the file again.');
      }
    } catch (e) {
      return ConversionResult.fail('Could not read file: $e');
    }

    // Guard: 50 MB limit
    if (bytes.length > 50 * 1024 * 1024) {
      return ConversionResult.fail(
          'File exceeds the 50 MB limit. Please choose a smaller file.');
    }

    try {
      // Step 1 — Create job
      onProgress?.call(5);
      final jobData = await _createJob(
        inputFormat  : inputFormat,
        outputFormat : outputFormat,
        toolId       : toolId,
        options      : options,
      );
      if (jobData == null) {
        return ConversionResult.fail(
            'Could not create conversion job. Check your API key.');
      }

      final String jobId     = jobData['jobId'] as String;
      final String uploadUrl = jobData['uploadUrl'] as String;
      final Map<String, dynamic> uploadFields =
          jobData['fields'] as Map<String, dynamic>? ?? {};

      // Step 2 — Upload bytes
      onProgress?.call(20);
      final uploaded = await _uploadBytes(
        uploadUrl : uploadUrl,
        fields    : uploadFields,
        bytes     : bytes,
        fileName  : fileName,
      );
      if (!uploaded) {
        return ConversionResult.fail(
            'File upload failed. Check your internet connection.');
      }

      // Step 3 — Poll
      onProgress?.call(40);
      final jobResult = await _pollJob(
        jobId      : jobId,
        onProgress : onProgress,
      );
      if (jobResult == null) {
        return ConversionResult.fail(
            'Conversion failed or timed out. Please try again.');
      }

      onProgress?.call(100);
      return ConversionResult.ok(
        downloadUrl    : jobResult['url']!,
        outputFileName : jobResult['filename']!,
        fileSizeBytes  : jobResult['size'] ?? 0,
      );

    } on SocketException {
      return ConversionResult.fail(
          'No internet connection. Please check your network.');
    } on TimeoutException {
      return ConversionResult.fail(
          'Connection timed out. Please try again.');
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('limit')) {
        return ConversionResult.fail(
            'Daily conversion limit reached. Try again tomorrow.');
      }
      if (msg.contains('Invalid') || msg.contains('401')) {
        return ConversionResult.fail(
            'Invalid API key. Check your CloudConvert key.');
      }
      return ConversionResult.fail('Unexpected error: $msg');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 1 — Create Job
  // ═══════════════════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>?> _createJob({
    required String              inputFormat,
    required String              outputFormat,
    required String              toolId,
    required Map<String, dynamic> options,
  }) async {
    final tasks = <String, dynamic>{
      'upload-file': {'operation': 'import/upload'},
      'convert-file': {
        'operation'    : 'convert',
        'input'        : 'upload-file',
        'input_format' : inputFormat,
        'output_format': outputFormat,
        ..._buildConvertOptions(toolId: toolId, options: options),
      },
      'export-file': {
        'operation': 'export/url',
        'input'    : 'convert-file',
      },
    };

    final response = await _client
        .post(
          Uri.parse('$kBaseUrl/jobs'),
          headers: _headers,
          body   : jsonEncode({'tasks': tasks}),
        )
        .timeout(const Duration(seconds: 30));

    debugPrint('CreateJob status: ${response.statusCode}');
    debugPrint('CreateJob body: ${response.body}');

    if (response.statusCode == 402) throw Exception('Daily limit reached');
    if (response.statusCode == 401) throw Exception('Invalid API key');
    if (response.statusCode != 201) return null;

    final body      = jsonDecode(response.body) as Map<String, dynamic>;
    final data      = body['data']  as Map<String, dynamic>;
    final jobId     = data['id']    as String;
    final tasksList = data['tasks'] as List<dynamic>;

    for (final task in tasksList) {
      final t = task as Map<String, dynamic>;
      if (t['name'] == 'upload-file') {
        final result    = t['result']         as Map<String, dynamic>?;
        final form      = result?['form']     as Map<String, dynamic>?;
        final uploadUrl = form?['url']        as String?;
        final fields    = form?['parameters'] as Map<String, dynamic>?;
        if (uploadUrl != null) {
          return {
            'jobId'    : jobId,
            'uploadUrl': uploadUrl,
            'fields'   : fields ?? <String, dynamic>{},
          };
        }
      }
    }
    return null;
  }

  Map<String, dynamic> _buildConvertOptions({
    required String              toolId,
    required Map<String, dynamic> options,
  }) {
    switch (toolId) {
      case 'pdf_to_word':
        return {'ocr': options['ocrEnabled'] ?? true};
      case 'word_to_pdf':
      case 'ppt_to_pdf':
      case 'excel_to_pdf':
      case 'pdf_to_ppt':
        return {'engine': 'libreoffice'};
      case 'image_to_pdf':
        return {
          'engine'     : 'graphicsmagick',
          'page_size'  : (options['pageSize'] as String? ?? 'A4').toLowerCase(),
          'orientation': (options['orientation'] as String? ?? 'Portrait').toLowerCase(),
          'fit'        : options['fitToPage'] ?? true,
        };
      case 'pdf_to_image':
        return {
          'output_format': (options['imageFormat'] as String? ?? 'jpg').toLowerCase(),
          'quality'      : _qualityToInt(options['imageQuality'] as String? ?? 'High'),
        };
      case 'compress_pdf':
        final level = (options['compressionLevel'] as num?)?.toInt() ?? 1;
        return {
          'engine' : 'ghostscript',
          'quality': ['screen', 'ebook', 'printer'][level],
        };
      case 'split_pdf':
        final radio = (options['splitRadio'] as int?) ?? 0;
        if (radio == 1) return {'engine': 'pdfcpu', 'pages': options['splitRange'] ?? ''};
        if (radio == 2) return {'engine': 'pdfcpu', 'split_size': int.tryParse(options['splitN'] as String? ?? '1') ?? 1};
        return {'engine': 'pdfcpu', 'split_size': 1};
      case 'merge_pdfs':
        return {'engine': 'pdfcpu'};
      default:
        return {};
    }
  }

  int _qualityToInt(String q) {
    switch (q) {
      case 'Ultra' : return 100;
      case 'High'  : return 80;
      case 'Medium': return 60;
      case 'Low'   : return 40;
      default      : return 80;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 2 — Upload bytes (works on web + mobile)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<bool> _uploadBytes({
    required String               uploadUrl,
    required Map<String, dynamic> fields,
    required Uint8List            bytes,
    required String               fileName,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));

      fields.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: fileName),
      );

      final response =
          await request.send().timeout(const Duration(minutes: 5));

      final respBody = await response.stream.bytesToString();
      debugPrint('Upload status: ${response.statusCode}');
      debugPrint('Upload response: $respBody');

      return response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204;
    } catch (e) {
      debugPrint('Upload exception: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 3 — Poll job status
  // ═══════════════════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>?> _pollJob({
    required String             jobId,
    void Function(int percent)? onProgress,
    int maxAttempts = 60,
  }) async {
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      await Future.delayed(const Duration(seconds: 2));

      try {
        final response = await _client
            .get(Uri.parse('$kBaseUrl/jobs/$jobId'), headers: _headers)
            .timeout(const Duration(seconds: 15));

        if (response.statusCode != 200) continue;

        final body   = jsonDecode(response.body) as Map<String, dynamic>;
        final data   = body['data']   as Map<String, dynamic>;
        final status = data['status'] as String;

        final pct = (40 + (attempt / maxAttempts) * 55).toInt().clamp(40, 95);
        onProgress?.call(pct);

        if (status == 'finished') return _extractDownloadInfo(data);

        if (status == 'error') {
          final tasks  = data['tasks'] as List<dynamic>;
          final failed = tasks.firstWhere(
            (t) => (t as Map)['status'] == 'error',
            orElse: () => <String, dynamic>{},
          ) as Map<String, dynamic>;
          throw Exception(failed['message'] ?? 'Conversion failed.');
        }
      } catch (e) {
        if (e.toString().contains('failed') || e.toString().contains('error')) rethrow;
      }
    }
    return null;
  }

  Map<String, dynamic>? _extractDownloadInfo(Map<String, dynamic> data) {
    try {
      final tasks = data['tasks'] as List<dynamic>;
      for (final task in tasks) {
        final t = task as Map<String, dynamic>;
        if (t['name'] == 'export-file' && t['status'] == 'finished') {
          final files = (t['result'] as Map?)?['files'] as List?;
          if (files != null && files.isNotEmpty) {
            final f = files.first as Map<String, dynamic>;
            return {
              'url'     : f['url']      as String,
              'filename': f['filename'] as String,
              'size'    : f['size']     as int? ?? 0,
            };
          }
        }
      }
    } catch (_) {}
    return null;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DOWNLOAD — triggers browser download on web, saves to disk on mobile
  // ═══════════════════════════════════════════════════════════════════════════

  Future<String?> downloadFile({
    required String downloadUrl,
    required String fileName,
    void Function(int received, int total)? onProgress,
  }) async {
    if (kIsWeb) {
      // On web — open the download URL directly in the browser
      // The browser will handle the file download natively
      return downloadUrl; // treated as "downloaded" on web
    }

    try {
      final dir = await _downloadsDir();
      if (dir == null) return null;

      String savePath = '${dir.path}/$fileName';
      int    counter  = 1;
      while (await File(savePath).exists()) {
        final parts = fileName.split('.');
        final ext   = parts.last;
        final base  = parts.sublist(0, parts.length - 1).join('.');
        savePath = '${dir.path}/${base}_$counter.$ext';
        counter++;
      }

      await _dio.download(
        downloadUrl,
        savePath,
        onReceiveProgress: onProgress,
        options: Options(
          responseType   : ResponseType.bytes,
          followRedirects: true,
          receiveTimeout : const Duration(minutes: 5),
        ),
      );

      return savePath;
    } catch (_) {
      return null;
    }
  }

  Future<Directory?> _downloadsDir() async {
    try {
      if (Platform.isAndroid) {
        final d = Directory('/storage/emulated/0/Download');
        if (await d.exists()) return d;
      }
      if (Platform.isIOS) return await getApplicationDocumentsDirectory();
      return await getDownloadsDirectory();
    } catch (_) {
      return await getTemporaryDirectory();
    }
  }

  Future<void> cancelJob(String jobId) async {
    try {
      await _client
          .delete(Uri.parse('$kBaseUrl/jobs/$jobId'), headers: _headers)
          .timeout(const Duration(seconds: 10));
    } catch (_) {}
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOCAL — JPG ↔ PNG (web-compatible using bytes)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<ConversionResult> convertImageLocally({
    required String              fileName,
    required String              outputFormat,
    String?                      filePath,
    Uint8List?                   fileBytes,
    Map<String, dynamic>         options    = const {},
    void Function(int percent)?  onProgress,
  }) async {
    try {
      onProgress?.call(10);

      Uint8List inputBytes;
      if (fileBytes != null) {
        inputBytes = fileBytes;
      } else if (filePath != null && !kIsWeb) {
        inputBytes = await File(filePath).readAsBytes();
      } else {
        return ConversionResult.fail(
            'No file data available. Please select the file again.');
      }

      onProgress?.call(30);

      final image = img.decodeImage(inputBytes);
      if (image == null) {
        return ConversionResult.fail(
            'Could not read the image. Is it a valid JPG or PNG?');
      }

      onProgress?.call(60);

      List<int> outputBytes;
      String    outputExt;

      if (outputFormat == 'png') {
        outputBytes = img.encodePng(image);
        outputExt   = 'png';
      } else {
        final quality =
            _imgQualityToInt(options['imgQuality'] as String? ?? 'High');
        outputBytes = img.encodeJpg(image, quality: quality);
        outputExt   = 'jpg';
      }

      onProgress?.call(80);

      final baseName   = fileName.split('.').first;
      final outputName = '$baseName.$outputExt';

      // On web — create a data URL so the file can be downloaded in browser
      if (kIsWeb) {
        final base64Data = base64Encode(outputBytes);
        final mimeType   =
            outputExt == 'png' ? 'image/png' : 'image/jpeg';
        final dataUrl = 'data:$mimeType;base64,$base64Data';

        onProgress?.call(100);
        return ConversionResult.ok(
          downloadUrl    : dataUrl,
          outputFileName : outputName,
          fileSizeBytes  : outputBytes.length,
        );
      }

      // On mobile — save to temp dir then copy to Downloads
      final tempDir  = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/$outputName';
      await File(tempPath).writeAsBytes(outputBytes);

      final dir = await _downloadsDir();
      String finalPath = tempPath;
      if (dir != null) {
        finalPath = '${dir.path}/$outputName';
        await File(tempPath).copy(finalPath);
      }

      onProgress?.call(100);

      return ConversionResult.ok(
        downloadUrl    : finalPath,
        outputFileName : outputName,
        fileSizeBytes  : outputBytes.length,
      );
    } catch (e) {
      return ConversionResult.fail('Image conversion failed: $e');
    }
  }

  int _imgQualityToInt(String quality) {
    switch (quality) {
      case 'Lossless': return 100;
      case 'High'    : return 85;
      case 'Medium'  : return 65;
      default        : return 85;
    }
  }
}
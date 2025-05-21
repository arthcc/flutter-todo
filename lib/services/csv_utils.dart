import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:universal_html/html.dart' as html;

class CsvUtils {
  static const String _defaultFileName = 'todos.csv';
  static const String _webStorageKey = 'todos_csv_data';
  
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_defaultFileName');
  }

  static Future<void> saveTodos(List<Map<String, dynamic>> todos) async {
    final headers = ['title', 'description', 'completed', 'priority', 'category'];
    final rows = todos.map((todo) => [
      todo['title'],
      todo['description'],
      todo['completed'].toString(),
      todo['priority'],
      todo['category'],
    ]).toList();

    final csvData = const ListToCsvConverter().convert([headers, ...rows]);
    
    if (kIsWeb) {
      html.window.localStorage[_webStorageKey] = csvData;
    } else {
      final file = await _localFile;
      await file.writeAsString(csvData);
    }
  }

  static Future<List<Map<String, dynamic>>> loadTodos() async {
    try {
      String? content;
      
      if (kIsWeb) {
        content = html.window.localStorage[_webStorageKey];
        if (content == null) return [];
      } else {
        final file = await _localFile;
        if (!await file.exists()) return [];
        content = await file.readAsString();
      }

      final fields = const CsvToListConverter().convert(content!);
      if (fields.isEmpty || fields[0].length < 3) return [];

      return fields.skip(1).map((row) {
        return {
          "title": row[0].toString(),
          "description": row[1].toString(),
          "completed": row[2].toString().toLowerCase() == 'true',
          "priority": row.length > 3 ? row[3].toString() : "Média",
          "category": row.length > 4 ? row[4].toString() : "Outro",
        };
      }).toList();
    } catch (e) {
      print('Erro ao carregar todos: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> importCsv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      final bytes = result.files.single.bytes!;
      final content = utf8.decode(bytes);
      final fields = const CsvToListConverter().convert(content);

      if (fields.isEmpty || fields[0].length < 3) return [];

      return fields.skip(1).map((row) {
        return {
          "title": row[0].toString(),
          "description": row[1].toString(),
          "completed": row[2].toString().toLowerCase() == 'true',
          "priority": row.length > 3 ? row[3].toString() : "Média",
          "category": row.length > 4 ? row[4].toString() : "Outro",
        };
      }).toList();
    }

    return [];
  }

  static Future<String> exportCsv(List<Map<String, dynamic>> todos) async {
    final headers = ['title', 'description', 'completed', 'priority', 'category'];
    final rows = todos.map((todo) => [
      todo['title'],
      todo['description'],
      todo['completed'].toString(),
      todo['priority'],
      todo['category'],
    ]).toList();

    final csvData = const ListToCsvConverter().convert([headers, ...rows]);

    if (kIsWeb) {
      html.window.localStorage[_webStorageKey] = csvData;
      
      final blob = html.Blob([csvData], 'text/csv');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'todos_export.csv')
        ..click();
      html.Url.revokeObjectUrl(url);

      return 'Arquivo CSV exportado e salvo no navegador';
    }

    final hasPermission = await _requestPermission();
    if (!hasPermission) return 'Permissão negada';

    final dir = await getExternalStorageDirectory();
    final file = File('${dir!.path}/todos_export.csv');
    await file.writeAsString(csvData);

    return 'Arquivo salvo em: ${file.path}';
  }

  static Future<bool> _requestPermission() async {
    if (kIsWeb) return true;

    final status = await Permission.storage.request();
    return status.isGranted;
  }
}

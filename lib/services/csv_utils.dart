import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_selector/file_selector.dart';
import 'package:universal_html/html.dart' as html;
import 'package:open_app_file/open_app_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';


class CsvUtils {
  static const String _defaultFileName = 'todos_export.csv';
  static const String _webStorageKey = 'todos_csv_data';

  // 👉 Exporta CSV (com file_saver)
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
        ..setAttribute('download', _defaultFileName)
        ..click();
      html.Url.revokeObjectUrl(url);

      return 'Arquivo exportado no navegador';
    }

    try {
      final bytes = Uint8List.fromList(utf8.encode(csvData));

      // Salva arquivo temporário
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/todos_export.csv';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // Salva com file_saver (para Downloads)
      await FileSaver.instance.saveFile(
        name: 'todos_export',
        bytes: bytes,
        ext: 'csv',
        mimeType: MimeType.csv,
      );

      // Abre o arquivo local
      await OpenAppFile.open(filePath);

      return 'Arquivo exportado com sucesso.';
    } catch (e) {
      return 'Erro ao exportar: $e';
    }
  }



  // 👉 Importa CSV com file_selector
  static Future<List<Map<String, dynamic>>> importCsv() async {
    try {
      const typeGroup = XTypeGroup(label: 'csv', extensions: ['csv']);
      final file = await openFile(acceptedTypeGroups: [typeGroup]);
      if (file == null) return [];

      final content = utf8.decode(await file.readAsBytes());
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
    } catch (e) {
      print('Erro ao importar CSV: $e');
      return [];
    }
  }

  // 👉 Salvamento local simplificado (web apenas)
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
      print('saveTodos chamado, mas não salva localmente com file_saver.');
    }
  }

  // 👉 Carregamento local simplificado (web apenas)
  static Future<List<Map<String, dynamic>>> loadTodos() async {
    if (!kIsWeb) return [];

    try {
      final content = html.window.localStorage[_webStorageKey];
      if (content == null) return [];

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
    } catch (e) {
      print('Erro ao carregar todos do navegador: $e');
      return [];
    }
  }
}

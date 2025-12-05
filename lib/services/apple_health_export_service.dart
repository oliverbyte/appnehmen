import 'dart:html' as html;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'storage_service.dart';

class AppleHealthExportService {
  /// Export weight data as Apple Health compatible CSV
  static Future<void> exportToAppleHealth() async {
    final storageService = StorageService();
    final history = await storageService.getWeightHistory();
    
    if (history.isEmpty) {
      return;
    }

    // Create CSV content compatible with Apple Health
    final buffer = StringBuffer();
    
    // CSV Header for Apple Health import
    buffer.writeln('Date,Weight (kg)');
    
    // Add all weight entries
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    for (var entry in history) {
      buffer.writeln('${dateFormat.format(entry.date)},${entry.weight}');
    }
    
    // Create downloadable file
    final bytes = utf8.encode(buffer.toString());
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = 'appnehmen_weight_${DateTime.now().millisecondsSinceEpoch}.csv';
    
    html.document.body?.children.add(anchor);
    anchor.click();
    
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }
}

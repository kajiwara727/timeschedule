// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../main.dart'; // TimetableInfoを使うため

class ApiService {
  // ★ ngrokのURLを貼り付けます（最後の / は不要）
  static const String serverUrl = 'https://arlyne-saxicoline-connately.ngrok-free.dev';

  static Future<List<TimetableInfo>> searchClasses({
    required String facultyCode,
    required int year,
    required String semester,
    required String day,
    required int period,
  }) async {
    // Go側の仕様に合わせて「春」→「春学期」、「秋」→「秋学期」に変換
    String termCode = semester == '春' ? '春学期' : '秋学期';

    final response = await http.post(
      Uri.parse('$serverUrl/search'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "Faculty": facultyCode,        // "21" など
        "Year": year.toString(),       // "2026" など
        "Term": termCode,              // "春学期" または "秋学期"
        "Week": [day],                 // ["月"] など
        "Period": [period.toString()], // ["1"] など
      }),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      
      // Goの domain.Syllabus のフィールド（ID, CourseName, CampusInfo など）に合わせてパース
      return jsonList.map((json) {
        return TimetableInfo(
          id: json['ID'] ?? '',
          name: json['CourseName'] ?? '授業名不明',
          // Go側のSyllabus構造体にCampusInfoが含まれていることを想定しています
          room: json['CampusInfo'] ?? '教室未定', 
        );
      }).toList();
    } else {
      throw Exception('サーバーエラー: ${response.statusCode}');
    }
  }
}
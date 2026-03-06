// lib/screens/class_selection_screen.dart
import 'package:flutter/material.dart';
import '../main.dart';
import '../services/api_service.dart'; // 作成した通信クラスをインポート

class ClassSelectionScreen extends StatelessWidget {
  final String day;
  final int period;
  // ★ 検索条件として使うために状態(年度・学部など)を受け取る
  final TimetableState state; 

  const ClassSelectionScreen({
    super.key, 
    required this.day, 
    required this.period,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$day曜日 $period限の授業を選択')),
      // ★ FutureBuilderを使って非同期でAPIからデータを取得する
      body: FutureBuilder<List<TimetableInfo>>(
        future: ApiService.searchClasses(
          facultyCode: state.faculty.code,
          year: state.year,
          semester: state.semester,
          day: day,
          period: period,
        ),
        builder: (context, snapshot) {
          // 1. 通信中（ローディングぐるぐるを表示）
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // 2. エラー発生時
          else if (snapshot.hasError) {
            return Center(
              child: Text('エラーが発生しました\n${snapshot.error}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
            );
          }
          // 3. データ取得成功時
          else {
            final classes = snapshot.data ?? [];
            
            return ListView.builder(
              itemCount: classes.length + 1, // 「未選択に戻す」ボタンの分 +1
              itemBuilder: (context, index) {
                // 先頭は必ず「未選択（空きコマ）に戻す」ボタン
                if (index == 0) {
                  return Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.delete_outline, color: Colors.red),
                        title: const Text('未選択（空きコマ）に戻す', style: TextStyle(color: Colors.red)),
                        onTap: () => Navigator.pop(context, 'REMOVE'),
                      ),
                      const Divider(),
                    ],
                  );
                }
                
                // 実際の授業データ
                final info = classes[index - 1];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: ListTile(
                    title: Text(info.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('教室: ${info.room}'),
                    trailing: const Icon(Icons.add_circle_outline),
                    onTap: () => Navigator.pop(context, info),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
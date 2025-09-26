import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const BabyCareApp());
}

class BabyCareApp extends StatelessWidget {
  const BabyCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '宝宝生活记录',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    RecordPage(),
    StatisticsPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.event_note), label: "记录"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "统计"),
          BottomNavigationBarItem(icon: Icon(Icons.child_care), label: "宝宝"),
        ],
      ),
    );
  }
}

// ------------------ 记录页 -------------------
class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  final List<Map<String, dynamic>> _records = [];

  Future<void> _addMilkRecord() async {
    int? selectedFeedType; // 绑定值 (1=母乳, 2=配方奶)
    DateTime milkTime = DateTime.now();
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("喝奶记录"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              value: selectedFeedType,
              decoration: const InputDecoration(labelText: '奶类型'),
              items: FeedType.values.map((ft) {
                return DropdownMenuItem(
                  value: ft.value,
                  child: Text(ft.label),
                );
              }).toList(),
              onChanged: (value) {
                selectedFeedType = value!;
              },
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: '奶量 (ml)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("取消")),
          ElevatedButton(
            onPressed: () async {
              final record = {
                'type': selectedFeedType,
                'time': milkTime.toUtc().toIso8601String(),
                'amount': int.tryParse(amountController.text) ?? 0,
              };

              try {
                print("开始调用后端接口。。。。。。。");
                // === 调用后端 API ===
                final response = await http.post(
                  Uri.parse('http://192.168.0.105:8080/api/record/milk/create'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(record),
                );

                if (response.statusCode == 200) {
                  setState(() {
                    _records.add(record); // 本地列表展示
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('上传失败: ${response.body}')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('网络错误: $e')),
                );
              }
            },
            child: const Text("保存"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("宝宝生活记录")),
      body: Column(
        children: [
          // 功能按钮区
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildActionButton(Icons.local_drink, "喝奶", _addMilkRecord),
                _buildActionButton(Icons.bedtime, "睡觉", () {}),
                _buildActionButton(Icons.baby_changing_station, "换尿布", () {}),
                _buildActionButton(Icons.monitor_weight, "身高体重", () {}),
              ],
            ),
          ),
          const Divider(),
          // 最近记录列表
          Expanded(
            child: ListView.builder(
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                return ListTile(
                  leading: const Icon(Icons.local_drink),
                  title: Text("${record['type']} - ${record['amount']}ml"),
                  subtitle: Text(
                    "时间: ${record['time'].hour}:${record['time'].minute.toString().padLeft(2, '0')}",
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            child: Icon(icon, size: 28),
          ),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }
}

// ------------------ 统计页 -------------------
class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("统计页面 (开发中)")),
    );
  }
}

// ------------------ 宝宝信息页 -------------------
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("宝宝信息页面 (开发中)")),
    );
  }
}


// ------------------ 喂养方式 -------------------
enum FeedType {
  breastMilk,   // 母乳
  formulaMilk,  // 配方奶
}

extension FeedTypeExt on FeedType {
  int get value {
    switch (this) {
      case FeedType.breastMilk:
        return 1;
      case FeedType.formulaMilk:
        return 2;
    }
  }

  String get label {
    switch (this) {
      case FeedType.breastMilk:
        return "母乳";
      case FeedType.formulaMilk:
        return "配方奶";
    }
  }
}

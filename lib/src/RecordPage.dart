import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  final List<Map<String, dynamic>> _records = [];

  Future<void> _addMilkRecord() async {
    String milkType = 'ĸ��';
    DateTime milkTime = DateTime.now();
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("���̼�¼"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: milkType,
              decoration: const InputDecoration(labelText: '������'),
              items: ['ĸ��', '�䷽��']
                  .map((type) => DropdownMenuItem(
                value: type,
                child: Text(type),
              ))
                  .toList(),
              onChanged: (value) {
                milkType = value!;
              },
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: '���� (ml)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ȡ��")),
          ElevatedButton(
            onPressed: () async {
              final record = {
                'type': milkType,
                'time': milkTime.toIso8601String(),
                'amount': int.tryParse(amountController.text) ?? 0,
              };

              try {
                // === ���ú�� API ===
                final response = await http.post(
                  Uri.parse('https://your-server.com/api/milk-records'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(record),
                );

                if (response.statusCode == 200) {
                  setState(() {
                    _records.add(record); // �����б�չʾ
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('�ϴ�ʧ��: ${response.body}')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('�������: $e')),
                );
              }
            },
            child: const Text("����"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("���������¼")),
      body: ListView.builder(
        itemCount: _records.length,
        itemBuilder: (context, index) {
          final record = _records[index];
          return ListTile(
            leading: const Icon(Icons.local_drink),
            title: Text("${record['type']} - ${record['amount']}ml"),
            subtitle: Text("ʱ��: ${record['time']}"),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMilkRecord,
        child: const Icon(Icons.add),
      ),
    );
  }
}

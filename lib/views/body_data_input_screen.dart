import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BodyDataInputScreen extends StatefulWidget {
  final String uid;

  const BodyDataInputScreen({super.key, required this.uid});

  @override
  _BodyDataInputScreenState createState() => _BodyDataInputScreenState();
}

class _BodyDataInputScreenState extends State<BodyDataInputScreen> {
  final _formKey = GlobalKey<FormState>();
  String? gender;
  double? height;
  double? weight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nhập Thông Tin Cơ Thể')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Giới Tính'),
                value: gender,
                items: ['Nam', 'Nữ', 'Khác']
                    .map(
                      (label) =>
                          DropdownMenuItem(value: label, child: Text(label)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => gender = value);
                },
                validator: (value) =>
                    value == null ? 'Vui lòng chọn giới tính' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Chiều Cao (cm)'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  height = double.tryParse(value!);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập chiều cao';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Cân Nặng (kg)'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  weight = double.tryParse(value!);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập cân nặng';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Lưu Thông Tin'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({
            'gender': gender,
            'height': height,
            'weight': weight,
            'hasBodyData': true,
          });

      // Sau khi lưu, chuyển sang MainTabView
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    }
  }
}

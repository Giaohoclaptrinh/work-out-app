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
  int? age;
  List<String> selectedGoals = [];

  final List<String> availableGoals = [
    'Lose Weight',
    'Build Muscle',
    'Improve Endurance',
    'Stay Fit',
    'Enhance Flexibility',
    'Gain Weight',
    'Tone Body',
    'General Health',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Body Data Input')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Gender'),
                value: gender,
                items: ['Male', 'Female', 'Other']
                    .map(
                      (label) =>
                          DropdownMenuItem(value: label, child: Text(label)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => gender = value),
                validator: (value) =>
                    value == null ? 'Please select gender' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
                onSaved: (value) => height = double.tryParse(value!),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter height';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
                onSaved: (value) => weight = double.tryParse(value!),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter weight';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                onSaved: (value) => age = int.tryParse(value!),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter age';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Select Your Goals:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                children: availableGoals.map((goal) {
                  return CheckboxListTile(
                    value: selectedGoals.contains(goal),
                    title: Text(goal),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          selectedGoals.add(goal);
                        } else {
                          selectedGoals.remove(goal);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Save Information'),
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
            'age': age,
            'goals': selectedGoals,
            'hasBodyData': true,
          });

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../common/color_extension.dart';
import '../utils/settings_helper.dart';
import '../widgets/round_button.dart';

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
  bool _isLoading = false;

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back_ios, size: 20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Complete Your Profile',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Form content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome message
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: TColor.primaryG),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: TColor.primaryColor1.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.person_add,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Let\'s Get Started!',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Help us personalize your experience',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Gender selection
                        _buildSectionTitle('Gender'),
                        const SizedBox(height: 12),
                        _buildGenderSelector(),

                        const SizedBox(height: 24),

                        // Basic measurements
                        _buildSectionTitle('Basic Measurements'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                'Height (${SettingsHelper.getUnits(context) == 'Imperial' ? 'ft/in' : 'cm'})',
                                Icons.height,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildInputField(
                                'Weight (${SettingsHelper.getUnits(context) == 'Imperial' ? 'lbs' : 'kg'})',
                                Icons.monitor_weight,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        _buildInputField('Age', Icons.cake),

                        const SizedBox(height: 32),

                        // Goals selection
                        _buildSectionTitle('Your Fitness Goals'),
                        const SizedBox(height: 8),
                        const Text(
                          'Select all that apply:',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildGoalsGrid(),

                        const SizedBox(height: 40),

                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: RoundButton(
                            title: _isLoading
                                ? 'Saving...'
                                : 'Complete Profile',
                            type: RoundButtonType.bgGradient,
                            onPressed: _isLoading ? () {} : _submitForm,
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',
        color: Colors.black87,
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Select your gender',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        value: gender,
        items: ['Male', 'Female', 'Other']
            .map(
              (label) => DropdownMenuItem(
                value: label,
                child: Text(
                  label,
                  style: const TextStyle(fontFamily: 'Poppins'),
                ),
              ),
            )
            .toList(),
        onChanged: (value) => setState(() => gender = value),
        validator: (value) => value == null ? 'Please select gender' : null,
        icon: const Icon(Icons.keyboard_arrow_down),
      ),
    );
  }

  Widget _buildInputField(String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: TColor.primaryColor1),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        keyboardType: TextInputType.number,
        onSaved: (value) {
          if (label.contains('Height')) {
            height = double.tryParse(value!);
          } else if (label.contains('Weight')) {
            weight = double.tryParse(value!);
          } else if (label.contains('Age')) {
            age = int.tryParse(value!);
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildGoalsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: availableGoals.length,
      itemBuilder: (context, index) {
        final goal = availableGoals[index];
        final isSelected = selectedGoals.contains(goal);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedGoals.remove(goal);
              } else {
                selectedGoals.add(goal);
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? TColor.primaryColor1 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? TColor.primaryColor1 : Colors.grey.shade300,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                goal,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      _formKey.currentState!.save();

      try {
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
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving data: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../common/color_extension.dart';
import '../utils/settings_helper.dart';
import '../widgets/round_button.dart';
import '../widgets/top_notification_banner.dart';

class BodyDataInputScreen extends StatefulWidget {
  final String uid;

  const BodyDataInputScreen({super.key, required this.uid});

  @override
  _BodyDataInputScreenState createState() => _BodyDataInputScreenState();
}

class _BodyDataInputScreenState extends State<BodyDataInputScreen> {
  // Wizard steps
  int _currentStep = 0;
  final int _totalSteps = 6; // Goal, Gender, Focus Areas, Age, Height, Weight

  // Collected values
  String? gender;
  int age = 25;
  double heightCm = 170;
  double weightKg = 65;
  List<String> selectedGoals = [];
  List<String> selectedFocus = [];
  bool _isLoading = false;

  // Units
  bool useMetric = true; // true => cm/kg, false => ft/lb

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
              // Header with progress
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (_currentStep == 0) {
                          Navigator.pop(context);
                        } else {
                          setState(() => _currentStep -= 1);
                        }
                      },
                      icon: const Icon(Icons.arrow_back_ios, size: 20),
                    ),
                    Expanded(child: _buildProgressBar()),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._buildStepContent(),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: RoundButton(
                    title: _currentStep == _totalSteps - 1
                        ? (_isLoading ? 'Saving...' : 'Continue')
                        : 'Continue',
                    type: RoundButtonType.bgGradient,
                    onPressed: _isLoading
                        ? () {}
                        : () {
                            if (_currentStep < _totalSteps - 1) {
                              if (_canProceed()) {
                                setState(() => _currentStep += 1);
                              } else {
                                showTopBanner(
                                  context,
                                  title: 'Incomplete',
                                  message: 'Please complete this step to continue',
                                  backgroundColor: Colors.orange,
                                  icon: Icons.warning_amber_rounded,
                                );
                              }
                            } else {
                              _submitForm();
                            }
                          },
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

  // ---------- Step UI ----------
  Widget _buildProgressBar() {
    return SizedBox(
      height: 8,
      child: Row(
        children: List.generate(_totalSteps, (i) {
          final active = i <= _currentStep;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: active
                    ? TColor.primaryColor1
                    : Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }

  List<Widget> _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _stepGoal();
      case 1:
        return _stepGender();
      case 2:
        return _stepFocusAreas();
      case 3:
        return _stepAge();
      case 4:
        return _stepHeight();
      case 5:
      default:
        return _stepWeight();
    }
  }

  List<Widget> _stepGoal() {
    return [
      _heroTitle("What's your fitness goal?", 'Your goal is our roadmap, let\'s make it happen!'),
      const SizedBox(height: 20),
      _buildGoalsGrid(),
    ];
  }

  List<Widget> _stepGender() {
    return [
      _heroTitle('Let\'s Start with the Basics',
          'We\'ll tailor your plan based on your gender for better result'),
      const SizedBox(height: 12),
      _pillOption('Male', gender == 'Male', () => setState(() => gender = 'Male')),
      const SizedBox(height: 12),
      _pillOption('Female', gender == 'Female', () => setState(() => gender = 'Female')),
      const SizedBox(height: 12),
      _pillOption('Prefer not to say', gender == 'Other', () => setState(() => gender = 'Other')),
    ];
  }

  List<Widget> _stepFocusAreas() {
    final areas = ['Whole Body', 'Back', 'Chest', 'Arm', 'Abs', 'Butt', 'Leg'];
    return [
      _heroTitle('Which areas do you want to focus on?',
          'Select the target area for more accurate course recommendations'),
      const SizedBox(height: 12),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: areas.map((a) {
          final sel = selectedFocus.contains(a);
          return ChoiceChip(
            label: Text(a),
            selected: sel,
            onSelected: (_) {
              setState(() {
                sel ? selectedFocus.remove(a) : selectedFocus.add(a);
              });
            },
            selectedColor: TColor.primaryColor1,
            labelStyle: TextStyle(color: sel ? Colors.white : TColor.black),
          );
        }).toList(),
      ),
    ];
  }

  List<Widget> _stepAge() {
    return [
      _heroTitle('Your age', 'Age information helps us assess your metabolic level'),
      const SizedBox(height: 8),
      Center(
        child: Text('$age', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w700)),
      ),
      Slider(
        value: age.toDouble(),
        min: 12,
        max: 80,
        divisions: 68,
        onChanged: (v) => setState(() => age = v.round()),
        activeColor: TColor.primaryColor1,
      ),
    ];
  }

  List<Widget> _stepHeight() {
    final heightDisplay = useMetric
        ? '${heightCm.round()} cm'
        : _formatFeet(heightCm);
    return [
      _heroTitle('Your height', 'Height information helps us calculate your BMI'),
      const SizedBox(height: 8),
      _unitToggle(),
      const SizedBox(height: 12),
      Center(
        child: Text(heightDisplay, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800)),
      ),
      Slider(
        value: heightCm,
        min: 120,
        max: 210,
        divisions: 90,
        onChanged: (v) => setState(() => heightCm = v),
        activeColor: TColor.primaryColor1,
      ),
    ];
  }

  List<Widget> _stepWeight() {
    final weightDisplay = useMetric
        ? '${weightKg.toStringAsFixed(0)} kg'
        : '${(weightKg * 2.20462).toStringAsFixed(0)} lb';
    return [
      _heroTitle('Your current weight', 'We use your weight to fine-tune plans'),
      const SizedBox(height: 8),
      _unitToggle(),
      const SizedBox(height: 12),
      Center(
        child: Text(weightDisplay, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800)),
      ),
      Slider(
        value: weightKg,
        min: 30,
        max: 150,
        divisions: 120,
        onChanged: (v) => setState(() => weightKg = v),
        activeColor: TColor.primaryColor1,
      ),
      const SizedBox(height: 12),
      _bmiCard(),
    ];
  }

  Widget _heroTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.2,
            )),
        const SizedBox(height: 4),
        Text(subtitle,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            )),
      ],
    );
  }

  Widget _pillOption(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? TColor.primaryColor1 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : TColor.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _unitToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _unitChip('FT', !useMetric, () => setState(() => useMetric = false)),
        const SizedBox(width: 8),
        _unitChip('CM', useMetric, () => setState(() => useMetric = true)),
      ],
    );
  }

  Widget _unitChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? TColor.primaryColor1 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: TColor.primaryColor1.withOpacity(0.5)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : TColor.primaryColor1,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _bmiCard() {
    final h = heightCm / 100.0;
    final bmi = weightKg / (h * h);
    String status = 'Normal';
    Color color = Colors.green;
    if (bmi < 18.5) {
      status = 'Underweight';
      color = Colors.blue;
    } else if (bmi >= 25 && bmi < 30) {
      status = 'Overweight';
      color = Colors.orange;
    } else if (bmi >= 30) {
      status = 'Obese';
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current BMI', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(bmi.toStringAsFixed(1),
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
                const SizedBox(height: 4),
                Text(status, style: TextStyle(color: color)),
              ],
            ),
          ),
          Icon(Icons.monitor_heart, color: color),
        ],
      ),
    );
  }

  String _formatFeet(double cm) {
    final inches = cm / 2.54;
    final ft = (inches / 12).floor();
    final inch = (inches - ft * 12).round();
    return '${ft.toString()}\' ${inch.toString()}\"';
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

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return selectedGoals.isNotEmpty;
      case 1:
        return gender != null && gender!.isNotEmpty;
      case 2:
        return selectedFocus.isNotEmpty;
      default:
        return true;
    }
  }

  Future<void> _submitForm() async {
    try {
      setState(() => _isLoading = true);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({
            'gender': gender,
            'height': heightCm,
            'weight': weightKg,
            'age': age,
            'goals': selectedGoals,
            'focusAreas': selectedFocus,
            'hasBodyData': true,
          });
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      if (!mounted) return;
      showTopBanner(
        context,
        title: 'Error',
        message: 'Error saving data: $e',
        backgroundColor: Colors.red,
        icon: Icons.error_outline,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

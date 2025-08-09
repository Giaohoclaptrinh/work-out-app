import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../common/color_extension.dart';
import '../widgets/round_button.dart';
import '../services/notification_service.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NotificationService _notificationService = NotificationService();

  // Settings state variables
  bool _isDarkMode = false;
  bool _pushNotifications = true;
  bool _workoutReminders = true;
  bool _mealReminders = false;
  bool _soundEffects = true;
  bool _hapticFeedback = true;
  bool _autoSync = true;
  bool _showTips = true;

  double _fontSize = 16.0; // Font size multiplier
  String _language = 'English';
  String _units = 'Metric'; // Metric vs Imperial
  String _workoutDifficulty = 'Intermediate';

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  Future<void> _loadUserSettings() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (doc.exists && mounted) {
        final data = doc.data()!;
        final settings = data['settings'] as Map<String, dynamic>? ?? {};

        setState(() {
          _isDarkMode = settings['darkMode'] ?? false;
          _pushNotifications = settings['pushNotifications'] ?? true;
          _workoutReminders = settings['workoutReminders'] ?? true;
          _mealReminders = settings['mealReminders'] ?? false;
          _soundEffects = settings['soundEffects'] ?? true;
          _hapticFeedback = settings['hapticFeedback'] ?? true;
          _autoSync = settings['autoSync'] ?? true;
          _showTips = settings['showTips'] ?? true;
          _fontSize = settings['fontSize']?.toDouble() ?? 16.0;
          _language = settings['language'] ?? 'English';
          _units = settings['units'] ?? 'Metric';
          _workoutDifficulty = settings['workoutDifficulty'] ?? 'Intermediate';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading settings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUserSettings() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final settings = {
        'darkMode': _isDarkMode,
        'pushNotifications': _pushNotifications,
        'workoutReminders': _workoutReminders,
        'mealReminders': _mealReminders,
        'soundEffects': _soundEffects,
        'hapticFeedback': _hapticFeedback,
        'autoSync': _autoSync,
        'showTips': _showTips,
        'fontSize': _fontSize,
        'language': _language,
        'units': _units,
        'workoutDifficulty': _workoutDifficulty,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'settings': settings});

      await _notificationService.addNotification(
        'Settings Updated! ⚙️',
        'Your app settings have been saved successfully',
        type: 'settings_update',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Settings saved successfully!'),
            backgroundColor: TColor.primaryColor1,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Font Size',
          style: TextStyle(color: TColor.black, fontWeight: FontWeight.bold),
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Preview Text',
                style: TextStyle(fontSize: _fontSize, color: TColor.black),
              ),
              const SizedBox(height: 20),
              Text(
                'Size: ${_fontSize.toStringAsFixed(0)}',
                style: TextStyle(color: TColor.gray),
              ),
              Slider(
                value: _fontSize,
                min: 12.0,
                max: 24.0,
                divisions: 12,
                activeColor: TColor.primaryColor1,
                onChanged: (value) {
                  setDialogState(() {
                    _fontSize = value;
                  });
                  setState(() {
                    _fontSize = value;
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Small',
                    style: TextStyle(color: TColor.gray, fontSize: 12),
                  ),
                  Text(
                    'Large',
                    style: TextStyle(color: TColor.gray, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: TColor.gray)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveUserSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TColor.primaryColor1,
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    final languages = [
      'English',
      'Tiếng Việt',
      'Español',
      'Français',
      '中文',
      '日本語',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Language',
          style: TextStyle(color: TColor.black, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: languages.length,
            itemBuilder: (context, index) {
              final language = languages[index];
              final isSelected = language == _language;

              return ListTile(
                title: Text(
                  language,
                  style: TextStyle(
                    color: isSelected ? TColor.primaryColor1 : TColor.black,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check, color: TColor.primaryColor1)
                    : null,
                onTap: () {
                  setState(() {
                    _language = language;
                  });
                  Navigator.pop(context);
                  _saveUserSettings();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: TColor.gray)),
          ),
        ],
      ),
    );
  }

  void _showUnitsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Units',
          style: TextStyle(color: TColor.black, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Metric (kg, cm)'),
              trailing: _units == 'Metric'
                  ? Icon(
                      Icons.radio_button_checked,
                      color: TColor.primaryColor1,
                    )
                  : Icon(Icons.radio_button_unchecked, color: TColor.gray),
              onTap: () {
                setState(() {
                  _units = 'Metric';
                });
                Navigator.pop(context);
                _saveUserSettings();
              },
            ),
            ListTile(
              title: const Text('Imperial (lbs, ft)'),
              trailing: _units == 'Imperial'
                  ? Icon(
                      Icons.radio_button_checked,
                      color: TColor.primaryColor1,
                    )
                  : Icon(Icons.radio_button_unchecked, color: TColor.gray),
              onTap: () {
                setState(() {
                  _units = 'Imperial';
                });
                Navigator.pop(context);
                _saveUserSettings();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showWorkoutDifficultyDialog() {
    final difficulties = ['Beginner', 'Intermediate', 'Advanced', 'Expert'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Workout Difficulty',
          style: TextStyle(color: TColor.black, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: difficulties.map((difficulty) {
            final isSelected = difficulty == _workoutDifficulty;
            return ListTile(
              title: Text(difficulty),
              trailing: isSelected
                  ? Icon(
                      Icons.radio_button_checked,
                      color: TColor.primaryColor1,
                    )
                  : Icon(Icons.radio_button_unchecked, color: TColor.gray),
              onTap: () {
                setState(() {
                  _workoutDifficulty = difficulty;
                });
                Navigator.pop(context);
                _saveUserSettings();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _resetSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Reset Settings',
          style: TextStyle(color: TColor.black, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to reset all settings to default values?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: TColor.gray)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isDarkMode = false;
                _pushNotifications = true;
                _workoutReminders = true;
                _mealReminders = false;
                _soundEffects = true;
                _hapticFeedback = true;
                _autoSync = true;
                _showTips = true;
                _fontSize = 16.0;
                _language = 'English';
                _units = 'Metric';
                _workoutDifficulty = 'Intermediate';
              });
              Navigator.pop(context);
              _saveUserSettings();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: TColor.white,
        body: Center(
          child: CircularProgressIndicator(color: TColor.primaryColor1),
        ),
      );
    }

    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: TColor.lightGray,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              "assets/img/ArrowLeft.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          "Settings",
          style: TextStyle(
            color: TColor.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          InkWell(
            onTap: _resetSettings,
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: TColor.lightGray,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.refresh, color: TColor.black, size: 20),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Appearance Section
              _buildSectionHeader('Appearance'),
              _buildSettingsCard([
                _buildToggleRow(
                  'Dark Mode',
                  'Enable dark theme',
                  Icons.dark_mode,
                  _isDarkMode,
                  (value) {
                    setState(() {
                      _isDarkMode = value;
                    });
                    _saveUserSettings();
                  },
                ),
                _buildActionRow(
                  'Font Size',
                  'Adjust text size',
                  Icons.text_fields,
                  '${_fontSize.toStringAsFixed(0)}px',
                  _showFontSizeDialog,
                ),
                _buildActionRow(
                  'Language',
                  'Change app language',
                  Icons.language,
                  _language,
                  _showLanguageDialog,
                ),
              ]),

              const SizedBox(height: 25),

              // Notifications Section
              _buildSectionHeader('Notifications'),
              _buildSettingsCard([
                _buildToggleRow(
                  'Push Notifications',
                  'Receive app notifications',
                  Icons.notifications,
                  _pushNotifications,
                  (value) {
                    setState(() {
                      _pushNotifications = value;
                    });
                    _saveUserSettings();
                  },
                ),
                _buildToggleRow(
                  'Workout Reminders',
                  'Get workout reminder alerts',
                  Icons.fitness_center,
                  _workoutReminders,
                  (value) {
                    setState(() {
                      _workoutReminders = value;
                    });
                    _saveUserSettings();
                  },
                ),
                _buildToggleRow(
                  'Meal Reminders',
                  'Get meal time notifications',
                  Icons.restaurant,
                  _mealReminders,
                  (value) {
                    setState(() {
                      _mealReminders = value;
                    });
                    _saveUserSettings();
                  },
                ),
              ]),

              const SizedBox(height: 25),

              // Audio & Feedback Section
              _buildSectionHeader('Audio & Feedback'),
              _buildSettingsCard([
                _buildToggleRow(
                  'Sound Effects',
                  'Enable app sounds',
                  Icons.volume_up,
                  _soundEffects,
                  (value) {
                    setState(() {
                      _soundEffects = value;
                    });
                    _saveUserSettings();
                  },
                ),
                _buildToggleRow(
                  'Haptic Feedback',
                  'Enable vibration feedback',
                  Icons.vibration,
                  _hapticFeedback,
                  (value) {
                    setState(() {
                      _hapticFeedback = value;
                    });
                    _saveUserSettings();
                  },
                ),
              ]),

              const SizedBox(height: 25),

              // Workout Preferences Section
              _buildSectionHeader('Workout Preferences'),
              _buildSettingsCard([
                _buildActionRow(
                  'Units',
                  'Measurement system',
                  Icons.straighten,
                  _units,
                  _showUnitsDialog,
                ),
                _buildActionRow(
                  'Difficulty Level',
                  'Default workout difficulty',
                  Icons.trending_up,
                  _workoutDifficulty,
                  _showWorkoutDifficultyDialog,
                ),
                _buildToggleRow(
                  'Show Tips',
                  'Display helpful tips',
                  Icons.lightbulb,
                  _showTips,
                  (value) {
                    setState(() {
                      _showTips = value;
                    });
                    _saveUserSettings();
                  },
                ),
              ]),

              const SizedBox(height: 25),

              // Data & Sync Section
              _buildSectionHeader('Data & Sync'),
              _buildSettingsCard([
                _buildToggleRow(
                  'Auto Sync',
                  'Automatically sync data',
                  Icons.sync,
                  _autoSync,
                  (value) {
                    setState(() {
                      _autoSync = value;
                    });
                    _saveUserSettings();
                  },
                ),
                _buildActionRow(
                  'Export Data',
                  'Download your workout data',
                  Icons.download,
                  '',
                  () {
                    // TODO: Implement data export
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Data export feature coming soon!'),
                        backgroundColor: TColor.primaryColor1,
                      ),
                    );
                  },
                ),
                _buildActionRow(
                  'Clear Cache',
                  'Free up storage space',
                  Icons.delete_sweep,
                  '',
                  () {
                    // TODO: Implement cache clearing
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Cache cleared successfully!'),
                        backgroundColor: TColor.primaryColor1,
                      ),
                    );
                  },
                ),
              ]),

              const SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: RoundButton(
                  title: "Save All Settings",
                  onPressed: _saveUserSettings,
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        title,
        style: TextStyle(
          color: TColor.black,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildToggleRow(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: TColor.primaryColor1.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: TColor.primaryColor1, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: _fontSize,
          fontWeight: FontWeight.w600,
          color: TColor.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: _fontSize - 2, color: TColor.gray),
      ),
      trailing: AnimatedToggleSwitch<bool>.dual(
        current: value,
        first: false,
        second: true,
        spacing: 45.0,
        animationDuration: const Duration(milliseconds: 300),
        style: ToggleStyle(
          borderColor: Colors.transparent,
          indicatorColor: value ? TColor.primaryColor1 : TColor.gray,
          backgroundColor: value
              ? TColor.primaryColor1.withOpacity(0.2)
              : TColor.lightGray,
        ),
        customStyleBuilder: (context, local, global) => ToggleStyle(
          indicatorColor: value ? TColor.primaryColor1 : TColor.gray,
        ),
        onChanged: onChanged,
        iconBuilder: (value) => value
            ? Icon(Icons.check, color: Colors.white, size: 16)
            : Icon(Icons.close, color: Colors.white, size: 16),
        textBuilder: (value) => value
            ? Text(
                'ON',
                style: TextStyle(
                  color: TColor.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Text(
                'OFF',
                style: TextStyle(
                  color: TColor.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildActionRow(
    String title,
    String subtitle,
    IconData icon,
    String value,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: TColor.primaryColor1.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: TColor.primaryColor1, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: _fontSize,
          fontWeight: FontWeight.w600,
          color: TColor.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: _fontSize - 2, color: TColor.gray),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value.isNotEmpty)
            Text(
              value,
              style: TextStyle(
                fontSize: _fontSize - 2,
                color: TColor.primaryColor1,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios, size: 16, color: TColor.gray),
        ],
      ),
      onTap: onTap,
    );
  }
}

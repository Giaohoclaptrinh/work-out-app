import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/color_extension.dart';
import '../providers/settings_provider.dart';
import '../widgets/setting_row.dart';
import '../utils/debug_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Load settings when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: TColor.primaryColor1,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<SettingsProvider>().loadSettings(),
          ),
        ],
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          if (settingsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Appearance'),
                _buildDarkModeSetting(settingsProvider),
                _buildFontSizeSetting(settingsProvider),
                _buildLanguageSetting(settingsProvider),

                const SizedBox(height: 20),
                _buildSectionTitle('Notifications'),
                _buildNotificationSettings(settingsProvider),

                const SizedBox(height: 20),
                _buildSectionTitle('Workout'),
                _buildWorkoutSettings(settingsProvider),

                const SizedBox(height: 20),
                _buildSectionTitle('General'),
                _buildGeneralSettings(settingsProvider),

                const SizedBox(height: 20),
                _buildResetButton(settingsProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: TColor.black,
        ),
      ),
    );
  }

  Widget _buildDarkModeSetting(SettingsProvider settingsProvider) {
    return SettingRow(
      title: 'Dark Mode',
      subtitle: 'Use dark theme',
      icon: Icons.dark_mode,
      trailing: Switch(
        value: settingsProvider.isDarkMode,
        onChanged: (value) => settingsProvider.toggleDarkMode(),
        activeColor: TColor.primaryColor1,
      ),
    );
  }

  Widget _buildFontSizeSetting(SettingsProvider settingsProvider) {
    return Column(
      children: [
        SettingRow(
          title: 'Font Size',
          subtitle: '${settingsProvider.fontSize.toStringAsFixed(1)}px',
          icon: Icons.text_fields,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () =>
                    settingsProvider.setFontSize(settingsProvider.fontSize - 1),
              ),
              Text('${settingsProvider.fontSize.toInt()}'),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () =>
                    settingsProvider.setFontSize(settingsProvider.fontSize + 1),
              ),
            ],
          ),
        ),
        // Add preview section
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Text Size Preview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This is how your text will look with the current font size setting.',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                'Smaller text example',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSetting(SettingsProvider settingsProvider) {
    return SettingRow(
      title: 'Language',
      subtitle: settingsProvider.language,
      icon: Icons.language,
      trailing: PopupMenuButton<String>(
        onSelected: (language) => settingsProvider.setLanguage(language),
        itemBuilder: (context) => [
          'Tiếng Việt',
          'English',
          'Español',
          'Français',
          '中文',
          '日本語',
        ].map((lang) => PopupMenuItem(value: lang, child: Text(lang))).toList(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(settingsProvider.language),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettings(SettingsProvider settingsProvider) {
    return Column(
      children: [
        SettingRow(
          title: 'Push Notifications',
          subtitle: 'Receive app notifications',
          icon: Icons.notifications,
          trailing: Switch(
            value: settingsProvider.pushNotifications,
            onChanged: (value) => settingsProvider.togglePushNotifications(),
            activeColor: TColor.primaryColor1,
          ),
        ),
        SettingRow(
          title: 'Workout Reminders',
          subtitle: 'Remind me to workout',
          icon: Icons.fitness_center,
          trailing: Switch(
            value: settingsProvider.workoutReminders,
            onChanged: (value) => settingsProvider.toggleWorkoutReminders(),
            activeColor: TColor.primaryColor1,
          ),
        ),
        SettingRow(
          title: 'Meal Reminders',
          subtitle: 'Remind me to eat',
          icon: Icons.restaurant,
          trailing: Switch(
            value: settingsProvider.mealReminders,
            onChanged: (value) => settingsProvider.toggleMealReminders(),
            activeColor: TColor.primaryColor1,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutSettings(SettingsProvider settingsProvider) {
    return Column(
      children: [
        SettingRow(
          title: 'Workout Difficulty',
          subtitle: settingsProvider.workoutDifficulty,
          icon: Icons.trending_up,
          trailing: PopupMenuButton<String>(
            onSelected: (difficulty) =>
                settingsProvider.setWorkoutDifficulty(difficulty),
            itemBuilder: (context) =>
                ['Beginner', 'Intermediate', 'Advanced', 'Expert']
                    .map(
                      (diff) => PopupMenuItem(value: diff, child: Text(diff)),
                    )
                    .toList(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(settingsProvider.workoutDifficulty),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        SettingRow(
          title: 'Units',
          subtitle: settingsProvider.units,
          icon: Icons.straighten,
          trailing: PopupMenuButton<String>(
            onSelected: (units) => settingsProvider.setUnits(units),
            itemBuilder: (context) => ['Metric', 'Imperial']
                .map((unit) => PopupMenuItem(value: unit, child: Text(unit)))
                .toList(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(settingsProvider.units),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralSettings(SettingsProvider settingsProvider) {
    return Column(
      children: [
        SettingRow(
          title: 'Sound Effects',
          subtitle: 'Play sounds in app',
          icon: Icons.volume_up,
          trailing: Switch(
            value: settingsProvider.soundEffects,
            onChanged: (value) => settingsProvider.toggleSoundEffects(),
            activeColor: TColor.primaryColor1,
          ),
        ),
        SettingRow(
          title: 'Haptic Feedback',
          subtitle: 'Vibrate on interactions',
          icon: Icons.vibration,
          trailing: Switch(
            value: settingsProvider.hapticFeedback,
            onChanged: (value) => settingsProvider.toggleHapticFeedback(),
            activeColor: TColor.primaryColor1,
          ),
        ),
        SettingRow(
          title: 'Auto Sync',
          subtitle: 'Automatically sync data',
          icon: Icons.sync,
          trailing: Switch(
            value: settingsProvider.autoSync,
            onChanged: (value) => settingsProvider.toggleAutoSync(),
            activeColor: TColor.primaryColor1,
          ),
        ),
        SettingRow(
          title: 'Show Tips',
          subtitle: 'Display helpful tips',
          icon: Icons.lightbulb,
          trailing: Switch(
            value: settingsProvider.showTips,
            onChanged: (value) => settingsProvider.toggleShowTips(),
            activeColor: TColor.primaryColor1,
          ),
        ),
      ],
    );
  }

  Widget _buildResetButton(SettingsProvider settingsProvider) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showResetDialog(settingsProvider),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Reset to Defaults',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _showResetDialog(SettingsProvider settingsProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'Are you sure you want to reset all settings to defaults?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await settingsProvider.resetToDefaults();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings reset to defaults'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

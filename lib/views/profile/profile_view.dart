import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../common/color_extension.dart';
import '../../screens/auth_screen.dart'; // Đảm bảo có AuthScreen để quay lại sau khi sign out

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  Future<Map<String, dynamic>?> fetchUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: fetchUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data ?? {};

        return Scaffold(
          backgroundColor: TColor.white,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Avatar + Info + Settings button
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: TColor.primaryColor1,
                      child: Icon(Icons.person, color: TColor.white, size: 30),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Settings button
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () {
                                // TODO: Navigate to profile settings screen
                              },
                              icon: const Icon(Icons.settings, size: 16),
                              label: const Text("Profile Settings"),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 30),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                          Text(
                            user['displayName'] ?? 'No Name',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: TColor.black,
                            ),
                          ),
                          Text(
                            (user['goals'] as List?)
                                    ?.join(', ')
                                    .trim()
                                    .toString() ??
                                'No Goals',
                            style: TextStyle(
                              fontSize: 12,
                              color: TColor.primaryColor2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Height - Weight - Age
                Row(
                  children: [
                    _buildInfoCard("Height", "${user['height'] ?? '--'} cm"),
                    const SizedBox(width: 10),
                    _buildInfoCard("Weight", "${user['weight'] ?? '--'} kg"),
                    const SizedBox(width: 10),
                    _buildInfoCard("Age", _calculateAge(user['dateOfBirth'])),
                  ],
                ),

                const SizedBox(height: 30),

                // Account Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Account",
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _buildSettingTile(Icons.email, "Email", user['email'] ?? '--'),

                const SizedBox(height: 20),

                // Other Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Other",
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _buildSettingTile(
                  Icons.logout,
                  "Sign Out",
                  null,
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    if (!mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const AuthScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Expanded(
      child: Container(
        height: 80,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: TColor.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                color: TColor.primaryColor1,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(label, style: TextStyle(color: TColor.gray, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    IconData icon,
    String label,
    String? value, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: TColor.primaryColor1),
      title: Text(label),
      subtitle: value != null ? Text(value) : null,
      onTap: onTap,
    );
  }

  String _calculateAge(dynamic dobString) {
    if (dobString == null) return '--';
    try {
      final dob = DateTime.parse(dobString);
      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      return '$age yo';
    } catch (_) {
      return '--';
    }
  }
}

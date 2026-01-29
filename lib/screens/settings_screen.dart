import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/feedback_profile.dart';
import '../services/feedback_service.dart';
import '../widgets/glass_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  FeedbackProfile profile = FeedbackProfile();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('feedback_profile');
    if (jsonString != null) {
      setState(() {
        profile = FeedbackProfile.fromJson(jsonString);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('feedback_profile', profile.toJson());
    FeedbackService.updateProfile(profile); // Notify service
  }

  Widget _buildSection(String title, String phase, String currentVibe, double currentFreq, Function(String, double) onChanged) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Vibration: '),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: currentVibe,
                  dropdownColor: Colors.grey[900],
                  items: const [
                    DropdownMenuItem(value: 'short', child: Text('Short (100ms)')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium (200ms)')),
                    DropdownMenuItem(value: 'long', child: Text('Long (500ms)')),
                    DropdownMenuItem(value: 'pulse', child: Text('Pulse (3x)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => onChanged(val, currentFreq));
                      _saveSettings();
                      FeedbackService.testFeedback(val, currentFreq);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Tone Frequency:'),
            Slider(
              min: 200,
              max: 800,
              divisions: 12,
              value: currentFreq,
              label: '${currentFreq.toInt()} Hz',
              onChanged: (val) {
                setState(() => onChanged(currentVibe, val));
                FeedbackService.testFeedback(currentVibe, val);
              },
              onChangeEnd: (val) => _saveSettings(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback Settings'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildSection('Inhale Phase', 'inhale', profile.inhaleVibe, profile.inhaleBeepFreq, (v, f) {
              profile.inhaleVibe = v; profile.inhaleBeepFreq = f;
            }),
            const SizedBox(height: 16),
            _buildSection('Hold Phase', 'hold', profile.holdVibe, profile.holdBeepFreq, (v, f) {
              profile.holdVibe = v; profile.holdBeepFreq = f;
            }),
            const SizedBox(height: 16),
            _buildSection('Exhale Phase', 'exhale', profile.exhaleVibe, profile.exhaleBeepFreq, (v, f) {
              profile.exhaleVibe = v; profile.exhaleBeepFreq = f;
            }),
            const SizedBox(height: 16),
            _buildSection('Hold Empty Phase', 'holdEmpty', profile.holdEmptyVibe, profile.holdEmptyBeepFreq, (v, f) {
              profile.holdEmptyVibe = v; profile.holdEmptyBeepFreq = f;
            }),
          ],
        ),
      ),
    );
  }
}

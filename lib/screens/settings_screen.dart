import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/feedback_profile.dart';
import '../services/feedback_service.dart';
import '../services/widget_service.dart';
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
    try {
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          throw Exception('SharedPreferences timeout');
        },
      );
      final jsonString = prefs.getString('feedback_profile');
      if (jsonString != null) {
        if (mounted) {
          setState(() {
            profile = FeedbackProfile.fromJson(jsonString);
            isLoading = false;
          });
        }
        return;
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
    
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('feedback_profile', profile.toJson());
    FeedbackService.updateProfile(profile); // Notify service
  }

  Future<void> _forceWidgetUpdate() async {
    await WidgetService.forceUpdateWidget();
  }

  Widget _buildSection(String title, String phase, String currentVibe, String currentBeep, double currentFreq, Function(String, String, double) onChanged) {
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
                      setState(() => onChanged(val, currentBeep, currentFreq));
                      _saveSettings();
                      FeedbackService.testFeedback(val, currentBeep, currentFreq);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Beep Pattern: '),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: currentBeep,
                  dropdownColor: Colors.grey[900],
                  items: const [
                    DropdownMenuItem(value: 'none', child: Text('None')),
                    DropdownMenuItem(value: 'single', child: Text('Single')),
                    DropdownMenuItem(value: 'double', child: Text('Double')),
                    DropdownMenuItem(value: 'triple', child: Text('Triple')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => onChanged(currentVibe, val, currentFreq));
                      _saveSettings();
                      FeedbackService.testFeedback(currentVibe, val, currentFreq);
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
                setState(() => onChanged(currentVibe, currentBeep, val));
                FeedbackService.testFeedback(currentVibe, currentBeep, val);
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
            _buildSection('Inhale Phase', 'inhale', profile.inhaleVibe, profile.inhaleBeepPattern, profile.inhaleBeepFreq, (v, b, f) {
              profile.inhaleVibe = v; profile.inhaleBeepPattern = b; profile.inhaleBeepFreq = f;
            }),
            const SizedBox(height: 16),
            _buildSection('Hold Phase', 'hold', profile.holdVibe, profile.holdBeepPattern, profile.holdBeepFreq, (v, b, f) {
              profile.holdVibe = v; profile.holdBeepPattern = b; profile.holdBeepFreq = f;
            }),
            const SizedBox(height: 16),
            _buildSection('Exhale Phase', 'exhale', profile.exhaleVibe, profile.exhaleBeepPattern, profile.exhaleBeepFreq, (v, b, f) {
              profile.exhaleVibe = v; profile.exhaleBeepPattern = b; profile.exhaleBeepFreq = f;
            }),
            const SizedBox(height: 16),
            _buildSection('Hold Empty Phase', 'holdEmpty', profile.holdEmptyVibe, profile.holdEmptyBeepPattern, profile.holdEmptyBeepFreq, (v, b, f) {
              profile.holdEmptyVibe = v; profile.holdEmptyBeepPattern = b; profile.holdEmptyBeepFreq = f;
            }),
            const SizedBox(height: 24),
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Widget Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Always-On Display Widget'),
                        Switch(
                          value: profile.enableAODWidget,
                          onChanged: (value) async {
                            setState(() => profile.enableAODWidget = value);
                            await _saveSettings();
                            // Force widget update when AOD mode changes
                            await _forceWidgetUpdate();
                          },
                          activeColor: Colors.cyanAccent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enable simplified widget for always-on displays. Uses less battery but shows basic breathing phase.',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

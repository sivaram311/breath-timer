import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/glass_card.dart';
import '../models/preset.dart';
import '../services/widget_service.dart';
import 'add_preset.dart';
import 'breathing_exercise.dart';
import 'breathing_exercise_fullscreen.dart';
import 'settings_screen.dart';

class PresetLibraryScreen extends StatefulWidget {
  const PresetLibraryScreen({super.key});

  @override
  State<PresetLibraryScreen> createState() => _PresetLibraryScreenState();
}

class _PresetLibraryScreenState extends State<PresetLibraryScreen> with TickerProviderStateMixin {
  bool isWiggleMode = false;
  bool isLoading = true;
  List<Preset> presets = [];

  List<Preset> get _defaultPresets => [
    Preset(name: 'Box Breathing', inhale: 4, hold: 4, exhale: 4, holdEmpty: 4, color: Colors.cyan),
    Preset(name: 'Deep Calm', inhale: 4, hold: 7, exhale: 8, holdEmpty: 0, color: Colors.indigo),
    Preset(name: 'Energize', inhale: 6, hold: 0, exhale: 2, holdEmpty: 0, color: Colors.orange),
  ];

  @override
  void initState() {
    super.initState();
    _loadPresets();
    _checkForWidgetLaunch();
  }

  Future<void> _checkForWidgetLaunch() async {
    // Check if app was launched from widget tap
    final favoritePreset = await WidgetService.handleWidgetTap();
    if (favoritePreset != null && mounted) {
      // Delay to ensure presets are loaded first
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BreathingExerciseScreen(preset: favoritePreset),
          ),
        );
      }
    }
  }

  Future<void> _loadPresets() async {
    try {
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          throw Exception('SharedPreferences timeout');
        },
      );
      final presetsJson = prefs.getStringList('presets');
      if (presetsJson != null && presetsJson.isNotEmpty) {
        setState(() {
          presets = presetsJson.map((jsonString) {
            final map = json.decode(jsonString) as Map<String, dynamic>;
            return Preset.fromMap(map);
          }).toList();
          isLoading = false;
        });
      } else {
        // No saved presets, use defaults
        setState(() {
          presets = _defaultPresets;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading presets: $e');
      // Fallback to defaults on error
      setState(() {
        presets = _defaultPresets;
        isLoading = false;
      });
    }
  }

  Future<void> _savePresets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final presetsJson = presets.map((preset) => json.encode(preset.toMap())).toList();
      await prefs.setStringList('presets', presetsJson);

      // Update widget with favorite preset
      await _updateWidgetWithFavoritePreset();
    } catch (e) {
      debugPrint('Error saving presets: $e');
    }
  }

  Future<void> _updateWidgetWithFavoritePreset() async {
    final favoritePreset = presets.where((preset) => preset.isFavorite).firstOrNull;

    // Get AOD setting from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString('feedback_profile');
    bool aodMode = false;

    if (profileJson != null) {
      try {
        final profileData = json.decode(profileJson) as Map<String, dynamic>;
        aodMode = profileData['enableAODWidget'] ?? false;
      } catch (e) {
        // Keep default AOD mode (false)
      }
    }

    await WidgetService.updateWidgetWithFavoritePreset(favoritePreset, aodMode: aodMode);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.cyan.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Preset Library',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.cyanAccent),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SettingsScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.separated(
                      itemCount: presets.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final preset = presets[index];
                        return GestureDetector(
                          onLongPress: () {
                            setState(() => isWiggleMode = true);
                          },
                          onTap: () {
                            if (isWiggleMode) {
                              setState(() => isWiggleMode = false);
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BreathingExerciseScreen(preset: preset),
                                ),
                              );
                            }
                          },
                          child: Stack(
                            children: [
                              // Main card content
                              GlassCard(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: preset.color,
                                          borderRadius: BorderRadius.circular(6),
                                          boxShadow: [
                                            BoxShadow(
                                              color: preset.color.withOpacity(0.5),
                                              blurRadius: 10,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    preset.name,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                if (preset.isFavorite)
                                                  const Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                    size: 16,
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Breathe-Bar: ${preset.pattern}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white.withOpacity(0.6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Fullscreen button (bottom right)
                              Positioned(
                                bottom: 12,
                                right: 12,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.fullscreen,
                                    color: Colors.cyanAccent,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FullscreenBreathingExerciseScreen(preset: preset),
                                      ),
                                    );
                                  },
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.black.withOpacity(0.3),
                                    padding: const EdgeInsets.all(8),
                                  ),
                                ),
                              ),
                          child: Stack(
                            children: [
                              GlassCard(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: preset.color,
                                          borderRadius: BorderRadius.circular(6),
                                          boxShadow: [
                                            BoxShadow(
                                              color: preset.color.withOpacity(0.5),
                                              blurRadius: 10,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    preset.name,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                if (preset.isFavorite)
                                                  const Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                    size: 16,
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Breathe-Bar: ${preset.pattern}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white.withOpacity(0.6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Favorite star icon (always visible)
                              Positioned(
                                top: 8,
                                left: 8,
                                child: IconButton(
                                  icon: Icon(
                                    preset.isFavorite ? Icons.star : Icons.star_border,
                                    color: preset.isFavorite ? Colors.amber : Colors.white.withOpacity(0.6),
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      presets[index] = Preset(
                                        name: preset.name,
                                        inhale: preset.inhale,
                                        hold: preset.hold,
                                        exhale: preset.exhale,
                                        holdEmpty: preset.holdEmpty,
                                        color: preset.color,
                                        isFavorite: !preset.isFavorite,
                                      );
                                    });
                                    _savePresets();
                                  },
                                ),
                              ),
                              // Delete button (only in wiggle mode)
                              if (isWiggleMode)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton(
                                    icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                                    onPressed: () {
                                      setState(() {
                                        presets.removeAt(index);
                                        if (presets.isEmpty) isWiggleMode = false;
                                      });
                                      _savePresets();
                                    },
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPresetScreen()),
          );
          
          if (result != null && result is Preset) {
            setState(() {
              presets.add(result);
            });
            _savePresets();
          }
        },
        backgroundColor: Colors.cyanAccent,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

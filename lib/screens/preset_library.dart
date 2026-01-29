import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../widgets/glass_card.dart';
import '../models/preset.dart';
import 'add_preset.dart';
import 'breathing_exercise.dart';
import 'settings_screen.dart';

class PresetLibraryScreen extends StatefulWidget {
  const PresetLibraryScreen({super.key});

  @override
  State<PresetLibraryScreen> createState() => _PresetLibraryScreenState();
}

class _PresetLibraryScreenState extends State<PresetLibraryScreen> with TickerProviderStateMixin {
  bool isWiggleMode = false;
  List<Preset> presets = [
    Preset(name: 'Box Breathing', inhale: 4, hold: 4, exhale: 4, holdEmpty: 4, color: Colors.cyan),
    Preset(name: 'Deep Calm', inhale: 4, hold: 7, exhale: 8, holdEmpty: 0, color: Colors.indigo),
    Preset(name: 'Energize', inhale: 6, hold: 0, exhale: 2, holdEmpty: 0, color: Colors.orange),
  ];

  @override
  Widget build(BuildContext context) {
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
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            preset.name,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
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
                                    ],
                                  ),
                                ),
                              ),
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
          }
        },
        backgroundColor: Colors.cyanAccent,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

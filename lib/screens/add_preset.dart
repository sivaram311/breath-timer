import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/radial_visualizer.dart';
import '../widgets/glass_card.dart';
import '../models/preset.dart';

class AddPresetScreen extends StatefulWidget {
  const AddPresetScreen({super.key});

  @override
  State<AddPresetScreen> createState() => _AddPresetScreenState();
}

class _AddPresetScreenState extends State<AddPresetScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'New Pattern');
  double inhale = 4;
  double hold = 4;
  double exhale = 4;
  double holdEmpty = 4;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _triggerHaptic() {
    HapticFeedback.selectionClick();
  }

  Widget _buildSlider(String label, double value, Color color, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('${value.toInt()}s', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            thumbColor: color,
            overlayColor: color.withOpacity(0.1),
          ),
          child: Slider(
            value: value,
            min: 0,
            max: 20,
            onChanged: (val) {
              if (val.toInt() != value.toInt()) {
                _triggerHaptic();
              }
              onChanged(val);
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Pattern'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Pattern Name',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: CustomPaint(
                    painter: RadialVisualizer(
                      inhale: inhale,
                      hold: hold,
                      exhale: exhale,
                      holdEmpty: holdEmpty,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildSlider('Inhale', inhale, Colors.cyanAccent, (v) => setState(() => inhale = v)),
                      const SizedBox(height: 16),
                      _buildSlider('Hold', hold, Colors.greenAccent, (v) => setState(() => hold = v)),
                      const SizedBox(height: 16),
                      _buildSlider('Exhale', exhale, Colors.orangeAccent, (v) => setState(() => exhale = v)),
                      const SizedBox(height: 16),
                      _buildSlider('Hold Empty', holdEmpty, Colors.deepPurpleAccent, (v) => setState(() => holdEmpty = v)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    final newPreset = Preset(
                      name: _nameController.text,
                      inhale: inhale.toInt(),
                      hold: hold.toInt(),
                      exhale: exhale.toInt(),
                      holdEmpty: holdEmpty.toInt(),
                    );
                    Navigator.pop(context, newPreset);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Save Preset', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

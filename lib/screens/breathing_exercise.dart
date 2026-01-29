import 'dart:async';
import 'package:flutter/material.dart';
import '../models/preset.dart';
import '../services/feedback_service.dart';

class BreathingExerciseScreen extends StatefulWidget {
  final Preset preset;
  const BreathingExerciseScreen({super.key, required this.preset});

  @override
  State<BreathingExerciseScreen> createState() => _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  bool isStarted = false;
  String currentPhase = 'Get Ready';
  int secondsRemaining = 0;
  Timer? _timer;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void _startExercise() async {
    // Explicitly initialize/resume audio context on user gesture
    FeedbackService.playPhaseFeedback('Start'); // Dummy phase to unlock
    
    setState(() => isStarted = true);
    while (mounted && isStarted) {
      if (widget.preset.inhale > 0) await _runPhase('Inhale', widget.preset.inhale, true);
      if (widget.preset.hold > 0) await _runPhase('Hold', widget.preset.hold, false);
      if (widget.preset.exhale > 0) await _runPhase('Exhale', widget.preset.exhale, true, reverse: true);
      if (widget.preset.holdEmpty > 0) await _runPhase('Hold', widget.preset.holdEmpty, false);
    }
  }

  Future<void> _runPhase(String phase, int seconds, bool animate, {bool reverse = false}) async {
    if (!mounted) return;
    
    // Trigger Sensory Feedback
    FeedbackService.playPhaseFeedback(phase);

    setState(() {
      currentPhase = phase;
      secondsRemaining = seconds;
    });

    if (animate) {
      _controller.duration = Duration(seconds: seconds);
      if (reverse) {
        _controller.reverse(from: 1.0);
      } else {
        _controller.forward(from: 0.0);
      }
    }

    final completer = Completer<void>();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (secondsRemaining > 0) {
          secondsRemaining--;
        }
      });
      if (secondsRemaining == 0) {
        timer.cancel();
        completer.complete();
      }
    });
    return completer.future;
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color phaseColor = Colors.white;
    switch (currentPhase) {
      case 'Inhale': phaseColor = Colors.cyanAccent; break;
      case 'Hold': phaseColor = Colors.greenAccent; break;
      case 'Exhale': phaseColor = Colors.orangeAccent; break;
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(seconds: 1),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    phaseColor.withOpacity(0.15),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Spacer(),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: GestureDetector(
                    onTap: isStarted ? null : _startExercise,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isStarted ? Colors.transparent : phaseColor.withOpacity(0.1),
                        border: Border.all(color: phaseColor, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: phaseColor.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isStarted)
                              const Icon(Icons.play_arrow, size: 80, color: Colors.white)
                            else ...[
                              Text(
                                currentPhase,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: phaseColor,
                                ),
                              ),
                              Text(
                                '$secondsRemaining',
                                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    widget.preset.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w300),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

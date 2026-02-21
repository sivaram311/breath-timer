import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/preset.dart';
import '../services/feedback_service.dart';
import '../services/widget_service.dart';
import 'breathing_exercise.dart';

class FullscreenBreathingExerciseScreen extends StatefulWidget {
  final Preset preset;
  const FullscreenBreathingExerciseScreen({super.key, required this.preset});

  @override
  State<FullscreenBreathingExerciseScreen> createState() => _FullscreenBreathingExerciseScreenState();
}

class _FullscreenBreathingExerciseScreenState extends State<FullscreenBreathingExerciseScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  bool isStarted = false;
  String currentPhase = 'Get Ready';
  int secondsRemaining = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Set fullscreen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

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

    // Update widget with current phase
    WidgetService.updateWidgetPhase(phase);

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

  void _exitFullscreen() {
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    Navigator.pop(context);
  }

  void _switchToRegularMode() {
    // Restore system UI and go back to regular breathing screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BreathingExerciseScreen(preset: widget.preset),
      ),
    );
  }

  @override
  void dispose() {
    // Restore system UI when leaving
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for fullscreen layout
    final screenSize = MediaQuery.of(context).size;
    final circleSize = screenSize.width * 0.8; // 80% of screen width

    Color phaseColor = Colors.white;
    switch (currentPhase) {
      case 'Inhale': phaseColor = Colors.cyanAccent; break;
      case 'Hold': phaseColor = Colors.greenAccent; break;
      case 'Exhale': phaseColor = Colors.orangeAccent; break;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fullscreen animated background
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(seconds: 1),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    phaseColor.withOpacity(0.2),
                    phaseColor.withOpacity(0.1),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),

          // Controls hint (subtle)
          Positioned(
            top: 40,
            right: 20,
            child: AnimatedOpacity(
              opacity: isStarted ? 0.0 : 0.7,
              duration: const Duration(milliseconds: 300),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Double tap to exit',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Long press for controls',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main breathing circle - fullscreen sized
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: GestureDetector(
                onTap: isStarted ? null : _startExercise,
                onDoubleTap: _exitFullscreen,
                onLongPress: isStarted ? null : _switchToRegularMode,
                child: Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isStarted ? Colors.transparent : phaseColor.withOpacity(0.05),
                    border: Border.all(
                      color: phaseColor,
                      width: isStarted ? 6 : 3,
                    ),
                    boxShadow: isStarted ? [
                      BoxShadow(
                        color: phaseColor.withOpacity(0.4),
                        blurRadius: 50,
                        spreadRadius: 20,
                      ),
                    ] : null,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isStarted) ...[
                          Icon(
                            Icons.play_arrow,
                            size: circleSize * 0.2,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Tap to start',
                            style: TextStyle(
                              fontSize: circleSize * 0.06,
                              color: Colors.white.withOpacity(0.7),
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ] else ...[
                          // Phase text - larger for fullscreen
                          Text(
                            currentPhase,
                            style: TextStyle(
                              fontSize: circleSize * 0.12,
                              fontWeight: FontWeight.bold,
                              color: phaseColor,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Countdown - very large for fullscreen
                          Text(
                            '$secondsRemaining',
                            style: TextStyle(
                              fontSize: circleSize * 0.25,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Preset name at bottom - subtle
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedOpacity(
                opacity: isStarted ? 0.0 : 0.6,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  widget.preset.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    color: Colors.white.withOpacity(0.8),
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // Breathing pattern hint
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedOpacity(
                opacity: isStarted ? 0.0 : 0.4,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  widget.preset.pattern,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
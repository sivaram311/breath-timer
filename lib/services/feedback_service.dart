import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import 'js_interop_stub.dart'
    if (dart.library.js_interop) 'js_interop.dart' as js;
import 'dart:developer' as dev;
import '../models/feedback_profile.dart';

class FeedbackService {
  static FeedbackProfile _profile = FeedbackProfile();
  static final AudioPlayer _audioPlayer = AudioPlayer();

  static void updateProfile(FeedbackProfile newProfile) {
    _profile = newProfile;
  }
  
  static void testFeedback(String vibeType, String beepPattern, double freq) {
    _feedback(
      pattern: _getPattern(vibeType), 
      beepPattern: beepPattern,
      freq: freq, 
      duration: 0.2
    );
  }

  static Future<void> playPhaseFeedback(String phase) async {
    dev.log('Triggering feedback for phase: $phase');
    
    // Ensure AudioContext is ready (safe to call repeatedly)
    if (kIsWeb) {
      js.initAudio();
    }

    switch (phase) {
      case 'Inhale':
        _feedback(
          pattern: _getPattern(_profile.inhaleVibe), 
          beepPattern: _profile.inhaleBeepPattern,
          freq: _profile.inhaleBeepFreq, 
          duration: 0.3
        );
        break;
      case 'Hold':
        _feedback(
          pattern: _getPattern(_profile.holdVibe), 
          beepPattern: _profile.holdBeepPattern,
          freq: _profile.holdBeepFreq, 
          duration: 0.3
        );
        break;
      case 'Exhale':
        _feedback(
          pattern: _getPattern(_profile.exhaleVibe), 
          beepPattern: _profile.exhaleBeepPattern,
          freq: _profile.exhaleBeepFreq, 
          duration: 0.6
        ); 
        break;
      case 'Hold (Empty)':
      case 'Hold Empty':
        _feedback(
          pattern: _getPattern(_profile.holdEmptyVibe), 
          beepPattern: _profile.holdEmptyBeepPattern,
          freq: _profile.holdEmptyBeepFreq, 
          duration: 0.3
        );
        break;
      case 'Start':
        _feedback(pattern: [0, 50], beepPattern: 'single', freq: 880, duration: 0.1); 
        break;
    }
  }

  static List<int> _getPattern(String type) {
    switch (type) {
      case 'short': return [0, 100];
      case 'medium': return [0, 200];
      case 'long': return [0, 500];
      case 'pulse': return [0, 100, 100, 100, 100, 100, 100, 100, 100, 100];
      default: return [];
    }
  }

  static void _feedback({
    required List<int> pattern, 
    required String beepPattern,
    required double freq, 
    required double duration
  }) {
    if (kIsWeb) {
      if (pattern.isNotEmpty) js.triggerVibrate(pattern);
      js.playTone(freq, duration);
    } else {
      if (pattern.isNotEmpty) {
        Vibration.vibrate(pattern: pattern);
      }
      _playMobileBeep(beepPattern);
      HapticFeedback.selectionClick(); 
    }
  }

  static Future<void> _playMobileBeep(String pattern) async {
    if (pattern == 'none') return;
    
    int count = 1;
    if (pattern == 'double') count = 2;
    if (pattern == 'triple') count = 3;

    for (int i = 0; i < count; i++) {
       await _audioPlayer.play(AssetSource('audio/beep.wav'), mode: PlayerMode.lowLatency);
       if (i < count - 1) {
         await Future.delayed(const Duration(milliseconds: 200));
       }
    }
  }
}

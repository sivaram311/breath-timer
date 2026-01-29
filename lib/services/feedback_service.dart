import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'js_interop.dart' as js;
import 'dart:developer' as dev;
import '../models/feedback_profile.dart';

class FeedbackService {
  static FeedbackProfile _profile = FeedbackProfile();

  static void updateProfile(FeedbackProfile newProfile) {
    _profile = newProfile;
  }
  
  static void testFeedback(String vibeType, double freq) {
    _feedback(pattern: _getPattern(vibeType), freq: freq, duration: 0.2);
  }

  static Future<void> playPhaseFeedback(String phase) async {
    dev.log('Triggering feedback for phase: $phase');
    
    // Ensure AudioContext is ready (safe to call repeatedly)
    if (kIsWeb) {
      js.initAudio();
    }

    switch (phase) {
      case 'Inhale':
        _feedback(pattern: _getPattern(_profile.inhaleVibe), freq: _profile.inhaleBeepFreq, duration: 0.3);
        break;
      case 'Hold':
        _feedback(pattern: _getPattern(_profile.holdVibe), freq: _profile.holdBeepFreq, duration: 0.3);
        break;
      case 'Exhale':
        _feedback(pattern: _getPattern(_profile.exhaleVibe), freq: _profile.exhaleBeepFreq, duration: 0.6); 
        break;
      case 'Hold (Empty)':
      case 'Hold Empty':
        _feedback(pattern: _getPattern(_profile.holdEmptyVibe), freq: _profile.holdEmptyBeepFreq, duration: 0.3);
        break;
      case 'Start':
        _feedback(pattern: [50], freq: 880, duration: 0.1); 
        break;
    }
  }

  static List<int> _getPattern(String type) {
    switch (type) {
      case 'short': return [100];
      case 'medium': return [200];
      case 'long': return [500];
      case 'pulse': return [100, 100, 100, 100, 100];
      default: return [100];
    }
  }

  static void _feedback({required List<int> pattern, required double freq, required double duration}) {
    if (kIsWeb) {
      js.triggerVibrate(pattern);
      js.playTone(freq, duration);
    } else {
      // Fallback for native (not implemented fully in this web-focused step)
      HapticFeedback.mediumImpact(); 
    }
  }
}

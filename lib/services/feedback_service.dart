import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'js_interop.dart' as js;
import 'dart:developer' as dev;

class FeedbackService {
  static Future<void> playPhaseFeedback(String phase) async {
    dev.log('Triggering feedback for phase: $phase');
    
    // Ensure AudioContext is ready (safe to call repeatedly)
    if (kIsWeb) {
      js.initAudio();
    }

    switch (phase) {
      case 'Inhale':
        _feedback(pattern: [0, 100], freq: 440, duration: 0.3);
        break;
      case 'Hold':
        _feedback(pattern: [0, 100, 100, 100], freq: 523, duration: 0.3);
        break;
      case 'Exhale':
        _feedback(pattern: [0, 300], freq: 330, duration: 0.6); 
        break;
      case 'Hold (Empty)':
      case 'Hold Empty':
        _feedback(pattern: [0, 50, 50, 50, 50, 50], freq: 261, duration: 0.3);
        break;
      case 'Start':
        // Silent or very short beep just to unlock AudioContext
        _feedback(pattern: [0, 50], freq: 880, duration: 0.1); 
        break;
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

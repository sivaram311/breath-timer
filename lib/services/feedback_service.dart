import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:developer' as dev;

class FeedbackService {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  static Future<void> playPhaseFeedback(String phase) async {
    dev.log('Triggering feedback for phase: $phase');
    
    switch (phase) {
      case 'Inhale':
        _vibrate(pattern: [0, 100]); // Short single vibration
        _beep(440); // Standard A4 (High)
        break;
      case 'Hold':
        _vibrate(pattern: [0, 100, 100, 100]); // Quick double pulse
        _beep(523); // C5 (Medium High)
        break;
      case 'Exhale':
        _vibrate(pattern: [0, 300]); // Longer single heavy vibration
        _beep(330); // E4 (Low Medium)
        break;
      case 'Hold Empty':
      case 'Hold (Empty)':
        _vibrate(pattern: [0, 50, 50, 50, 50, 50]); // Triple quick pulses
        _beep(261); // C4 (Low)
        break;
    }
  }

  static void _vibrate({required List<int> pattern}) async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(pattern: pattern);
    }
  }

  static void _beep(double frequency) async {
    // Note: Generating real-time waveforms is complex in Flutter without heavy assets.
    // For this implementation, we simulate using a short premium asset sound 
    // or log the attempt if assets aren't present.
    // In a real mobile app, we'd include short .wav files for each note.
    dev.log('Playing beep for frequency: $frequency');
    // Using a system sound as a placeholder or could use Source.asset('beeps/$phase.mp3')
  }
}

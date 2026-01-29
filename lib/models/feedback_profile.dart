import 'dart:convert';

class FeedbackProfile {
  String inhaleVibe; // 'short', 'medium', 'long', 'pulse'
  String holdVibe;
  String exhaleVibe;
  String holdEmptyVibe;
  
  double inhaleBeepFreq;
  double holdBeepFreq;
  double exhaleBeepFreq;
  double holdEmptyBeepFreq;

  FeedbackProfile({
    this.inhaleVibe = 'short',
    this.holdVibe = 'pulse',
    this.exhaleVibe = 'medium',
    this.holdEmptyVibe = 'short',
    this.inhaleBeepFreq = 440,
    this.holdBeepFreq = 523,
    this.exhaleBeepFreq = 330,
    this.holdEmptyBeepFreq = 261,
  });

  Map<String, dynamic> toMap() {
    return {
      'inhaleVibe': inhaleVibe,
      'holdVibe': holdVibe,
      'exhaleVibe': exhaleVibe,
      'holdEmptyVibe': holdEmptyVibe,
      'inhaleBeepFreq': inhaleBeepFreq,
      'holdBeepFreq': holdBeepFreq,
      'exhaleBeepFreq': exhaleBeepFreq,
      'holdEmptyBeepFreq': holdEmptyBeepFreq,
    };
  }

  factory FeedbackProfile.fromMap(Map<String, dynamic> map) {
    return FeedbackProfile(
      inhaleVibe: map['inhaleVibe'] ?? 'short',
      holdVibe: map['holdVibe'] ?? 'pulse',
      exhaleVibe: map['exhaleVibe'] ?? 'medium',
      holdEmptyVibe: map['holdEmptyVibe'] ?? 'short',
      inhaleBeepFreq: (map['inhaleBeepFreq'] ?? 440).toDouble(),
      holdBeepFreq: (map['holdBeepFreq'] ?? 523).toDouble(),
      exhaleBeepFreq: (map['exhaleBeepFreq'] ?? 330).toDouble(),
      holdEmptyBeepFreq: (map['holdEmptyBeepFreq'] ?? 261).toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory FeedbackProfile.fromJson(String source) => FeedbackProfile.fromMap(json.decode(source));
}

import 'package:flutter/material.dart';

class Preset {
  final String name;
  final int inhale;
  final int hold;
  final int exhale;
  final int holdEmpty;
  final Color color;
  final bool isFavorite;

  Preset({
    required this.name,
    required this.inhale,
    required this.hold,
    required this.exhale,
    required this.holdEmpty,
    this.color = Colors.cyanAccent,
    this.isFavorite = false,
  });

  String get pattern => '$inhale-$hold-$exhale-$holdEmpty';

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'inhale': inhale,
      'hold': hold,
      'exhale': exhale,
      'holdEmpty': holdEmpty,
      'color': color.value,
      'isFavorite': isFavorite,
    };
  }

  factory Preset.fromMap(Map<String, dynamic> map) {
    return Preset(
      name: map['name'],
      inhale: map['inhale'],
      hold: map['hold'],
      exhale: map['exhale'],
      holdEmpty: map['holdEmpty'],
      color: Color(map['color']),
      isFavorite: map['isFavorite'] ?? false,
    );
  }
}

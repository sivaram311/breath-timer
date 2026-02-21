import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import '../models/preset.dart';

class WidgetService {
  static const String _favoritePresetKey = 'favorite_preset';
  static const String _currentPhaseKey = 'current_phase';

  // Battery optimization: track last update times
  static DateTime? _lastPhaseUpdateTime;
  static DateTime? _lastPresetUpdateTime;

  // Initialize the widget service
  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId('group.com.example.breath_timer');
  }

  // Update widget with favorite preset data
  static Future<void> updateWidgetWithFavoritePreset(Preset? favoritePreset, {bool aodMode = false}) async {
    // Battery optimization: throttle preset updates to every 5 seconds in AOD mode
    if (aodMode) {
      final now = DateTime.now();
      if (_lastPresetUpdateTime != null &&
          now.difference(_lastPresetUpdateTime!).inSeconds < 5) {
        return; // Skip update to save battery
      }
      _lastPresetUpdateTime = now;
    }

    if (favoritePreset != null) {
      final presetData = {
        'name': favoritePreset.name,
        'pattern': favoritePreset.pattern,
        'color': favoritePreset.color.value,
        'inhale': favoritePreset.inhale,
        'hold': favoritePreset.hold,
        'exhale': favoritePreset.exhale,
        'holdEmpty': favoritePreset.holdEmpty,
      };

      await HomeWidget.saveWidgetData<String>(
        _favoritePresetKey,
        json.encode(presetData),
      );
    } else {
      await HomeWidget.saveWidgetData<String>(_favoritePresetKey, null);
    }

    // Save AOD mode setting
    await HomeWidget.saveWidgetData<bool>('aod_mode', aodMode);

    await HomeWidget.updateWidget(
      name: 'BreathingWidgetProvider',
      androidName: 'BreathingWidgetProvider',
    );
  }

  // Force update widget (bypasses battery optimization)
  static Future<void> forceUpdateWidget() async {
    await HomeWidget.updateWidget(
      name: 'BreathingWidgetProvider',
      androidName: 'BreathingWidgetProvider',
    );
  }

  // Update widget with current breathing phase
  static Future<void> updateWidgetPhase(String phase, {bool forceUpdate = false}) async {
    // Check AOD mode for battery optimization
    final aodMode = await HomeWidget.getWidgetData<bool>('aod_mode') ?? false;

    // In AOD mode, throttle updates to every 2 seconds to save battery
    if (aodMode && !forceUpdate) {
      final now = DateTime.now();
      if (_lastPhaseUpdateTime != null &&
          now.difference(_lastPhaseUpdateTime!).inSeconds < 2) {
        return; // Skip update to save battery
      }
      _lastPhaseUpdateTime = now;
    }

    await HomeWidget.saveWidgetData<String>(_currentPhaseKey, phase);
    await HomeWidget.updateWidget(
      name: 'BreathingWidgetProvider',
      androidName: 'BreathingWidgetProvider',
    );
  }

  // Get favorite preset from widget data (for app launch from widget)
  static Future<Preset?> getFavoritePresetFromWidget() async {
    final presetJson = await HomeWidget.getWidgetData<String>(_favoritePresetKey);
    if (presetJson != null) {
      try {
        final presetData = json.decode(presetJson) as Map<String, dynamic>;
        return Preset(
          name: presetData['name'],
          inhale: presetData['inhale'],
          hold: presetData['hold'],
          exhale: presetData['exhale'],
          holdEmpty: presetData['holdEmpty'],
          color: Color(presetData['color']),
          isFavorite: true,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Get current phase from widget data
  static Future<String?> getCurrentPhaseFromWidget() async {
    return await HomeWidget.getWidgetData<String>(_currentPhaseKey);
  }

  // Handle widget tap - returns the preset that should be launched
  static Future<Preset?> handleWidgetTap() async {
    return await getFavoritePresetFromWidget();
  }
}
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WeightEntry {
  final DateTime date;
  final double weight;

  WeightEntry({required this.date, required this.weight});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'weight': weight,
      };

  factory WeightEntry.fromJson(Map<String, dynamic> json) => WeightEntry(
        date: DateTime.parse(json['date'] as String),
        weight: json['weight'] as double,
      );
}

class StorageService {
  static const String _keyName = 'user_name';
  static const String _keyCurrentWeight = 'current_weight';
  static const String _keyTargetWeight = 'target_weight';
  static const String _keyWhy = 'user_why';
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyWeightHistory = 'weight_history';

  Future<void> saveUserData({
    required String name,
    required double currentWeight,
    required double targetWeight,
    required String why,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
    await prefs.setDouble(_keyCurrentWeight, currentWeight);
    await prefs.setDouble(_keyTargetWeight, targetWeight);
    await prefs.setString(_keyWhy, why);
    await prefs.setBool(_keyOnboardingComplete, true);
    
    // Save initial weight entry
    await addWeightEntry(currentWeight);
  }

  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!await isOnboardingComplete()) return null;

    return {
      'name': prefs.getString(_keyName),
      'currentWeight': prefs.getDouble(_keyCurrentWeight),
      'targetWeight': prefs.getDouble(_keyTargetWeight),
      'why': prefs.getString(_keyWhy),
    };
  }

  Future<void> addWeightEntry(double weight) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getWeightHistory();
    
    final newEntry = WeightEntry(
      date: DateTime.now(),
      weight: weight,
    );
    
    history.add(newEntry);
    
    // Save history
    final jsonList = history.map((e) => e.toJson()).toList();
    await prefs.setString(_keyWeightHistory, jsonEncode(jsonList));
    
    // Update current weight
    await prefs.setDouble(_keyCurrentWeight, weight);
  }

  Future<List<WeightEntry>> getWeightHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyString = prefs.getString(_keyWeightHistory);
    
    if (historyString == null) return [];
    
    final jsonList = jsonDecode(historyString) as List;
    return jsonList
        .map((json) => WeightEntry.fromJson(json as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<double?> getCurrentWeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyCurrentWeight);
  }

  Future<void> updateWhy(String why) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyWhy, why);
  }

  Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

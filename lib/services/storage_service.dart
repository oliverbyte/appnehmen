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

class Habit {
  final String id;
  final String name;
  final String description;
  final bool isDefault;  // Cannot be deleted if true

  Habit({
    required this.id,
    required this.name,
    required this.description,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'isDefault': isDefault,
      };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        isDefault: json['isDefault'] as bool? ?? false,
      );

  Habit copyWith({
    String? name,
    String? description,
  }) {
    return Habit(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      isDefault: isDefault,
    );
  }
}

class HabitCompletion {
  final String habitId;
  final DateTime date;

  HabitCompletion({required this.habitId, required this.date});

  Map<String, dynamic> toJson() => {
        'habitId': habitId,
        'date': date.toIso8601String(),
      };

  factory HabitCompletion.fromJson(Map<String, dynamic> json) =>
      HabitCompletion(
        habitId: json['habitId'] as String,
        date: DateTime.parse(json['date'] as String),
      );
}

class StorageService {
  static const String _keyName = 'user_name';
  static const String _keyCurrentWeight = 'current_weight';
  static const String _keyTargetWeight = 'target_weight';
  static const String _keyWhy = 'user_why';
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyWeightHistory = 'weight_history';
  static const String _keyHabits = 'habits';
  static const String _keyHabitCompletions = 'habit_completions';
  static const String _keyHabitsInitialized = 'habits_initialized';
  static const String _keyInstallPromptSeen = 'install_prompt_seen';

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

  // ============ HABIT METHODS ============

  // Standard-Gewohnheiten
  List<Habit> _getDefaultHabits() {
    return [
      Habit(
        id: 'habit_1',
        name: 'Tägliches Workout',
        description: '2 Runden à 30x Kniebeugen, Damen-Liegestütz, Situps oder Crunches',
        isDefault: true,
      ),
      Habit(
        id: 'habit_2',
        name: 'Nur 3 Hauptmahlzeiten',
        description: 'Maximal handtellergroß, keine Snacks zwischen den Mahlzeiten',
        isDefault: true,
      ),
      Habit(
        id: 'habit_3',
        name: '30 Minuten Bewegung',
        description: 'Walken, Fahrrad, Joggen oder ähnliches',
        isDefault: true,
      ),
    ];
  }

  Future<void> initializeDefaultHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final initialized = prefs.getBool(_keyHabitsInitialized) ?? false;
    
    if (!initialized) {
      final defaultHabits = _getDefaultHabits();
      final jsonList = defaultHabits.map((h) => h.toJson()).toList();
      await prefs.setString(_keyHabits, jsonEncode(jsonList));
      await prefs.setBool(_keyHabitsInitialized, true);
    }
  }

  Future<List<Habit>> getHabits() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Initialisiere Standard-Habits falls noch nicht geschehen
    await initializeDefaultHabits();
    
    final habitsString = prefs.getString(_keyHabits);
    if (habitsString == null) return [];

    final jsonList = jsonDecode(habitsString) as List;
    return jsonList
        .map((json) => Habit.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveHabit(Habit habit) async {
    final habits = await getHabits();
    final index = habits.indexWhere((h) => h.id == habit.id);
    
    if (index >= 0) {
      habits[index] = habit;
    } else {
      habits.add(habit);
    }
    
    final prefs = await SharedPreferences.getInstance();
    final jsonList = habits.map((h) => h.toJson()).toList();
    await prefs.setString(_keyHabits, jsonEncode(jsonList));
  }

  Future<void> deleteHabit(String habitId) async {
    final habits = await getHabits();
    habits.removeWhere((h) => h.id == habitId);
    
    final prefs = await SharedPreferences.getInstance();
    final jsonList = habits.map((h) => h.toJson()).toList();
    await prefs.setString(_keyHabits, jsonEncode(jsonList));
    
    // Also delete all completions for this habit
    final completions = await getHabitCompletions();
    completions.removeWhere((c) => c.habitId == habitId);
    final completionJsonList = completions.map((c) => c.toJson()).toList();
    await prefs.setString(_keyHabitCompletions, jsonEncode(completionJsonList));
  }

  Future<List<HabitCompletion>> getHabitCompletions() async {
    final prefs = await SharedPreferences.getInstance();
    final completionsString = prefs.getString(_keyHabitCompletions);
    
    if (completionsString == null) return [];
    
    final jsonList = jsonDecode(completionsString) as List;
    return jsonList
        .map((json) => HabitCompletion.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> toggleHabitCompletion(String habitId, DateTime date) async {
    final completions = await getHabitCompletions();
    
    // Normalize date to start of day for comparison
    final normalizedDate = DateTime(date.year, date.month, date.day);
    
    final existingIndex = completions.indexWhere((c) =>
        c.habitId == habitId &&
        c.date.year == normalizedDate.year &&
        c.date.month == normalizedDate.month &&
        c.date.day == normalizedDate.day);
    
    if (existingIndex >= 0) {
      // Remove if already completed
      completions.removeAt(existingIndex);
    } else {
      // Add completion
      completions.add(HabitCompletion(
        habitId: habitId,
        date: normalizedDate,
      ));
    }
    
    final prefs = await SharedPreferences.getInstance();
    final jsonList = completions.map((c) => c.toJson()).toList();
    await prefs.setString(_keyHabitCompletions, jsonEncode(jsonList));
  }

  Future<bool> isHabitCompletedOn(String habitId, DateTime date) async {
    final completions = await getHabitCompletions();
    final normalizedDate = DateTime(date.year, date.month, date.day);
    
    return completions.any((c) =>
        c.habitId == habitId &&
        c.date.year == normalizedDate.year &&
        c.date.month == normalizedDate.month &&
        c.date.day == normalizedDate.day);
  }

  Future<int> getHabitCompletionCount(String habitId, DateTime startDate, DateTime endDate) async {
    final completions = await getHabitCompletions();
    
    return completions.where((c) {
      return c.habitId == habitId &&
          c.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          c.date.isBefore(endDate.add(const Duration(days: 1)));
    }).length;
  }

  Future<bool> areAllHabitsCompletedOn(DateTime date) async {
    final habits = await getHabits();
    final normalizedDate = DateTime(date.year, date.month, date.day);
    
    for (final habit in habits) {
      final isCompleted = await isHabitCompletedOn(habit.id, normalizedDate);
      if (!isCompleted) return false;
    }
    
    return habits.isNotEmpty;
  }

  Future<double> getHabitCompletionPercentage(DateTime date) async {
    final habits = await getHabits();
    if (habits.isEmpty) return 0.0;
    
    final normalizedDate = DateTime(date.year, date.month, date.day);
    int completedCount = 0;
    
    for (final habit in habits) {
      final isCompleted = await isHabitCompletedOn(habit.id, normalizedDate);
      if (isCompleted) completedCount++;
    }
    
    return completedCount / habits.length;
  }

  // ============ INSTALL PROMPT METHODS ============

  Future<bool> hasSeenInstallPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyInstallPromptSeen) ?? false;
  }

  Future<void> setInstallPromptSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyInstallPromptSeen, true);
  }
}

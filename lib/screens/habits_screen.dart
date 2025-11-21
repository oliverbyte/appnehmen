import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'package:intl/intl.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  final _storageService = StorageService();
  List<Habit> _habits = [];
  List<HabitCompletion> _completions = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final habits = await _storageService.getHabits();
    final completions = await _storageService.getHabitCompletions();
    setState(() {
      _habits = habits;
      _completions = completions;
      _isLoading = false;
    });
  }

  Future<void> _toggleHabit(String habitId) async {
    await _storageService.toggleHabitCompletion(habitId, _selectedDate);
    await _loadData();
  }

  bool _isCompletedToday(String habitId) {
    final today = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    return _completions.any((c) =>
        c.habitId == habitId &&
        c.date.year == today.year &&
        c.date.month == today.month &&
        c.date.day == today.day);
  }



  Future<void> _showEditDialog(Habit? habit) async {
    final isEdit = habit != null;
    final nameController = TextEditingController(text: habit?.name ?? '');
    final descriptionController = TextEditingController(text: habit?.description ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Gewohnheit bearbeiten' : 'Neue Gewohnheit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Beschreibung',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;

              final newHabit = Habit(
                id: habit?.id ?? 'habit_${DateTime.now().millisecondsSinceEpoch}',
                name: nameController.text.trim(),
                description: descriptionController.text.trim(),
                isDefault: habit?.isDefault ?? false,
              );

              await _storageService.saveHabit(newHabit);
              if (context.mounted) Navigator.of(context).pop(true);
            },
            child: Text(isEdit ? 'Speichern' : 'Hinzufügen'),
          ),
        ],
      ),
    );

    if (result == true) await _loadData();
  }

  Future<void> _deleteHabit(Habit habit) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gewohnheit löschen?'),
        content: Text('Möchtest du "${habit.name}" wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _storageService.deleteHabit(habit.id);
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gewohnheiten'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Week overview
                _buildWeekOverview(),
                const Divider(height: 1),
                // Heutige Gewohnheiten
                Expanded(
                  child: _habits.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'Noch keine Gewohnheiten',
                                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _habits.length,
                          itemBuilder: (context, index) {
                            final habit = _habits[index];
                            final isCompleted = _isCompletedToday(habit.id);
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                leading: Checkbox(
                                  value: isCompleted,
                                  onChanged: (_) => _toggleHabit(habit.id),
                                  activeColor: Colors.green,
                                ),
                                title: Text(
                                  habit.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(habit.description),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.green[700]),
                                      onPressed: () => _showEditDialog(habit),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.grey[600]),
                                      onPressed: () => _deleteHabit(habit),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(null),
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  int _getWeekNumber(DateTime date) {
    // ISO 8601 week number
    final dayOfYear = int.parse(DateFormat("D").format(date));
    final woy = ((dayOfYear - date.weekday + 10) / 7).floor();
    if (woy == 0) {
      return _getWeekNumber(DateTime(date.year - 1, 12, 31));
    }
    if (woy == 53 && DateTime(date.year, 12, 31).weekday < 4) {
      return 1;
    }
    return woy;
  }

  Widget _buildWeekOverview() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.green[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Diese Woche',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
              Text(
                'KW ${_getWeekNumber(now)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final date = startOfWeek.add(Duration(days: index));
              final isToday = date.day == now.day && 
                              date.month == now.month && 
                              date.year == now.year;
              final isFuture = date.isAfter(now);
              
              return FutureBuilder<double>(
                future: _storageService.getHabitCompletionPercentage(date),
                builder: (context, snapshot) {
                  final percentage = snapshot.data ?? 0.0;
                  final allCompleted = percentage >= 1.0;
                  
                  // Calculate green shade based on completion percentage
                  Color bgColor;
                  Color textColor;
                  
                  if (isFuture) {
                    bgColor = Colors.grey[300]!;
                    textColor = Colors.grey[600]!;
                  } else if (percentage == 0.0) {
                    bgColor = isToday ? Colors.orange[100]! : Colors.white;
                    textColor = Colors.green[900]!;
                  } else {
                    // Gradient from light green to vibrant green based on percentage
                    // More granular shading for better visual feedback
                    int shade;
                    if (percentage <= 0.2) {
                      shade = 100; // 0-20%: very light
                    } else if (percentage <= 0.4) {
                      shade = 200; // 20-40%: light
                    } else if (percentage <= 0.6) {
                      shade = 300; // 40-60%: medium light
                    } else if (percentage <= 0.8) {
                      shade = 400; // 60-80%: medium
                    } else if (percentage < 1.0) {
                      shade = 500; // 80-99%: vibrant
                    } else {
                      shade = 600; // 100%: full completion - saturated but not too dark
                    }
                    
                    bgColor = Colors.green[shade]!;
                    textColor = percentage >= 0.6 ? Colors.white : Colors.green[900]!;
                  }
                  
                  return GestureDetector(
                    onTap: isFuture ? null : () {
                      setState(() => _selectedDate = date);
                    },
                    child: Container(
                      width: 40,
                      height: 60,
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isToday ? Colors.orange : Colors.green[300]!,
                          width: isToday ? 3 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('E', 'de_DE').format(date).substring(0, 2),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              DateFormat('EEEE, d. MMMM', 'de_DE').format(_selectedDate),
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.green[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

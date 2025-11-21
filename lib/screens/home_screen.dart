// Appnehmen - Weight Loss Tracking PWA
// Copyright (c) 2025 Oliver Byte
// Licensed under the MIT License - see LICENSE file for details

import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../widgets/install_banner.dart';
import 'emergency_checklist_screen.dart';
import 'weight_history_screen.dart';
import 'info_screen.dart';
import 'habits_screen.dart';

// Helper function to format numbers with German comma
String _formatGermanNumber(double number, int decimalPlaces) {
  return number.toStringAsFixed(decimalPlaces).replaceAll('.', ',');
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storageService = StorageService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await _storageService.getUserData();
    setState(() {
      _userData = data;
      _isLoading = false;
    });
  }

  Future<void> _showAddWeightDialog() async {
    final weightController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Neues Gewicht eingeben'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'Gewicht (kg)',
                hintText: 'z.B. 75,5',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.monitor_weight),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            Text(
              'Dein aktuelles Gewicht: ${_formatGermanNumber(_userData!['currentWeight'] as double, 1)} kg',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              // Convert German comma to decimal point
              final normalizedText = weightController.text.replaceAll(',', '.');
              final weight = double.tryParse(normalizedText);
              if (weight != null && weight > 0 && weight < 500) {
                Navigator.of(context).pop(true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bitte gib ein gültiges Gewicht ein'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Speichern'),
          ),
        ],
      ),
    );

    if (result == true && weightController.text.isNotEmpty) {
      final normalizedText = weightController.text.replaceAll(',', '.');
      final weight = double.parse(normalizedText);
      await _storageService.addWeightEntry(weight);
      await _loadUserData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gewicht gespeichert: ${_formatGermanNumber(weight, 1)} kg'),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _showEditWhyDialog() async {
    final whyController = TextEditingController(text: _userData!['why'] as String);
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dein Warum bearbeiten'),
        content: TextField(
          controller: whyController,
          decoration: const InputDecoration(
            labelText: 'Dein Warum',
            hintText: 'Warum möchtest du abnehmen?',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.favorite),
          ),
          maxLines: 4,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              if (whyController.text.isNotEmpty) {
                Navigator.of(context).pop(true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bitte beschreibe dein Warum'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Speichern'),
          ),
        ],
      ),
    );

    if (result == true && whyController.text.isNotEmpty) {
      await _storageService.updateWhy(whyController.text);
      await _loadUserData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Dein Warum wurde aktualisiert'),
            backgroundColor: Colors.purple[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  double get _weightToLose {
    if (_userData == null) return 0;
    final current = _userData!['currentWeight'] as double;
    final target = _userData!['targetWeight'] as double;
    return current - target;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appnehmen'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green[700],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        // Bathroom scale base
                        Positioned(
                          left: 10,
                          right: 10,
                          bottom: 10,
                          height: 22,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.green[700],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        // Display screen
                        Positioned(
                          left: 14,
                          right: 14,
                          bottom: 14,
                          height: 10,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        // Big down arrow
                        Positioned(
                          left: 18,
                          right: 18,
                          top: 6,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.green[700],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                size: 20,
                                color: Colors.green[700],
                              ),
                            ],
                          ),
                        ),
                        // Minus symbol on arrow
                        Positioned(
                          left: 22,
                          right: 22,
                          top: 12,
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Appnehmen',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Hallo ${_userData!['name']}!',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.green[700]),
              title: const Text('Startseite'),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(Icons.show_chart, color: Colors.green[600]),
              title: const Text('Gewichtsverlauf'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const WeightHistoryScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.add_circle_outline, color: Colors.green[700]),
              title: const Text('Gewicht hinzufügen'),
              onTap: () {
                Navigator.of(context).pop();
                _showAddWeightDialog();
              },
            ),
            ListTile(
              leading: Icon(Icons.check_circle_outline, color: Colors.teal[700]),
              title: const Text('Gewohnheiten'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const HabitsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.sos, color: Colors.orange[600]),
              title: const Text('Heißhunger-Notfall'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const EmergencyChecklistScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.info_outline, color: Colors.grey[700]),
              title: const Text('Info'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const InfoScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Install banner at the top
          const InstallBanner(),
          // Main content
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green[700],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hallo ${_userData!['name']}! 👋',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Noch ${_formatGermanNumber(_weightToLose, 1)} kg bis zum Ziel',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green[50],
                      ),
                    ),
                  ],
                ),
            ),
            
            const SizedBox(height: 24),
            
            // Dein Warum - ganz oben
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.favorite, color: Colors.green[700], size: 20),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Dein Warum',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.green[700], size: 20),
                            onPressed: _showEditWhyDialog,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _userData!['why'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green[900],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
            ),
            
            const SizedBox(height: 24),
            
            // 3 Hauptbereiche
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // 1. Mein Gewicht
                    _buildMainSection(
                      icon: Icons.monitor_weight,
                      title: 'Mein Gewicht',
                      color: Colors.green,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const WeightHistoryScreen(),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildWeightInfo(
                                'Aktuell',
                                _formatGermanNumber(_userData!['currentWeight'] as double, 1),
                              ),
                              Container(
                                height: 40,
                                width: 1,
                                color: Colors.green[200],
                              ),
                              _buildWeightInfo(
                                'Ziel',
                                _formatGermanNumber(_userData!['targetWeight'] as double, 1),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _showAddWeightDialog,
                              icon: const Icon(Icons.add, size: 20),
                              label: const Text('Gewicht hinzufügen'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[600],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 2. Meine Gewohnheiten
                    _buildMainSection(
                      icon: Icons.check_circle_outline,
                      title: 'Meine Gewohnheiten',
                      color: Colors.green,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const HabitsScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Tracke deine täglichen Gewohnheiten für langfristigen Erfolg',
                        style: TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 3. Heißhunger-Notfall
                    _buildMainSection(
                      icon: Icons.sos,
                      title: 'Heißhunger-Notfall',
                      color: Colors.orange,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const EmergencyChecklistScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Schnelle Hilfe bei akutem Heißhunger',
                        style: TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          )
        )
      );
  }

  Widget _buildMainSection({
    required IconData icon,
    required String title,
    required MaterialColor color,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color[200]!),
          boxShadow: [
            BoxShadow(
              color: color[100]!.withValues(alpha: 0.5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color[700], size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color[900],
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: color[400], size: 18),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildWeightInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.green[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$value kg',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green[900],
          ),
        ),
      ],
    );
  }
}

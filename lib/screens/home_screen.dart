// Appnehmen - Weight Loss Tracking PWA
// Copyright (c) 2025 Oliver Byte
// Licensed under the MIT License - see LICENSE file for details

import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'emergency_checklist_screen.dart';
import 'weight_history_screen.dart';
import 'info_screen.dart';

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
                hintText: 'z.B. 75,5 oder 75.5',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.monitor_weight),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            Text(
              'Dein aktuelles Gewicht: ${_userData!['currentWeight']} kg',
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
            content: Text('Gewicht gespeichert: ${weight.toStringAsFixed(1)} kg'),
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
                  Icon(
                    Icons.fitness_center,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Appnehmen',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Hallo ${_userData!['name']}!',
                    style: TextStyle(
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
              leading: Icon(Icons.show_chart, color: Colors.blue[700]),
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
              leading: Icon(Icons.sos, color: Colors.orange[700]),
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
              leading: Icon(Icons.info_outline, color: Colors.purple[700]),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Hallo ${_userData!['name']}! 👋',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                icon: Icons.monitor_weight,
                title: 'Aktuelles Gewicht',
                value: '${_userData!['currentWeight']} kg',
                color: Colors.blue,
                onTap: _showAddWeightDialog,
                trailingIcon: Icons.edit,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                icon: Icons.flag,
                title: 'Wunschgewicht',
                value: '${_userData!['targetWeight']} kg',
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                icon: Icons.trending_down,
                title: 'Noch zu verlieren',
                value: '${_weightToLose.toStringAsFixed(1)} kg',
                color: Colors.orange,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.favorite, color: Colors.purple[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Dein Warum',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple[900],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.purple[700], size: 20),
                          onPressed: _showEditWhyDialog,
                          tooltip: 'Bearbeiten',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _userData!['why'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.purple[800],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const WeightHistoryScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.show_chart, size: 24),
                      label: const Text(
                        'Verlauf',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showAddWeightDialog,
                      icon: const Icon(Icons.add_circle_outline, size: 24),
                      label: const Text(
                        'Gewicht',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const EmergencyChecklistScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.sos, size: 28),
                label: const Text(
                  'Heißhunger-Notfall!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required MaterialColor color,
    VoidCallback? onTap,
    IconData? trailingIcon,
  }) {
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color[700], size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: color[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color[900],
                  ),
                ),
              ],
            ),
          ),
          if (trailingIcon != null)
            Icon(trailingIcon, color: color[700], size: 24),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: card,
      );
    }
    return card;
  }
}

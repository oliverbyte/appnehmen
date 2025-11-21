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
                  SnackBar(
                    content: const Text('Bitte gib ein gültiges Gewicht ein'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Speichern',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
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
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Abbrechen',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (whyController.text.trim().isEmpty) return;
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Speichern',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
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
      body: Builder(
        builder: (context) => Column(
          children: [
            // Install banner ganz oben
            const InstallBanner(),
            // AppBar als Widget
            Container(
              color: Colors.green[700],
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'Appnehmen',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Main content
            Expanded(
              child: _buildMainContent(),
            ),
          ],
        ),
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
    );
  }

  Widget _buildMainContent() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            
            // Header mit Name und Fortschritt
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green[200]!, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green[100]!.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          '👋',
                          style: TextStyle(fontSize: 28),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hallo ${_userData!['name']}!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.green[900],
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Noch ${_formatGermanNumber(_weightToLose, 1)} kg bis zum Ziel',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[700],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ),
            
            const SizedBox(height: 20),
            
            // Mein Warum
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green[200]!, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green[100]!.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(Icons.favorite, color: Colors.green[700], size: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mein Warum',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green[900],
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _userData!['why'] as String,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[700],
                                    height: 1.5,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit_outlined, color: Colors.green[700], size: 22),
                            onPressed: _showEditWhyDialog,
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                            tooltip: 'Bearbeiten',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ),
            
            const SizedBox(height: 28),
            
            // 3 Hauptbereiche
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _showAddWeightDialog,
                              icon: const Icon(Icons.add, size: 22),
                              label: const Text(
                                'Gewicht hinzufügen',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[600],
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // 2. Meine Gewohnheiten
                    _buildMainSectionWithSubtext(
                      icon: Icons.check_circle_outline,
                      title: 'Meine Gewohnheiten',
                      subtext: 'Tracke deine täglichen Gewohnheiten für langfristigen Erfolg',
                      color: Colors.green,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const HabitsScreen(),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // 3. Heißhunger-Notfall
                    _buildMainSectionWithSubtext(
                      icon: Icons.sos,
                      title: 'Heißhunger-Notfall',
                      subtext: 'Schnelle Hilfe bei akutem Heißhunger',
                      color: Colors.orange,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const EmergencyChecklistScreen(),
                          ),
                        );
                      },
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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color[200]!, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color[100]!.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color[700], size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: color[900],
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: color[400], size: 32),
              ],
            ),
            const SizedBox(height: 20),
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

  Widget _buildMainSectionWithSubtext({
    required IconData icon,
    required String title,
    required String subtext,
    required MaterialColor color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color[200]!, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color[100]!.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color[700], size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: color[900],
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtext,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color[400], size: 32),
          ],
        ),
      ),
    );
  }
}

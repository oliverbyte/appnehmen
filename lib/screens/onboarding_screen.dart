import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/analytics_service.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _currentWeightController = TextEditingController();
  final _targetWeightController = TextEditingController();
  final _whyController = TextEditingController();
  final _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    AnalyticsService.trackScreenView('onboarding');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentWeightController.dispose();
    _targetWeightController.dispose();
    _whyController.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue() async {
    if (_formKey.currentState!.validate()) {
      // Convert German comma to decimal point
      final currentWeight = double.parse(_currentWeightController.text.replaceAll(',', '.'));
      final targetWeight = double.parse(_targetWeightController.text.replaceAll(',', '.'));
      
      await _storageService.saveUserData(
        name: _nameController.text,
        currentWeight: currentWeight,
        targetWeight: targetWeight,
        why: _whyController.text,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Text(
                  'Willkommen bei \n"Einfach Appnehmen"',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Deine Reise beginnt hier',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Dein Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte gib deinen Namen ein';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _currentWeightController,
                  decoration: InputDecoration(
                    labelText: 'Aktuelles Gewicht (kg)',
                    hintText: 'z.B. 75,5',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.monitor_weight),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte gib dein aktuelles Gewicht ein';
                    }
                    // Convert German comma to decimal point for validation
                    final normalizedValue = value.replaceAll(',', '.');
                    if (double.tryParse(normalizedValue) == null) {
                      return 'Bitte gib eine gültige Zahl ein';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _targetWeightController,
                  decoration: InputDecoration(
                    labelText: 'Wunschgewicht (kg)',
                    hintText: 'z.B. 65,0',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.flag),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte gib dein Wunschgewicht ein';
                    }
                    // Convert German comma to decimal point for validation
                    final normalizedValue = value.replaceAll(',', '.');
                    if (double.tryParse(normalizedValue) == null) {
                      return 'Bitte gib eine gültige Zahl ein';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _whyController,
                  decoration: InputDecoration(
                    labelText: 'Dein Warum',
                    hintText: 'Warum möchtest du abnehmen?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.favorite),
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte beschreibe dein Warum';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                
                // Autor & Motivation
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person_outline, color: Colors.blue[700], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Über diese App',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[900],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Entwickelt von jemandem, der selbst 45kg abgenommen hat: Olli. Entstanden aus dem Wunsch heraus, anderen auf ihrer Reise zu helfen – mit Tools, die wirklich funktionieren.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                ElevatedButton(
                  onPressed: _saveAndContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Los geht\'s!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Trust Badges
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildTrustItem(
                          icon: Icons.public,
                          text: 'Made in Germany 🇩🇪',
                          color: Colors.grey[700],
                        ),
                        const SizedBox(height: 8),
                        _buildTrustItem(
                          icon: Icons.lock_outline,
                          text: 'SSL-verschlüsselte Verbindung',
                          color: Colors.green,
                        ),
                            const SizedBox(height: 8),
                            _buildTrustItem(
                              icon: Icons.phone_android,
                              text: 'Alle Daten nur lokal auf deinem Gerät',
                              color: Colors.blue,
                            ),
                        const SizedBox(height: 8),
                        _buildTrustItem(
                          icon: Icons.shield_outlined,
                          text: 'Keine Cloud, keine Server, keine Weitergabe',
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTrustItem({
    required IconData icon,
    required String text,
    required dynamic color,
  }) {
    final iconColor = color is MaterialColor ? color[700] : color;
    
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }
}

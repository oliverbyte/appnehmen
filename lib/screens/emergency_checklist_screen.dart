import 'package:flutter/material.dart';
import 'dart:async';
import '../services/analytics_service.dart';

class EmergencyChecklistScreen extends StatefulWidget {
  const EmergencyChecklistScreen({super.key});

  @override
  State<EmergencyChecklistScreen> createState() =>
      _EmergencyChecklistScreenState();
}

class _EmergencyChecklistScreenState extends State<EmergencyChecklistScreen> {
  bool _step1Complete = false;
  bool _step2Complete = false;
  bool _step3Complete = false;
  bool _timerStarted = false;
  int _secondsRemaining = 600; // 10 minutes = 600 seconds
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    AnalyticsService.trackScreenView('emergency_checklist');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _timerStarted = true;
      _secondsRemaining = 600;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  bool get _allStepsComplete => _step1Complete && _step2Complete && _step3Complete && _timerStarted && _secondsRemaining == 0;

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heißhunger-Notfall'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 40, color: Colors.orange[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Heißhunger? Kein Problem!\nFolge diesen Schritten:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Step 1: Trinken
              _buildStep(
                number: '1',
                title: 'Viel trinken (mind. 2 Gläser)',
                isComplete: _step1Complete,
                onToggle: () => setState(() => _step1Complete = !_step1Complete),
                items: [
                  _buildSubItem('✓ Tee (warm, Ingwer, Mate)', Colors.green),
                  _buildSubItem('✓ Sprudelwasser (mit Zitrone/Eiswürfeln)', Colors.green),
                  _buildSubItem('✓ Gemüsebrühe', Colors.green),
                  _buildSubItem('❌ Cola (Koffein → Schlafprobleme, Süßungsmittel → Heißhunger, Zucker → Zahnschmerzen & Abhängigkeit)', Colors.red),
                  _buildSubItem('❌ Alkohol (hemmt Abnahme)', Colors.red),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Step 2: Handeln
              _buildStep(
                number: '2',
                title: 'Handeln',
                isComplete: _step2Complete,
                onToggle: () => setState(() => _step2Complete = !_step2Complete),
                items: [
                  _buildSubItem('✓ Kaltes Wasser über Hände', Colors.green),
                  _buildSubItem('✓ Zähneputzen mit Minze', Colors.green),
                  _buildSubItem('✓ Kaugummi ohne Zucker', Colors.green),
                  _buildSubItem('✓ Jemandem schreiben', Colors.green),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Step 3: Bewegen
              _buildStep(
                number: '3',
                title: 'Bewegen',
                isComplete: _step3Complete,
                onToggle: () => setState(() => _step3Complete = !_step3Complete),
                items: [
                  _buildSubItem('✓ 1-3 Min Kniebeugen', Colors.green),
                  _buildSubItem('✓ Treppe laufen', Colors.green),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Timer Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[300]!),
                ),
                child: Column(
                  children: [
                    Text(
                      '⏱️ 10 Minuten warten',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_timerStarted)
                      Text(
                        _formatTime(_secondsRemaining),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: _secondsRemaining == 0 ? Colors.green[700] : Colors.blue[700],
                        ),
                      ),
                    const SizedBox(height: 12),
                    if (!_timerStarted)
                      ElevatedButton.icon(
                        onPressed: _step1Complete && _step2Complete && _step3Complete ? _startTimer : null,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Timer starten'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      )
                    else if (_secondsRemaining == 0)
                      Icon(Icons.check_circle, size: 48, color: Colors.green[600]),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Step 4: Essen (optional)
              _buildExpandableSection(
                title: '4. Immer noch Hunger? Gesunde Optionen:',
                items: [
                  _buildSubItem('✓ Gemüse (Möhren, Tomaten, Paprika)', Colors.green),
                  _buildSubItem('✓ Skyr, Magerquark (≤20% Fett)', Colors.green),
                  _buildSubItem('✓ Handvoll Nüsse', Colors.green),
                  _buildSubItem('✓ Gekochtes Ei', Colors.green),
                  _buildSubItem('❌ Obst (Zucker)', Colors.red),
                  _buildSubItem('❌ Schokolade (süchtig machend)', Colors.red),
                  _buildSubItem('❌ Chips (Fett)', Colors.red),
                ],
              ),
              
              const SizedBox(height: 24),
              
              if (_allStepsComplete)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[300]!),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.celebration, size: 48, color: Colors.green[600]),
                      const SizedBox(height: 12),
                      Text(
                        'Fantastisch!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Du hast alle Schritte gemeistert! 💪',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep({
    required String number,
    required String title,
    required bool isComplete,
    required VoidCallback onToggle,
    required List<Widget> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isComplete ? Colors.green[50] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isComplete ? Colors.green[300]! : Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isComplete ? Colors.green[600] : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isComplete
                        ? const Icon(Icons.check, color: Colors.white, size: 24)
                        : Text(
                            number,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isComplete ? Colors.green[800] : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 52),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 52),
            child: ElevatedButton(
              onPressed: onToggle,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(isComplete ? '✓ Erledigt' : 'Als erledigt markieren'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubItem(String text, MaterialColor color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: color[800],
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required List<Widget> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 12),
          ...items,
        ],
      ),
    );
  }
}

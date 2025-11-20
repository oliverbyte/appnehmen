import 'package:flutter/material.dart';
import 'dart:async';

class EmergencyChecklistScreen extends StatefulWidget {
  const EmergencyChecklistScreen({super.key});

  @override
  State<EmergencyChecklistScreen> createState() =>
      _EmergencyChecklistScreenState();
}

class _EmergencyChecklistScreenState extends State<EmergencyChecklistScreen> {
  bool _step1Complete = false;
  bool _step2Started = false;
  int _secondsRemaining = 600; // 10 minutes = 600 seconds
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _step2Started = true;
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
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
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
              const SizedBox(height: 32),
              _buildChecklistItem(
                number: '1',
                title: '2 Gläser Wasser trinken',
                description: 'Trinke langsam 2 große Gläser Wasser (ca. 500ml)',
                isComplete: _step1Complete,
                onToggle: () {
                  setState(() {
                    _step1Complete = !_step1Complete;
                  });
                },
              ),
              const SizedBox(height: 24),
              _buildChecklistItem(
                number: '2',
                title: '10 Minuten warten',
                description: _step2Started
                    ? 'Noch ${_formatTime(_secondsRemaining)} verbleiben'
                    : 'Warte 10 Minuten ab, bevor du etwas isst',
                isComplete: _step2Started && _secondsRemaining == 0,
                onToggle: _step1Complete && !_step2Started ? _startTimer : null,
                buttonText: _step2Started ? null : 'Timer starten',
              ),
              const Spacer(),
              if (_step2Started && _secondsRemaining == 0)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[300]!),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle,
                          size: 48, color: Colors.green[600]),
                      const SizedBox(height: 12),
                      Text(
                        'Gut gemacht!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hast du immer noch Hunger? Dann gönn dir eine gesunde Kleinigkeit!',
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

  Widget _buildChecklistItem({
    required String number,
    required String title,
    required String description,
    required bool isComplete,
    VoidCallback? onToggle,
    String? buttonText,
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isComplete ? Colors.green[600] : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isComplete
                      ? const Icon(Icons.check, color: Colors.white)
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
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isComplete ? Colors.green[800] : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 56),
            child: Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
          if (onToggle != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 56),
              child: ElevatedButton(
                onPressed: onToggle,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isComplete ? Colors.grey[400] : Colors.blue[600],
                  foregroundColor: Colors.white,
                ),
                child: Text(buttonText ??
                    (isComplete ? 'Erledigt ✓' : 'Als erledigt markieren')),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

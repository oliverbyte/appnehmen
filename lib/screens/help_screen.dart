import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hilfe'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.help_outline,
                    size: 60,
                    color: Colors.green[700],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'App installieren',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[900],
                    ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: Colors.blue[700], size: 28),
                        const SizedBox(width: 12),
                        Text(
                          'Wichtiger Tipp',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Öffne die App in deinem Browser (Chrome oder Safari), nicht in WhatsApp oder anderen Apps!\n\nNur im Browser kannst du die App auf deinem Handy installieren.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.android, color: Colors.green[700], size: 28),
                        const SizedBox(width: 12),
                        Text(
                          'Android Installation',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildStep('1', 'Öffne die App in Chrome oder deinem Standard-Browser'),
                    _buildStep('2', 'Tippe oben rechts auf die drei Punkte (⋮)'),
                    _buildStep('3', 'Wähle "App installieren" oder "Zum Startbildschirm"'),
                    _buildStep('4', 'Bestätige mit "Installieren"'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Fertig! Die App ist jetzt auf deinem Startbildschirm',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.apple, color: Colors.grey[800], size: 28),
                        const SizedBox(width: 12),
                        Text(
                          'iPhone/iPad Installation',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildStep('1', 'Öffne die App in Safari (wichtig: Safari, nicht Chrome!)'),
                    _buildStep('2', 'Tippe unten auf das Teilen-Symbol (□↑)'),
                    _buildStep('3', 'Scrolle nach unten und wähle "Zum Home-Bildschirm"'),
                    _buildStep('4', 'Tippe oben rechts auf "Hinzufügen"'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.grey[700], size: 20),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Fertig! Die App ist jetzt auf deinem Home-Bildschirm',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange[700], size: 28),
                        const SizedBox(width: 12),
                        Text(
                          'Warum installieren?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildBenefit('📱', 'App erscheint wie eine normale App auf deinem Handy'),
                    _buildBenefit('⚡', 'Schneller Start - kein Browser nötig'),
                    _buildBenefit('🔒', 'Alle Daten bleiben sicher auf deinem Gerät'),
                    _buildBenefit('📶', 'Funktioniert auch ohne Internet'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.green[700],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefit(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

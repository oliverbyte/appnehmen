import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../build_info.dart';
import '../services/analytics_service.dart';
import 'dart:html' as html;

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  Future<void> _clearCacheAndReload(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cache löschen'),
        content: const Text(
          'Cache und Service Worker werden gelöscht, um die neueste Version zu laden.\n\nDeine Daten bleiben erhalten!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Löschen', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Clear all caches
      final cacheNames = await html.window.caches?.keys();
      if (cacheNames != null) {
        for (final cacheName in cacheNames) {
          await html.window.caches?.delete(cacheName);
        }
      }

      // Unregister service workers
      final registrations = await html.window.navigator.serviceWorker?.getRegistrations();
      if (registrations != null) {
        for (final registration in registrations) {
          await registration.unregister();
        }
      }

      // Show success message and reload
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cache gelöscht. App wird neu geladen...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Reload page after short delay
      await Future.delayed(const Duration(milliseconds: 1000));
      html.window.location.reload();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Löschen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AnalyticsService.trackScreenView('info');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Info'),
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
                    Icons.info_outline,
                    size: 60,
                    color: Colors.green[700],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Über "Einfach Appnehmen"',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[900],
                    ),
              ),
              const SizedBox(height: 16),
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
                        Icon(Icons.person, color: Colors.green[700], size: 28),
                        const SizedBox(width: 12),
                        Text(
                          'Über mich',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Ich habe selbst 45 Kilo abgenommen – mit Hilfe von kilos-verlasst-mich.de (Danke an Melli!) und meiner Frau – und möchte mit diesen kleinen aber wirksamen Alltagswerkzeugen anderen helfen, dasselbe zu erreichen.',
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
                        Icon(Icons.privacy_tip, color: Colors.green[700], size: 28),
                        const SizedBox(width: 12),
                        Text(
                          'Datenschutz',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Alle deine persönlichen Daten (Gewicht, Gewohnheiten) werden ausschließlich lokal auf deinem Gerät gespeichert.\n\nZur Verbesserung der App werden anonyme Nutzungsstatistiken erfasst (Anzahl Nutzer, letzte Nutzung, App-Version). Diese Daten sind nicht personenbezogen und dienen rein statistischen Zwecken – ohne Zustimmungspflicht gemäß DSGVO Art. 6 Abs. 1 lit. f.',
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
                        Icon(Icons.info_outline, color: Colors.green[700], size: 28),
                        const SizedBox(width: 12),
                        Text(
                          'Wichtiger Hinweis',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Ich bin kein Arzt, Ernährungsberater oder ähnlich qualifiziert. Die Inhalte dieser App basieren ausschließlich auf meinen persönlichen Erfahrungen. Bei gesundheitlichen Fragen oder Unsicherheiten konsultiere bitte einen Fachmann.',
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
                        Icon(Icons.email, color: Colors.green[700], size: 28),
                        const SizedBox(width: 12),
                        Text(
                          'Feedback & Anregungen',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Ich freue mich jederzeit über Feedback und Anregungen via E-Mail:',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final url = Uri.parse('mailto:info@oliverbyte.de');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.email_outlined, color: Colors.green[700], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'info@oliverbyte.de',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[900],
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '(Freizeitprojekt, kein Support)',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Commit: $buildCommitId',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => _clearCacheAndReload(context),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Cache löschen & neu laden'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[400]!),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'MIT License © 2025 Oliver Byte',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Open Source - Frei nutzbar',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final url = Uri.parse('https://github.com/oliverbyte/appnehmen');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.code, size: 16, color: Colors.blue[700]),
                          const SizedBox(width: 6),
                          Text(
                            'github.com/oliverbyte/appnehmen',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
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

  Widget _buildBulletPoint(String text, MaterialColor color) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

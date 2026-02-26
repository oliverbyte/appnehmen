import 'package:flutter/material.dart';
import '../services/analytics_service.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  @override
  void initState() {
    super.initState();
    AnalyticsService.trackScreenView('news');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Was ist neu?'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNewsSection(
            'Februar 2026',
            [
              _NewsItem(
                icon: Icons.bug_report,
                title: 'Bugfix: Gewichtsdiagramm zeigt neueste Einträge',
                description: 'Das Gewichtsdiagramm zeigt jetzt korrekt alle neuesten Gewichtseinträge an. Die Trendlinie und der Verlauf sind nun immer aktuell.',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildNewsSection(
            'Januar 2026',
            [
              _NewsItem(
                icon: Icons.calendar_view_week,
                title: 'Flexible Zeitraumauswahl für Gewichtsdiagramm',
                description: 'Wähle den Zeitraum für dein Gewichtsdiagramm: 7 Tage, 14 Tage, 4 Wochen (Standard), 3 Monate, 6 Monate, 1 Jahr, 5 Jahre oder 10 Jahre. So behältst du sowohl kurzfristige als auch langfristige Trends im Blick.',
              ),
              _NewsItem(
                icon: Icons.show_chart,
                title: 'Trendlinie im Gewichtsdiagramm',
                description: 'Eine deutlich sichtbare Trendlinie zeigt die Gewichtsentwicklung: Grau bei neutralem Verlauf, Rot bei Gewichtszunahme, Grün bei Gewichtsabnahme.',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildNewsSection(
            'Dezember 2025',
            [
              _NewsItem(
                icon: Icons.edit,
                title: 'Zielgewicht anpassen',
                description: 'Zielgewicht jederzeit ändern, ohne bisherige Gewichtseingaben zu verlieren. Klicke einfach auf die Ziel-Anzeige.',
              ),
              _NewsItem(
                icon: Icons.add_chart,
                title: 'Gewicht im Verlauf eintragen',
                description: 'Neues Gewicht kann jetzt auch direkt im Gewichtsverlauf-Tab eingetragen werden.',
              ),
              _NewsItem(
                icon: Icons.calendar_today,
                title: 'Verbesserte Tag-Auswahl',
                description: 'Der ausgewählte Tag bei Gewohnheiten wird jetzt deutlicher hervorgehoben.',
              ),
              _NewsItem(
                icon: Icons.new_releases,
                title: 'Was ist neu?',
                description: 'Neuer Menüpunkt zeigt alle Änderungen und neuen Funktionen übersichtlich an.',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildNewsSection(
            'November 2025',
            [
              _NewsItem(
                icon: Icons.celebration,
                title: 'Konfetti-Feier',
                description: 'Bei Gewichtsverlust oder abgeschlossenen Gewohnheiten gibt\'s jetzt eine kleine Konfetti-Animation! 🎉',
              ),
              _NewsItem(
                icon: Icons.lightbulb,
                title: 'Tägliche Tipps',
                description: 'Erhalte jeden Tag einen hilfreichen Tipp zum Abnehmen - maximal ein Tipp pro Tag.',
              ),
              _NewsItem(
                icon: Icons.trending_down,
                title: 'Fortschritts-Visualisierung',
                description: 'Die Gewohnheiten zeigen jetzt mit Farbverläufen deinen Fortschritt - je grüner, desto besser!',
              ),
              _NewsItem(
                icon: Icons.check_circle,
                title: 'Gewohnheiten-Tracking',
                description: 'Tracke deine täglichen Gewohnheiten und behalte den Überblick über deine Erfolge der Woche.',
              ),
              _NewsItem(
                icon: Icons.update,
                title: 'Automatische Updates',
                description: 'Die App aktualisiert sich automatisch im Hintergrund. Du wirst benachrichtigt, wenn eine neue Version verfügbar ist.',
              ),
              _NewsItem(
                icon: Icons.install_mobile,
                title: 'Als App installieren',
                description: 'Du kannst die App jetzt auf deinem Gerät installieren und wie eine native App nutzen.',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildNewsSection(
            'Start - November 2025',
            [
              _NewsItem(
                icon: Icons.monitor_weight,
                title: 'Gewichtsverlauf',
                description: 'Verfolge deinen Gewichtsverlauf mit einem übersichtlichen Diagramm und detaillierter Historie.',
              ),
              _NewsItem(
                icon: Icons.sos,
                title: 'Heißhunger-Notfall',
                description: 'Eine praktische Checkliste hilft dir, Heißhunger-Attacken zu überstehen.',
              ),
              _NewsItem(
                icon: Icons.favorite,
                title: 'Dein Warum',
                description: 'Definiere dein persönliches "Warum" und lass dich täglich daran erinnern.',
              ),
              _NewsItem(
                icon: Icons.language,
                title: 'Deutsche Komma-Eingabe',
                description: 'Gewichte können mit deutschem Komma eingegeben werden (z.B. 75,5 kg).',
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildNewsSection(String title, List<_NewsItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green[900],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => _buildNewsItem(item)),
      ],
    );
  }

  Widget _buildNewsItem(_NewsItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              item.icon,
              color: Colors.green[700],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsItem {
  final IconData icon;
  final String title;
  final String description;

  _NewsItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

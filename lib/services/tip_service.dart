import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class Tip {
  final String id;
  final String text;

  const Tip({required this.id, required this.text});
}

class TipService {
  static const String _seenTipsKey = 'seen_tips';
  static const String _lastTipDateKey = 'last_tip_date';
  static const String _firstAppStartDateKey = 'first_app_start_date';

  // List of all available tips - can be extended at any time
  // New tips can simply be added - they will be automatically shown to users who haven't seen them yet
  static const List<Tip> _allTips = [
    Tip(
      id: 'tip_1',
      text: 'Salz bindet Wasser in deinem Körper. Eine salzige Mahlzeit kann die Waage am nächsten Tag nach oben treiben - das ist kein echtes Fett, sondern nur Wassereinlagerung!',
    ),
    Tip(
      id: 'tip_2',
      text: 'Sport führt zu Muskelaufbau, und Muskeln sind schwerer als Fett. Die Waage kann also steigen, obwohl du Fett verlierst. Miss lieber auch deinen Bauchumfang!',
    ),
    Tip(
      id: 'tip_3',
      text: 'Ein normales Bier (0,5l) hat ca. 215 kcal. Ein alkoholfreies Bier hat nur ca. 125 kcal - also fast die Hälfte weniger!',
    ),
    Tip(
      id: 'tip_4',
      text: '1 Stunde Walken verbrennt ungefähr genauso viele Kalorien wie 30 Minuten Radfahren. Wähle was dir mehr Spaß macht!',
    ),
    Tip(
      id: 'tip_5',
      text: '45kg Abnehmen ist möglich - auch mit Pizza und ohne Fitnessstudio! Entscheidend ist das Kaloriendefizit, nicht der Verzicht.',
    ),
    Tip(
      id: 'tip_6',
      text: 'Gewichtsschwankungen von bis zu 2kg am Tag sind völlig normal. Das ist kein echtes Zu- oder Abnehmen, sondern Wasser und Verdauung.',
    ),
    Tip(
      id: 'tip_7',
      text: 'Während der Periode kann dein Gewicht durch Wassereinlagerungen ansteigen. Das ist normal und geht wieder vorbei!',
    ),
    Tip(
      id: 'tip_8',
      text: 'Light-Produkte können mehr Hunger machen, weil künstliche Süßstoffe deinen Körper verwirren. Manchmal ist das Original in Maßen besser.',
    ),
    Tip(
      id: 'tip_9',
      text: 'Es gibt kostenlose Beratungsstellen für Ernährung und Gewichtsmanagement. Du musst das nicht alleine schaffen - hol dir Unterstützung!',
    ),
    Tip(
      id: 'tip_10',
      text: 'Realistisch sind 0,3-1kg Gewichtsverlust pro Woche. Alles darüber ist meist nur Wasser. Langsam ist nachhaltiger!',
    ),
    Tip(
      id: 'tip_11',
      text: 'Zusammen ist es leichter! Such dir Gleichgesinnte, tausch dich aus, motiviert euch gegenseitig. Gemeinsam zum Ziel!',
    ),
    Tip(
      id: 'tip_12',
      text: 'Wenn du abends viel isst (besonders Chips und salzige Snacks), hast du morgens oft Heißhunger. Der Blutzucker spielt verrückt!',
    ),
    Tip(
      id: 'tip_13',
      text: '1kg pro Woche abnehmen bedeutet täglich 1000 kcal einsparen. Das ist machbar: 500 kcal weniger essen + 500 kcal mehr bewegen!',
    ),
    Tip(
      id: 'tip_14',
      text: 'Trink vor, beim und nach dem Essen 2 Gläser Wasser oder iss einen Skyr. Das füllt den Magen und du isst automatisch weniger!',
    ),
    Tip(
      id: 'tip_15',
      text: 'Neue Gewohnheiten brauchen etwa 3 Monate, bis sie zur Routine werden. Gib nicht vorher auf - es wird leichter!',
    ),
    Tip(
      id: 'tip_16',
      text: 'Alkohol hat nicht nur viele Kalorien, sondern hemmt auch den Fettabbau im Körper. Am besten meiden, wenn du abnehmen willst.',
    ),
    Tip(
      id: 'tip_17',
      text: 'Ausrutscher bei einer Gewohnheit? Kein Problem! Es zählen die anderen 350 Tage im Jahr. Einfach weitermachen und niemals aufgeben - der Alltag entscheidet!',
    ),
    Tip(
      id: 'tip_18',
      text: 'Erkenne deine Muster: Was genau lässt dich stressen und essen? Erkenne die Trigger, vermeide sie und etabliere Alternativen.',
    ),
  ];

  /// Returns a random unseen tip, or null if all have been seen or a tip was already shown today
  Future<Tip?> getNextUnseenTip() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Store first app start date if not set
    final firstStartDate = prefs.getString(_firstAppStartDateKey);
    final today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD
    
    if (firstStartDate == null) {
      await prefs.setString(_firstAppStartDateKey, today);
      return null; // Don't show tip on first day (new users are overwhelmed)
    }
    
    // Don't show tip on the same day as first app start
    if (firstStartDate == today) {
      return null;
    }
    
    // Check if a tip was already shown today
    final lastTipDate = prefs.getString(_lastTipDateKey);
    
    if (lastTipDate == today) {
      return null; // Tip already shown today
    }
    
    final seenTips = prefs.getStringList(_seenTipsKey) ?? [];
    
    // Find all unseen tips
    final unseenTips = _allTips.where((tip) => !seenTips.contains(tip.id)).toList();
    
    if (unseenTips.isEmpty) {
      return null;
    }
    
    // Return a random unseen tip
    final random = Random();
    return unseenTips[random.nextInt(unseenTips.length)];
  }

  /// Marks a tip as seen and saves today's date
  Future<void> markTipAsSeen(String tipId) async {
    final prefs = await SharedPreferences.getInstance();
    final seenTips = prefs.getStringList(_seenTipsKey) ?? [];
    
    if (!seenTips.contains(tipId)) {
      seenTips.add(tipId);
      await prefs.setStringList(_seenTipsKey, seenTips);
    }
    
    // Save today's date
    final today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD
    await prefs.setString(_lastTipDateKey, today);
  }

  /// Checks if there are unseen tips
  Future<bool> hasUnseenTips() async {
    final prefs = await SharedPreferences.getInstance();
    final seenTips = prefs.getStringList(_seenTipsKey) ?? [];
    return _allTips.any((tip) => !seenTips.contains(tip.id));
  }

  /// Resets all tips (for testing)
  Future<void> resetSeenTips() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_seenTipsKey);
  }
}

import 'dart:js' as js;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AnalyticsService {
  static const String _userIdKey = 'analytics_user_id';
  static String? _userId;

  /// Initialize Mixpanel and set up anonymous user ID
  static Future<void> initialize() async {
    // Mixpanel is already initialized in index.html
    print('Mixpanel initialized via HTML');
    
    // Get or create anonymous user ID
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString(_userIdKey);
    
    if (_userId == null) {
      _userId = const Uuid().v4();
      await prefs.setString(_userIdKey, _userId!);
      print('Created new anonymous user ID: $_userId');
    } else {
      print('Using existing user ID: $_userId');
    }
    
    // Identify user to Mixpanel
    try {
      js.context['mixpanel'].callMethod('identify', [_userId]);
      print('Mixpanel user identified: $_userId');
    } catch (e) {
      print('Failed to identify user: $e');
    }
  }

  /// Track app open event with commit ID
  static Future<void> trackAppOpen({String? commitId}) async {
    try {
      final properties = js.JsObject.jsify({
        'platform': 'web',
        if (commitId != null) 'commit_id': commitId,
      });
      
      js.context['mixpanel'].callMethod('track', ['app_open', properties]);
      print('Tracked app_open event with properties: platform=web, commit_id=$commitId');
    } catch (e) {
      print('Failed to track app_open: $e');
    }
  }

  /// Track custom event
  static Future<void> trackEvent(String eventName, {Map<String, dynamic>? properties}) async {
    try {
      final jsProperties = properties != null 
        ? js.JsObject.jsify(properties)
        : js.JsObject.jsify({});
      
      js.context['mixpanel'].callMethod('track', [eventName, jsProperties]);
      print('Tracked event: $eventName');
    } catch (e) {
      print('Failed to track event $eventName: $e');
    }
  }

  /// Track screen view
  static Future<void> trackScreenView(String screenName) async {
    await trackEvent('screen_view', properties: {'screen_name': screenName});
  }

  /// Set user property
  static Future<void> setUserProperty(String propertyName, dynamic value) async {
    try {
      js.context['mixpanel']['people'].callMethod('set', [propertyName, value]);
      print('Set user property: $propertyName = $value');
    } catch (e) {
      print('Failed to set user property $propertyName: $e');
    }
  }

  /// Track weight update (without actual weight value for privacy)
  static Future<void> trackWeightUpdate() async {
    await trackEvent('weight_updated');
    await setUserProperty('last_weight_update', DateTime.now().toIso8601String());
  }

  /// Track habit toggle (without habit details for privacy)
  static Future<void> trackHabitToggle() async {
    await trackEvent('habit_toggled');
    await setUserProperty('last_habit_update', DateTime.now().toIso8601String());
  }
}

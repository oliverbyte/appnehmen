# Automatische Updates

## Funktionsweise

Die App nutzt Service Workers für automatische Updates. Sobald eine neue Version deployed wird:

1. **Erkennung**: Der Service Worker erkennt automatisch neue Versionen
2. **Installation**: Die neue Version wird im Hintergrund heruntergeladen
3. **Aktivierung**: Nach dem Download wird die neue Version automatisch aktiviert
4. **Reload**: Die App lädt sich automatisch neu, um die neue Version anzuzeigen

## Technische Details

### Service Worker (`web/service_worker.js`)
- Cached wichtige App-Assets für Offline-Verfügbarkeit
- Nutzt Network-First Strategie mit Cache-Fallback
- Cache-Version wird automatisch mit Commit-ID aktualisiert
- Forciert sofortiges Update via `skipWaiting()` und `clients.claim()`

### Update Manager (`web/update_manager.js`)
- Registriert den Service Worker beim App-Start
- Prüft alle 60 Sekunden auf Updates
- Behandelt `updatefound` Events automatisch
- Löst automatischen Reload bei neuer Version aus

### Update Notifier (`lib/widgets/update_notifier.dart`)
- Zeigt visuelles Feedback während des Updates (optional)
- Wraps die gesamte App auf Web-Plattform
- Kommuniziert mit JavaScript Update Manager

## Deployment

Bei jedem Push auf `main`:
1. GitHub Actions buildet die neue Version
2. Cache-Version im Service Worker wird mit Commit-ID aktualisiert
3. Deployment auf GitHub Pages

## Für Nutzer

- **Installierte Apps**: Updates werden automatisch im Hintergrund geladen und aktiviert
- **Browser-Nutzung**: Updates werden beim nächsten Besuch automatisch geladen
- **Offline-Fähigkeit**: Gecachte Assets ermöglichen Offline-Nutzung

## Update-Intervall

- Automatische Update-Prüfung: Alle 60 Sekunden
- Bei App-Start: Sofortige Update-Prüfung
- Bei `controllerchange`: Automatischer Reload innerhalb von 500ms

## Kompatibilität

- ✅ Chrome/Edge (Desktop & Mobile)
- ✅ Firefox (Desktop & Mobile)
- ✅ Safari (Desktop & Mobile)
- ✅ Alle modernen Browser mit Service Worker Support

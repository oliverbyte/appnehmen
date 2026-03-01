# Manuelle Updates mit Benutzersteuerung

## Funktionsweise

Die App nutzt Service Workers für Updates mit voller Benutzerkontrolle. Sobald eine neue Version deployed wird:

1. **Erkennung**: Der Service Worker erkennt automatisch neue Versionen
2. **Installation**: Die neue Version wird im Hintergrund heruntergeladen
3. **Benachrichtigung**: Ein blaues Update-Banner erscheint am oberen Bildschirmrand
4. **Benutzeraktion**: Der Benutzer entscheidet, wann er aktualisieren möchte
5. **Aktivierung**: Beim Klick auf "Aktualisieren" wird die neue Version aktiviert

## Technische Details

### Service Worker (`web/service_worker.js`)
- Cached wichtige App-Assets für Offline-Verfügbarkeit
- Nutzt Network-First Strategie mit Cache-Fallback
- Cache-Version wird automatisch mit Commit-ID aktualisiert
- Wartet auf Benutzeraktion - **KEIN** automatisches `skipWaiting()`
- Aktiviert nur bei SKIP_WAITING Message vom Update Manager

### Update Manager (`web/update_manager.js`)
- Registriert den Service Worker beim App-Start
- Prüft alle 60 Sekunden auf Updates
- Benachrichtigt Flutter-App über verfügbare Updates
- Wartet auf Benutzeraktion (kein automatischer Reload)

### Update Banner (`lib/widgets/update_banner.dart`)
- Zeigt blaues Benachrichtigungs-Banner am oberen Bildschirmrand
- Erscheint nur wenn Update verfügbar ist
- "Aktualisieren"-Button startet manuelles Update
- Kommuniziert mit JavaScript Update Manager

## Deployment

Bei jedem Push auf `main`:
1. GitHub Actions buildet die neue Version
2. Cache-Version im Service Worker wird mit Commit-ID aktualisiert
3. Deployment auf GitHub Pages

## FUpdate-Erkennung**: Updates werden automatisch erkannt und heruntergeladen
- **Benachrichtigung**: Blaues Banner erscheint am oberen Bildschirmrand
- **Volle Kontrolle**: Benutzer entscheidet, wann das Update installiert wird
- **Offline-Fähigkeit**: Gecachte Assets ermöglichen Offline-Nutzung
- **Datensicherheit**: localStorage-Daten werden IMMER bewahrt

## Update-Intervall

- Automatische Update-Prüfung: Alle 60 Sekunden
- Bei App-Start: Sofortige Update-Prüfung
- Aktivierung: Nur auf Benutzerwunsch per Klick auf "Aktualisieren"
- Bei App-Start: Sofortige Update-Prüfung
- Bei `controllerchange`: Automatischer Reload innerhalb von 500ms

## Kompatibilität

- ✅ Chrome/Edge (Desktop & Mobile)
- ✅ Firefox (Desktop & Mobile)
- ✅ Safari (Desktop & Mobile)
- ✅ Alle modernen Browser mit Service Worker Support

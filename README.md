# Appnehmen 🏋️

Eine Progressive Web App (PWA) zur Unterstützung beim Abnehmen – mit lokaler Datenspeicherung, Gewichtsverfolgung und Heißhunger-Notfallhilfe.

## 📱 Über die App

**Appnehmen** ist eine minimalistische PWA, die dir mit einfachen aber wirksamen Werkzeugen beim Abnehmen hilft:

- 📊 **Gewichtsverfolgung**: Verfolge deinen Fortschritt mit grafischer Auswertung
- 💪 **Mein Warum**: Bleib motiviert durch dein persönliches "Warum"
- 🚨 **Heißhunger-Notfall**: Strukturierte Hilfe bei akuten Heißhunger-Momenten
- 🔒 **100% Privat**: Alle Daten bleiben lokal auf deinem Gerät

### Entstehungsgeschichte

Oliver hat selbst 45 Kilos abgenommen und teilt mit dieser App die kleinen aber wirksamen Alltagswerkzeuge, die ihm dabei geholfen haben. Dies ist ein Freizeitprojekt ohne kommerzielles Interesse.

## 🚀 Installation

### Als PWA auf dem Smartphone

1. Öffne die App im Browser: **[https://oliverbyte.github.io/appnehmen](https://oliverbyte.github.io/appnehmen)**

2. **Auf iOS (iPhone/iPad)**:
   - Tippe auf das Teilen-Symbol (□↑)
   - Wähle "Zum Home-Bildschirm"
   - Bestätige mit "Hinzufügen"

3. **Auf Android**:
   - Tippe auf die drei Punkte (⋮) im Browser
   - Wähle "App installieren" oder "Zum Startbildschirm hinzufügen"
   - Bestätige die Installation

4. Die App erscheint nun als Icon auf deinem Startbildschirm und verhält sich wie eine native App!

### Als PWA auf dem Desktop

- **Chrome/Edge**: Klicke auf das ⊕ Symbol in der Adresszeile
- **Safari**: Datei → Zum Dock hinzufügen

## 🛠️ Technologie

- **Framework**: Flutter Web
- **Storage**: Lokaler Browser-Speicher (shared_preferences)
- **Charts**: fl_chart für Gewichtsverlauf-Visualisierung
- **Deployment**: GitHub Pages

## ✨ Features

### Onboarding
- Erstmalige Erfassung von Name, aktuellem Gewicht, Wunschgewicht und persönlicher Motivation

### Startseite
- Übersicht über aktuelles Gewicht, Wunschgewicht und verbleibende Kilos
- Schnellzugriff auf alle Hauptfunktionen
- Editierbare Motivation ("Mein Warum")

### Gewichtsverfolgung
- Eingabe neuer Gewichtsmessungen (mit deutscher Komma-Unterstützung: 75,5 kg)
- Grafische Darstellung des Verlaufs
- Statistiken: Startgewicht, aktuelles Gewicht, verlorene Kilos
- Chronologische Liste aller Einträge

### Heißhunger-Notfall
- **Schritt 1**: Trinke 2 Gläser Wasser
- **Schritt 2**: Warte 10 Minuten (mit Timer)
- Strukturierte Hilfe für kritische Momente

### Burger-Menü
- Navigation zu allen Hauptfunktionen
- Info-Seite mit Hintergrundinfos zur App

## 🔐 Datenschutz

**Alle Daten werden ausschließlich lokal auf deinem Gerät gespeichert.**

- Keine Server-Kommunikation
- Keine Cloud-Synchronisation
- Keine Weitergabe an Dritte
- Vollständige Kontrolle über deine Daten

## 💻 Entwicklung

### Voraussetzungen

```bash
# Flutter installieren (stable channel)
flutter channel stable
flutter upgrade

```bash
# Repository klonen
git clone https://github.com/oliverbyte/appnehmen.git
cd appnehmen

# Dependencies installieren
flutter pub get
```

### Lokal ausführen

```bash
# Im Chrome Browser
flutter run -d chrome

# Als Web-Server (für Netzwerk-Zugriff, z.B. vom Smartphone)
flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0
```

### Bauen

```bash
# Production Build
flutter build web --release

# Output in build/web/
```

## 📧 Feedback & Kontakt

Oliver freut sich über Feedback und Anregungen:

**E-Mail**: info@oliverbyte.de

*(Freizeitprojekt, kein Support)*

## 📄 Lizenz

MIT License - siehe [LICENSE](LICENSE) Datei für Details.

Dieses Projekt ist Open Source und kann frei verwendet, modifiziert und weiterverbreitet werden.

---

**Version 1.0.0** | Made with ❤️ by Oliver | MIT License

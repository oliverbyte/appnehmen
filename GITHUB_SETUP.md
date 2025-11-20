# GitHub Veröffentlichung - Schritt für Schritt

## 1. GitHub Repository erstellen

1. Gehe zu https://github.com/new
2. Repository-Name: `appnehmen`
3. Beschreibung: `PWA zum Abnehmen - Gewichtsverfolgung und Heißhunger-Notfallhilfe`
4. Öffentlich (Public) auswählen
5. **KEINE** README, .gitignore oder License hinzufügen (haben wir schon lokal)
6. "Create repository" klicken

## 2. Lokales Repository mit GitHub verbinden

```bash
# Remote hinzufügen (ersetze USERNAME mit deinem GitHub-Username)
git remote add origin https://github.com/USERNAME/appnehmen.git

# Push zum GitHub Repository
git branch -M main
git push -u origin main
```

**Mit deinem GitHub-Username:**
```bash
git remote add origin https://github.com/oliverbyte/appnehmen.git
git branch -M main
git push -u origin main
```

## 3. GitHub Pages aktivieren

1. Gehe zu deinem Repository auf GitHub
2. Klicke auf **Settings** (Einstellungen)
3. Klicke in der linken Sidebar auf **Pages**
4. Bei **Source** wähle: **GitHub Actions**
5. Die GitHub Action wird automatisch beim nächsten Push ausgeführt

Die Action ist bereits konfiguriert in `.github/workflows/deploy.yml`

## 4. Deployment prüfen

1. Gehe zum Tab **Actions** in deinem Repository
2. Du solltest den Workflow "Deploy to GitHub Pages" sehen
3. Nach erfolgreicher Ausführung (grünes ✓) ist die App verfügbar unter:
   
   **https://USERNAME.github.io/appnehmen/**
   
   (z.B. https://oliverbyte.github.io/appnehmen/)

## 5. Bei Updates

Jeder Push zum `main` oder `master` Branch triggert automatisch ein neues Deployment:

```bash
# Änderungen machen, dann:
git add .
git commit -m "Beschreibung der Änderung"
git push
```

Die App wird automatisch nach 1-2 Minuten aktualisiert!

## Troubleshooting

### Build schlägt fehl
- Prüfe den Actions-Tab für Fehlermeldungen
- Stelle sicher, dass der Branch-Name in `.github/workflows/deploy.yml` stimmt

### Seite nicht erreichbar
- Warte 2-3 Minuten nach dem ersten Deployment
- Prüfe in Settings → Pages, ob die URL angezeigt wird
- Leere Browser-Cache (Cmd+Shift+R / Ctrl+Shift+R)

### 404 Error
- Stelle sicher, dass `--base-href "/appnehmen/"` im Workflow richtig gesetzt ist
- Repository-Name muss mit dem base-href übereinstimmen

## Wichtig

Die App funktioniert als PWA am besten, wenn sie über HTTPS bereitgestellt wird. GitHub Pages nutzt automatisch HTTPS - perfekt für PWAs!

**Nach der Veröffentlichung können Nutzer die App direkt vom Smartphone-Browser installieren!**

// Update Manager für automatische PWA Updates
class UpdateManager {
  constructor() {
    this.updateAvailable = false;
    this.registration = null;
  }

  // Service Worker registrieren und auf Updates prüfen
  async init() {
    if (!('serviceWorker' in navigator)) {
      console.log('Service Workers werden nicht unterstützt');
      return;
    }

    try {
      // Service Worker registrieren
      // Automatisch den richtigen Pfad aus <base href> ermitteln
      const baseUrl = document.querySelector('base')?.getAttribute('href') || '/';
      this.registration = await navigator.serviceWorker.register(
        baseUrl + 'service_worker.js',
        { scope: baseUrl }
      );
      
      console.log('Service Worker registriert:', this.registration);

      // Auf Updates prüfen
      this.registration.addEventListener('updatefound', () => {
        const newWorker = this.registration.installing;
        console.log('Neuer Service Worker gefunden');

        newWorker.addEventListener('statechange', () => {
          if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
            // Neue Version verfügbar!
            console.log('Neue App-Version verfügbar - Update wird durchgeführt...');
            this.updateAvailable = true;
            this.performUpdate(newWorker);
          }
        });
      });

      // Regelmäßig auf Updates prüfen (alle 60 Sekunden)
      setInterval(() => {
        this.registration.update();
      }, 60000);

      // Sofort beim Start auf Updates prüfen
      this.registration.update();

    } catch (error) {
      console.error('Service Worker Registrierung fehlgeschlagen:', error);
    }
  }

  // Update durchführen
  performUpdate(worker) {
    // Sende Nachricht an neuen Service Worker, um sofort zu aktivieren
    worker.postMessage({ type: 'SKIP_WAITING' });

    // Warte auf Controller-Wechsel
    navigator.serviceWorker.addEventListener('controllerchange', () => {
      console.log('Neue App-Version aktiv - Seite wird neu geladen...');
      
      // Kurze Verzögerung für bessere UX
      setTimeout(() => {
        window.location.reload();
      }, 500);
    });
  }

  // Manuelles Update auslösen
  async checkForUpdates() {
    if (this.registration) {
      await this.registration.update();
    }
  }
}

// Global verfügbar machen
window.updateManager = new UpdateManager();

// Update Manager for automatic PWA updates
class UpdateManager {
  constructor() {
    this.updateAvailable = false;
    this.registration = null;
  }

  // Register Service Worker and check for updates
  async init() {
    if (!('serviceWorker' in navigator)) {
      console.log('Service Workers are not supported');
      return;
    }

    try {
      // Register Service Worker
      // Automatically determine correct path from <base href>
      const baseUrl = document.querySelector('base')?.getAttribute('href') || '/';
      this.registration = await navigator.serviceWorker.register(
        baseUrl + 'service_worker.js',
        { scope: baseUrl }
      );
      
      console.log('Service Worker registered:', this.registration);

      // Check for updates
      this.registration.addEventListener('updatefound', () => {
        const newWorker = this.registration.installing;
        
        // ONLY if a controller is already active (not on first load!)
        if (navigator.serviceWorker.controller) {
          console.log('Update detected - new version available');
          
          newWorker.addEventListener('statechange', () => {
            if (newWorker.state === 'installed') {
              console.log('Update ready - activating new version...');
              this.updateAvailable = true;
              this.performUpdate(newWorker);
            }
          });
        }
      });

      // Check for updates regularly (every 60 seconds)
      setInterval(() => {
        this.registration.update();
      }, 60000);

      // Check for updates immediately on start
      this.registration.update();

    } catch (error) {
      console.error('Service Worker registration failed:', error);
    }
  }

  // Perform update
  performUpdate(worker) {
    // Send message to new Service Worker to activate immediately
    worker.postMessage({ type: 'SKIP_WAITING' });

    // Wait for controller change
    navigator.serviceWorker.addEventListener('controllerchange', () => {
      console.log('New app version active - page will be reloaded automatically...');
      
      // Immediate reload without visual notification
      window.location.reload();
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

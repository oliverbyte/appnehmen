// Update Manager for PWA updates with user notification
class UpdateManager {
  constructor() {
    this.updateAvailable = false;
    this.registration = null;
    this.waitingWorker = null;
    this.updateCallback = null;
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
              console.log('Update ready - waiting for user action');
              this.updateAvailable = true;
              this.waitingWorker = newWorker;
              
              // Notify Flutter app that update is available
              if (this.updateCallback) {
                this.updateCallback(true);
              }
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

  // Set callback function to notify Flutter when update is available
  onUpdateAvailable(callback) {
    this.updateCallback = callback;
  }

  // User-triggered update - call this when user clicks update button
  applyUpdate() {
    if (!this.waitingWorker) {
      console.log('No update available to apply');
      return;
    }

    console.log('Applying update - reloading to activate new version...');
    
    // Send message to new Service Worker to activate immediately
    this.waitingWorker.postMessage({ type: 'SKIP_WAITING' });
    
    // Immediately reload - the new service worker will take over
    window.location.reload();
  }

  // Trigger manual update check
  async checkForUpdates() {
    if (this.registration) {
      await this.registration.update();
    }
  }
}

// Make globally available and initialize
window.updateManager = new UpdateManager();
window.updateManager.init();

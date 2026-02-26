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
              console.log('Update ready - auto-applying...');
              this.updateAvailable = true;
              this.waitingWorker = newWorker;
              
              // Auto-apply update immediately
              setTimeout(() => {
                console.log('Auto-reloading app to apply update...');
                this.applyUpdate();
              }, 500);
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
    
    // Set flag to show loading overlay during update
    sessionStorage.setItem('isUpdating', 'true');
    
    // Show loading overlay
    const overlay = document.getElementById('loading-overlay');
    if (overlay) {
      overlay.classList.remove('hidden');
    }
    
    // Set flag to redirect to news page after reload
    sessionStorage.setItem('showNewsAfterUpdate', 'true');
    
    // Send message to new Service Worker to activate immediately
    this.waitingWorker.postMessage({ type: 'SKIP_WAITING' });
    
    // Reload after a short delay to ensure overlay is visible
    setTimeout(() => {
      window.location.reload();
    }, 300);
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

// Hide loading overlay once Flutter app is loaded
window.addEventListener('load', () => {
  // Don't auto-hide overlay if we're in the middle of an update
  if (sessionStorage.getItem('isUpdating') === 'true') {
    sessionStorage.removeItem('isUpdating');
    // Keep overlay visible longer during update to prevent flicker
    setTimeout(() => {
      const overlay = document.getElementById('loading-overlay');
      if (overlay) {
        overlay.classList.add('hidden');
        // Keep in DOM but hidden (don't remove) to prevent re-creation flicker
      }
    }, 1000);
  } else {
    // Normal load - hide overlay after short delay
    setTimeout(() => {
      const overlay = document.getElementById('loading-overlay');
      if (overlay) {
        overlay.classList.add('hidden');
        // Keep in DOM but hidden (don't remove) to prevent re-creation flicker
      }
    }, 500);
  }
});

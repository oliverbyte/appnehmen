// Service Worker for automatic updates
const CACHE_NAME = 'appnehmen-cache-v1';
// Assets are cached relative to Service Worker scope
const ASSETS_TO_CACHE = [
  './',
  './index.html',
  './manifest.json',
  './favicon.png',
  './icons/Icon-192.png',
  './icons/Icon-512.png',
  './icons/Icon-maskable-192.png',
  './icons/Icon-maskable-512.png'
];

// Installation: Cache important assets
self.addEventListener('install', (event) => {
  console.log('[Service Worker] Installing...');
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        console.log('[Service Worker] Caching app shell');
        return cache.addAll(ASSETS_TO_CACHE);
      })
      .then(() => {
        // Force immediate activation of new Service Worker
        return self.skipWaiting();
      })
  );
});

// Activation: Delete old caches and reload all clients
self.addEventListener('activate', (event) => {
  console.log('[Service Worker] Activating...');
  event.waitUntil(
    Promise.all([
      // Delete ALL old caches
      caches.keys().then((cacheNames) => {
        return Promise.all(
          cacheNames.map((cacheName) => {
            if (cacheName !== CACHE_NAME) {
              console.log('[Service Worker] Deleting old cache:', cacheName);
              return caches.delete(cacheName);
            }
          })
        );
      }),
      // Take control over all clients immediately
      self.clients.claim().then(() => {
        console.log('[Service Worker] Clients claimed');
        // Force reload all clients to use new version
        return self.clients.matchAll({ type: 'window' }).then((clients) => {
          clients.forEach((client) => {
            console.log('[Service Worker] Reloading client:', client.url);
            client.postMessage({ type: 'RELOAD' });
          });
        });
      })
    ])
  );
});

// Fetch: Network-First strategy with cache fallback
self.addEventListener('fetch', (event) => {
  event.respondWith(
    fetch(event.request)
      .then((response) => {
        // Clone response for cache
        const responseToCache = response.clone();
        
        caches.open(CACHE_NAME)
          .then((cache) => {
            cache.put(event.request, responseToCache);
          });
        
        return response;
      })
      .catch(() => {
        // Fallback to cache when offline
        return caches.match(event.request);
      })
  );
});

// Message handler for manual updates
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});

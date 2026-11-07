/* Teste do iPhone (Route Referrals): mostra o push que chega e abre a página ao tocar. */
self.addEventListener('install', function () { self.skipWaiting(); });
self.addEventListener('activate', function (e) { e.waitUntil(self.clients.claim()); });
self.addEventListener('push', function (e) {
  var d = {}; try { d = e.data ? e.data.json() : {}; } catch (x) { d = { body: e.data ? e.data.text() : '' }; }
  e.waitUntil(Promise.all([
    self.registration.showNotification(d.title || 'New neighbor', { body: d.body || 'This is how a real alert will look.', tag: 'rr-test', data: { url: './?from=push' } }),
    self.navigator && self.navigator.setAppBadge ? self.navigator.setAppBadge(1).catch(function () {}) : Promise.resolve()
  ]));
});
self.addEventListener('notificationclick', function (e) {
  e.notification.close();
  e.waitUntil(self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then(function (cs) {
    for (var i = 0; i < cs.length; i++) { if ('focus' in cs[i]) return cs[i].focus(); }
    return self.clients.openWindow('./?from=push');
  }));
});

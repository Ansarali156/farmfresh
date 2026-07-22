const http = require('http');
const fs = require('fs');
const path = require('path');

const BACKEND_PORT = 3001;
const PROXY_PORT = 8080;
const WEB_DIR = path.join(__dirname, 'frontend', 'build', 'web');

const MIME_TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.wasm': 'application/wasm',
  '.ttf': 'font/ttf',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
};

const server = http.createServer((req, res) => {
  console.log(`[Proxy] Received ${req.method} request to ${req.url}`);
  // Add CORS headers for web requests
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PATCH, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', '*');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  // Disable PWA Service Worker cache to guarantee fresh live reloads
  if (req.url.includes('flutter_service_worker.js')) {
    res.writeHead(404, { 'Content-Type': 'text/plain', 'Cache-Control': 'no-store' });
    res.end('Disabled for dev');
    return;
  }

  // 1. Proxy API and Socket.io requests to NestJS Backend on 3000
  if (req.url.startsWith('/api') || req.url.startsWith('/socket.io')) {
    const options = {
      hostname: '127.0.0.1',
      port: BACKEND_PORT,
      path: req.url,
      method: req.method,
      headers: {
        ...req.headers,
        host: `127.0.0.1:${BACKEND_PORT}`,
      },
    };

    const proxyReq = http.request(options, (proxyRes) => {
      res.writeHead(proxyRes.statusCode, proxyRes.headers);
      proxyRes.pipe(res, { end: true });
    });

    proxyReq.on('error', (err) => {
      console.error(`[Proxy API Error] ${req.method} ${req.url}:`, err.message);
      if (!res.headersSent) {
        res.writeHead(502, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ success: false, message: 'Backend connection error' }));
      }
    });

    req.pipe(proxyReq, { end: true });
    return;
  }

  // 2. Serve Flutter Web static release files from frontend/build/web
  let reqPath = req.url.split('?')[0];
  let filePath = path.join(WEB_DIR, reqPath === '/' ? 'index.html' : reqPath);

  fs.stat(filePath, (err, stats) => {
    if (err || !stats.isFile()) {
      // SPA Fallback: serve index.html for client-side GoRouter navigation
      filePath = path.join(WEB_DIR, 'index.html');
    }

    const ext = path.extname(filePath).toLowerCase();
    const contentType = MIME_TYPES[ext] || 'application/octet-stream';

    fs.readFile(filePath, (readErr, content) => {
      if (readErr) {
        res.writeHead(500, { 'Content-Type': 'text/plain' });
        res.end('Server Error');
        return;
      }
      res.writeHead(200, {
        'Content-Type': contentType,
        'Cache-Control': 'no-cache, no-store, must-revalidate',
      });
      res.end(content);
    });
  });
});

// Handle WebSocket upgrades for Socket.io
server.on('upgrade', (req, socket, head) => {
  socket.on('error', () => {});

  if (req.url.startsWith('/api') || req.url.startsWith('/socket.io')) {
    const options = {
      hostname: '127.0.0.1',
      port: BACKEND_PORT,
      path: req.url,
      method: req.method,
      headers: req.headers,
    };

    const proxyReq = http.request(options);
    proxyReq.on('upgrade', (proxyRes, proxySocket, proxyHead) => {
      proxySocket.on('error', () => {});
      try {
        socket.write(
          `HTTP/1.1 101 Switching Protocols\r\n` +
          Object.keys(proxyRes.headers)
            .map((key) => `${key}: ${proxyRes.headers[key]}`)
            .join('\r\n') +
          '\r\n\r\n'
        );
        proxySocket.pipe(socket);
        socket.pipe(proxySocket);
      } catch (_) {}
    });

    proxyReq.on('error', () => {
      socket.destroy();
    });

    proxyReq.end();
  } else {
    socket.destroy();
  }
});

process.on('uncaughtException', (err) => {
  console.warn('[Proxy Warning]:', err.message);
});

server.listen(PROXY_PORT, () => {
  console.log(`🚀 Production Gateway Server active on http://localhost:${PROXY_PORT}`);
  console.log(`   └─ /api & /socket.io -> NestJS Backend (http://localhost:${BACKEND_PORT})`);
  console.log(`   └─ /*                 -> Flutter Web Release (${WEB_DIR})`);
});

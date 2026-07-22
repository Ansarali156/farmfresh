const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');

const PORT = 8081;
const BACKEND = 'http://127.0.0.1:3000';
const STATIC_DIR = path.join(__dirname, 'frontend', 'build', 'web');

const MIME_TYPES = {
  '.html': 'text/html',
  '.js': 'text/javascript',
  '.css': 'text/css',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.wasm': 'application/wasm',
  '.map': 'application/json',
};

const server = http.createServer((req, res) => {
  const parsed = url.parse(req.url);
  const pathname = parsed.pathname;

  // Proxy /api/* requests to the NestJS backend
  if (pathname.startsWith('/api/')) {
    const backendUrl = BACKEND + req.url;
    const options = url.parse(backendUrl);
    options.method = req.method;
    options.headers = { ...req.headers };
    delete options.headers['host'];

    const proxyReq = http.request(options, (proxyRes) => {
      res.writeHead(proxyRes.statusCode, proxyRes.headers);
      proxyRes.pipe(res);
    });

    proxyReq.on('error', (err) => {
      console.error('Proxy error:', err.message);
      res.writeHead(502, { 'Content-Type': 'text/plain' });
      res.end('Backend unavailable');
    });

    req.pipe(proxyReq);
    return;
  }

  // Serve static Flutter web files
  let filePath = path.join(STATIC_DIR, pathname === '/' ? 'index.html' : pathname);

  // If file doesn't exist, serve index.html (SPA fallback)
  if (!fs.existsSync(filePath) || fs.statSync(filePath).isDirectory()) {
    filePath = path.join(STATIC_DIR, 'index.html');
  }

  const ext = path.extname(filePath);
  const contentType = MIME_TYPES[ext] || 'application/octet-stream';

  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.writeHead(404);
      res.end('Not found');
      return;
    }
    res.writeHead(200, { 'Content-Type': contentType });
    res.end(data);
  });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Proxy server running on http://0.0.0.0:${PORT}`);
  console.log(`Serving Flutter from: ${STATIC_DIR}`);
  console.log(`Proxying /api/* to: ${BACKEND}`);
});

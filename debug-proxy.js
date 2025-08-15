const http = require('http');
const url = require('url');

const TARGET_HOST = 'avi.alliance.unm.edu';
const TARGET_PORT = 8443;
const PROXY_PORT = 8080;

const server = http.createServer((req, res) => {
  console.log('\n=== INCOMING REQUEST ===');
  console.log(`${req.method} ${req.url}`);
  console.log('Headers:', JSON.stringify(req.headers, null, 2));
  
  let body = '';
  req.on('data', chunk => {
    body += chunk.toString();
  });
  
  req.on('end', () => {
    if (body) {
      console.log('Body:', body);
    }
    
    // Forward the request
    const options = {
      hostname: TARGET_HOST,
      port: TARGET_PORT,
      path: req.url,
      method: req.method,
      headers: req.headers
    };
    
    // Remove host header to avoid issues
    delete options.headers.host;
    
    console.log('\n=== FORWARDING TO ===');
    console.log(`http://${TARGET_HOST}:${TARGET_PORT}${req.url}`);
    
    const proxyReq = http.request(options, (proxyRes) => {
      console.log('\n=== RESPONSE ===');
      console.log(`Status: ${proxyRes.statusCode}`);
      console.log('Headers:', JSON.stringify(proxyRes.headers, null, 2));
      
      res.writeHead(proxyRes.statusCode, proxyRes.headers);
      
      let responseBody = '';
      proxyRes.on('data', chunk => {
        responseBody += chunk.toString();
        res.write(chunk);
      });
      
      proxyRes.on('end', () => {
        if (responseBody) {
          console.log('Response Body:', responseBody.substring(0, 500));
        }
        res.end();
      });
    });
    
    proxyReq.on('error', (e) => {
      console.error('Proxy request error:', e);
      res.writeHead(500);
      res.end('Proxy Error');
    });
    
    if (body) {
      proxyReq.write(body);
    }
    proxyReq.end();
  });
});

server.listen(PROXY_PORT, () => {
  console.log(`Debug proxy listening on port ${PROXY_PORT}`);
  console.log(`Forwarding to http://${TARGET_HOST}:${TARGET_PORT}`);
});
// Minimal sample app used to demonstrate deploying to Clymist via the action.
// Serves a tiny HTTP response; Clymist's builder (Nixpacks) detects Node and
// runs `npm start`.
const http = require('http');

const port = process.env.PORT || 3000;

http
  .createServer((_req, res) => {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('Hello from the Clymist deploy-action example app!\n');
  })
  .listen(port, () => {
    console.log(`example app listening on ${port}`);
  });

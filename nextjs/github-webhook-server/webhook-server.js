const express = require('express');
const crypto = require('crypto');
const { spawn } = require('child_process');
require('dotenv').config();

const app = express();
const PORT = 5000;

const branch = process.env.BRANCH || 'main';

const secret = process.env.GITHUB_SECRET || 'default';
const path = process.env.WEBHOOK_PATH || '/webhook'

app.use(express.json({
  verify: (req, res, buf, encoding) => {
    if (buf && buf.length) {
      req.rawBody = buf.toString(encoding || 'utf8');
    }
  }
}));

function verifySignature(req) {
  const signature = req.headers['x-hub-signature'];
  if (!signature) {
    return false;
  }

  const receivedSignature = signature.split('=')[1];

  const hmac = crypto.createHmac('sha1', secret);
  const digest = hmac.update(req.rawBody).digest('hex');

  return crypto.timingSafeEqual(Buffer.from(receivedSignature), Buffer.from(digest));
}

app.post(path, (req, res) => {
  if (!verifySignature(req)) {
    return res.status(403).send('Forbidden: Invalid signature');
  }

  const payload = req.body;

  if (payload.ref === `refs/heads/${branch}`) {
    const updateProcess = spawn('/scripts/refresh_nextjs.sh', {
      detached: true,
      stdio: 'ignore'
    });

    updateProcess.unref();

    res.status(200).send('Repo update process started in background');
  } else {
    res.status(200).send('Not the correct branch, no action taken');
  }
});

app.listen(PORT, () => {
  console.log(`Webhook listener running on port ${PORT}`);
});
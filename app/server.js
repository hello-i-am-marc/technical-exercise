const express = require('express');
const fs = require('fs');
const { MongoClient } = require('mongodb');

const app = express();
const port = process.env.PORT || 3000;
const mongoUri = process.env.MONGO_URI || '';

let db;
let mongoVersion = 'unknown';
let mongoConnected = false;

async function connectDB() {
  if (!mongoUri) {
    console.error('MONGO_URI not set');
    return;
  }
  try {
    const client = new MongoClient(mongoUri);
    await client.connect();
    db = client.db('exercise');
    const buildInfo = await db.command({ buildInfo: 1 });
    mongoVersion = buildInfo.version;
    mongoConnected = true;
    console.log(`Connected to MongoDB ${mongoVersion}`);
  } catch (err) {
    console.error('Failed to connect:', err.message);
    mongoConnected = false;
  }
}

function sanitizeMongoUri(uri) {
  return uri.replace(/(mongodb:\/\/)([^:]+):([^@]+)@/, '$1****:****@');
}

function readWizExercise() {
  try {
    return fs.readFileSync('/app/wizexercise.txt', 'utf8').trim();
  } catch (err) {
    return `(error reading file: ${err.message})`;
  }
}

function escapeHtml(str) {
  return String(str).replace(/[&<>"']/g, c => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
  }[c]));
}

function renderPage(items) {
  const wizContent = readWizExercise();
  const sanitizedUri = sanitizeMongoUri(mongoUri);

  const itemRows = items.map(item => `
    <tr>
      <td><code>${escapeHtml(String(item._id))}</code></td>
      <td>${escapeHtml(item.message || '(no message)')}</td>
      <td>${item.timestamp ? new Date(item.timestamp).toISOString() : ''}</td>
    </tr>
  `).join('');

  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Wiz Technical Exercise</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; max-width: 960px; margin: 2rem auto; padding: 0 1rem; color: #1a1a1a; line-height: 1.5; }
    h1 { margin-bottom: 0.25rem; }
    h2 { margin-top: 0; font-size: 1.1rem; color: #333; }
    .subtitle { color: #666; margin-top: 0; }
    .section { background: #f7f7f8; padding: 1rem 1.5rem; border-radius: 8px; margin-bottom: 1rem; border: 1px solid #e5e5e7; }
    .check { color: #16a34a; font-weight: bold; margin-right: 0.25rem; }
    .terminal { background: #0d1117; color: #c9d1d9; padding: 0.75rem 1rem; border-radius: 6px; font-family: ui-monospace, SFMono-Regular, monospace; font-size: 0.9rem; overflow-x: auto; margin: 0.5rem 0 1rem 0; white-space: pre; }
    .prompt { color: #58a6ff; }
    .label { font-weight: 600; color: #444; display: inline-block; min-width: 11rem; }
    table { border-collapse: collapse; width: 100%; margin-top: 0.5rem; background: #fff; }
    th, td { padding: 0.5rem 0.75rem; text-align: left; border-bottom: 1px solid #e5e5e7; vertical-align: top; }
    th { background: #fafafa; font-weight: 600; font-size: 0.9rem; }
    code { background: #ececef; padding: 0.1rem 0.35rem; border-radius: 3px; font-size: 0.9em; }
    .actions { margin-top: 1rem; }
    .actions a { display: inline-block; padding: 0.4rem 0.75rem; background: #2563eb; color: white; text-decoration: none; border-radius: 4px; font-size: 0.9rem; margin-right: 0.5rem; }
    .actions a:hover { background: #1d4ed8; }
    .actions a.secondary { background: #6b7280; }
    .actions a.secondary:hover { background: #4b5563; }
    .empty { color: #888; font-style: italic; }
    .links { margin-top: 1.5rem; font-size: 0.85rem; color: #666; padding-top: 1rem; border-top: 1px solid #e5e5e7; }
    .links a { color: #2563eb; margin-right: 0.75rem; }
  </style>
</head>
<body>
  <h1>Wiz Technical Exercise</h1>
  <p class="subtitle">Two-tier web app: containerized Node.js on EKS reading from MongoDB on EC2.</p>

  <div class="section">
    <h2>Exercise requirement evidence</h2>

    <p><span class="check">✓</span><strong>wizexercise.txt baked into the container image</strong></p>
    <div class="terminal"><span class="prompt">$</span> cat /app/wizexercise.txt
${escapeHtml(wizContent)}</div>

    <p><span class="check">✓</span><strong>MongoDB access configured via Kubernetes environment variable</strong></p>
    <p>
      <span class="label">Env var name:</span> <code>MONGO_URI</code><br>
      <span class="label">Configured in:</span> Deployment spec, <code>env.valueFrom.secretKeyRef</code><br>
      <span class="label">K8s Secret source:</span> <code>mongo-credentials</code> in namespace <code>app</code><br>
      <span class="label">Value (redacted):</span> <code>${escapeHtml(sanitizedUri || '(not set)')}</code><br>
      <span class="label">Live connection:</span> ${mongoConnected ? `<span class="check">connected</span> to MongoDB ${escapeHtml(mongoVersion)}` : '<span style="color:#dc2626">not connected</span>'}
    </p>

    <p><span class="check">✓</span><strong>App publicly reachable via Ingress + ALB</strong></p>
    <p>This page is being served through the AWS Application Load Balancer provisioned by the AWS Load Balancer Controller from the Ingress manifest.</p>

    <p><span class="check">✓</span><strong>Two-tier architecture, app reads and writes MongoDB</strong></p>
    <p>The data below is queried live from MongoDB on each page load.</p>
  </div>

  <div class="section">
    <h2>MongoDB data (live query)</h2>
    <p>Item count: <strong>${items.length}</strong></p>
    ${items.length > 0 ? `
    <table>
      <thead><tr><th>ID</th><th>Message</th><th>Timestamp</th></tr></thead>
      <tbody>${itemRows}</tbody>
    </table>
    ` : '<p class="empty">No items yet. Click the button below to seed.</p>'}
    <div class="actions">
      <a href="/seed">Add seed item</a>
      <a href="/items.json" class="secondary">View as JSON</a>
    </div>
  </div>

  <div class="links">
    <a href="/health">/health</a>
    <a href="/items.json">/items.json</a>
    <a href="/seed">/seed</a>
  </div>
</body>
</html>`;
}

app.get('/', async (req, res) => {
  try {
    const items = mongoConnected && db
      ? await db.collection('items').find({}).sort({ timestamp: -1 }).limit(50).toArray()
      : [];
    res.set('Content-Type', 'text/html').send(renderPage(items));
  } catch (err) {
    res.status(500).send(`Error: ${escapeHtml(err.message)}`);
  }
});

app.get('/items.json', async (req, res) => {
  try {
    const items = mongoConnected && db
      ? await db.collection('items').find({}).sort({ timestamp: -1 }).toArray()
      : [];
    res.set('Content-Type', 'application/json').send(JSON.stringify({
      mongoConnected,
      mongoVersion,
      itemCount: items.length,
      items
    }, null, 2));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/health', (req, res) => res.json({ status: 'ok', mongoConnected }));

app.get('/seed', async (req, res) => {
  try {
    if (!db) return res.status(503).send('MongoDB not connected');
    await db.collection('items').insertOne({
      timestamp: new Date(),
      message: `Seed entry created at ${new Date().toISOString()}`
    });
    res.redirect('/');
  } catch (err) {
    res.status(500).send(`Error: ${escapeHtml(err.message)}`);
  }
});

connectDB().then(() => {
  app.listen(port, () => console.log(`Listening on ${port}`));
}).catch(err => {
  console.error('Startup error:', err);
  app.listen(port, () => console.log(`Listening on ${port} (Mongo down)`));
});
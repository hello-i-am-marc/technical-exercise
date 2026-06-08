const express = require('express');
const fs = require('fs');
const crypto = require('crypto');
const { MongoClient } = require('mongodb');

const app = express();
const port = process.env.PORT || 3000;
const mongoUri = process.env.MONGO_URI || '';
const backupBucket = process.env.BACKUP_BUCKET || 'tech-exercise-mongo-backups-181137999457-e4819509';

let db;
let mongoVersion = 'unknown';
let mongoOsName = 'unknown';
let mongoOsVersion = 'unknown';
let mongoConnected = false;

function parseMongoVmIp(uri) {
  // mongodb://user:pass@HOST:port/...
  const m = uri.match(/@([^:]+):/);
  return m ? m[1] : 'unknown';
}
const mongoVmIp = parseMongoVmIp(mongoUri);

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
    try {
      const hostInfo = await db.command({ hostInfo: 1 });
      mongoOsName = hostInfo.os?.name || hostInfo.os?.type || 'unknown';
      mongoOsVersion = hostInfo.os?.version || 'unknown';
    } catch (osErr) {
      console.warn('hostInfo unavailable:', osErr.message);
    }
    mongoConnected = true;
    console.log(`Connected to MongoDB ${mongoVersion} on ${mongoOsName} ${mongoOsVersion}`);
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

// Session middleware: parse cookie header manually, generate sid on first visit
function getSessionId(req) {
  const cookies = req.headers.cookie || '';
  const m = cookies.match(/sid=([a-f0-9]{8})/);
  return m ? m[1] : null;
}

app.use((req, res, next) => {
  let sid = getSessionId(req);
  if (!sid) {
    sid = crypto.randomBytes(4).toString('hex');
    res.cookie('sid', sid, { maxAge: 24 * 60 * 60 * 1000, sameSite: 'lax' });
  }
  req.sid = sid;
  next();
});

function renderPage(items, currentSid) {
  const wizContent = readWizExercise();
  const sanitizedUri = sanitizeMongoUri(mongoUri);
  const bucketUrl = `https://${backupBucket}.s3.amazonaws.com/`;

  const itemRows = items.map(item => {
    const itemSid = item.sessionId || '(unknown)';
    const isYours = itemSid === currentSid;
    return `
    <tr${isYours ? ' class="yours"' : ''}>
      <td><code>${escapeHtml(itemSid)}</code>${isYours ? ' <span class="you">(you)</span>' : ''}</td>
      <td>${escapeHtml(item.message || '(no message)')}</td>
      <td>${item.timestamp ? new Date(item.timestamp).toISOString() : ''}</td>
    </tr>`;
  }).join('');

  const yourCount = items.filter(i => i.sessionId === currentSid).length;
  const totalSessions = new Set(items.map(i => i.sessionId).filter(Boolean)).size;

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
    .session-bar { background: #eff6ff; border: 1px solid #bfdbfe; padding: 0.5rem 1rem; border-radius: 6px; margin-bottom: 1rem; font-size: 0.9rem; }
    .section { background: #f7f7f8; padding: 1rem 1.5rem; border-radius: 8px; margin-bottom: 1rem; border: 1px solid #e5e5e7; }
    .section.misconfig { background: #fef2f2; border-color: #fecaca; }
    .check { color: #16a34a; font-weight: bold; margin-right: 0.25rem; }
    .warn { color: #dc2626; font-weight: bold; margin-right: 0.25rem; }
    .terminal { background: #0d1117; color: #c9d1d9; padding: 0.75rem 1rem; border-radius: 6px; font-family: ui-monospace, SFMono-Regular, monospace; font-size: 0.9rem; overflow-x: auto; margin: 0.5rem 0 1rem 0; white-space: pre; }
    .prompt { color: #58a6ff; }
    .label { font-weight: 600; color: #444; display: inline-block; min-width: 11rem; }
    table { border-collapse: collapse; width: 100%; margin-top: 0.5rem; background: #fff; }
    th, td { padding: 0.5rem 0.75rem; text-align: left; border-bottom: 1px solid #e5e5e7; vertical-align: top; }
    th { background: #fafafa; font-weight: 600; font-size: 0.9rem; }
    tr.yours { background: #fef9c3; }
    .you { color: #b45309; font-weight: 600; font-size: 0.85em; }
    code { background: #ececef; padding: 0.1rem 0.35rem; border-radius: 3px; font-size: 0.9em; }
    .actions { margin-top: 1rem; }
    .actions a { display: inline-block; padding: 0.4rem 0.75rem; background: #2563eb; color: white; text-decoration: none; border-radius: 4px; font-size: 0.9rem; margin-right: 0.5rem; }
    .actions a:hover { background: #1d4ed8; }
    .actions a.secondary { background: #6b7280; }
    .empty { color: #888; font-style: italic; }
    .links { margin-top: 1.5rem; font-size: 0.85rem; color: #666; padding-top: 1rem; border-top: 1px solid #e5e5e7; }
    .links a { color: #2563eb; margin-right: 0.75rem; }
    ul { margin: 0.5rem 0; padding-left: 1.5rem; }
    li { margin: 0.25rem 0; }
  </style>
</head>
<body>
  <h1>Wiz Technical Exercise</h1>
  <p class="subtitle">Two-tier web app: containerized Node.js on EKS reading from MongoDB on EC2.</p>

  <div class="session-bar">
    <strong>Your session:</strong> <code>${escapeHtml(currentSid)}</code>
    &nbsp;&middot;&nbsp; <strong>${yourCount}</strong> of your seed entries visible below
    &nbsp;&middot;&nbsp; <strong>${totalSessions}</strong> total sessions have seeded so far
  </div>

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
      <span class="label">Value (redacted):</span> <code>${escapeHtml(sanitizedUri || '(not set)')}</code>
    </p>

    <p><span class="check">✓</span><strong>Database server live connection</strong></p>
    <p>
      <span class="label">MongoDB version:</span> ${mongoConnected ? `<span class="check">connected</span> — ${escapeHtml(mongoVersion)}` : '<span class="warn">not connected</span>'}<br>
      <span class="label">Host OS:</span> ${escapeHtml(mongoOsName)} ${escapeHtml(mongoOsVersion)}<br>
      <span class="label">Mongo VM private IP:</span> <code>${escapeHtml(mongoVmIp)}</code>
    </p>

    <p><span class="check">✓</span><strong>App publicly reachable via Ingress + ALB</strong></p>
    <p>This page is being served through the AWS Application Load Balancer provisioned by the AWS Load Balancer Controller from the Ingress manifest.</p>
  </div>

  <div class="section misconfig">
    <h2>Intentional misconfigurations (visible to Wiz)</h2>
    <p>These weaknesses are required by the exercise. Wiz CSPM and CIEM will surface them as findings during cloud security assessment.</p>

    <p><span class="warn">!</span><strong>Mongo VM: SSH exposed to the public internet</strong></p>
    <ul>
      <li>Security group rule: ingress TCP/22 from <code>0.0.0.0/0</code></li>
      <li>Translates to: any host on the internet can attempt to authenticate to SSH on this VM</li>
    </ul>

    <p><span class="warn">!</span><strong>Mongo VM IAM role: overly permissive permissions</strong></p>
    <ul>
      <li>Inline policy grants <code>ec2:*</code> (including <code>ec2:RunInstances</code>) and broad S3 actions</li>
      <li>Translates to: if the VM is compromised, the attacker can pivot to create infrastructure, exfiltrate from S3, etc.</li>
      <li>Mitigation in place: permission boundary attached, denies <code>ec2:RunInstances</code> (defense in depth, but the declared permissions remain a CIEM finding)</li>
    </ul>

    <p><span class="warn">!</span><strong>S3 backup bucket: publicly readable and listable</strong></p>
    <ul>
      <li>Bucket Public Access Block disabled</li>
      <li>Bucket policy grants <code>s3:GetObject</code> and <code>s3:ListBucket</code> to <code>Principal: *</code></li>
      <li>Backups (mongodump tarballs) are accessible to anyone on the internet</li>
      <li>Verify directly: <a href="${escapeHtml(bucketUrl)}" target="_blank">${escapeHtml(bucketUrl)}</a></li>
    </ul>
  </div>

  <div class="section">
    <h2>MongoDB data (live query)</h2>
    <p>Item count: <strong>${items.length}</strong>${currentSid ? ` (${yourCount} from your session)` : ''}</p>
    ${items.length > 0 ? `
    <table>
      <thead><tr><th>Session</th><th>Message</th><th>Timestamp</th></tr></thead>
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
    res.set('Content-Type', 'text/html').send(renderPage(items, req.sid));
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
      mongoOsName,
      mongoOsVersion,
      mongoVmIp,
      backupBucketUrl: `https://${backupBucket}.s3.amazonaws.com/`,
      yourSessionId: req.sid,
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
      sessionId: req.sid,
      message: `Seed entry from session ${req.sid}`
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
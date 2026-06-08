const express = require('express');
const { MongoClient } = require('mongodb');

const app = express();
const port = process.env.PORT || 3000;
const mongoUri = process.env.MONGO_URI;

let db;

async function connectDB() {
  const client = new MongoClient(mongoUri);
  await client.connect();
  db = client.db('exercise');
  console.log('Connected to MongoDB');
}

app.get('/', async (req, res) => {
  try {
    const items = await db.collection('items').find({}).toArray();
    res.json({
      message: 'Wiz technical exercise app',
      mongoConnected: true,
      itemCount: items.length,
      items: items
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/health', (req, res) => res.json({ status: 'ok' }));

app.get('/seed', async (req, res) => {
  try {
    await db.collection('items').insertOne({
      timestamp: new Date(),
      message: 'Seed entry'
    });
    res.json({ status: 'inserted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

connectDB().then(() => {
  app.listen(port, () => console.log(`Listening on ${port}`));
}).catch(err => {
  console.error('Failed to connect to MongoDB:', err);
  process.exit(1);
});
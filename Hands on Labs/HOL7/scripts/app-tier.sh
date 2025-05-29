#### APPLICATION TIER (BACKEND) SCRIPT ####
#!/bin/bash

# app-tier-init.sh - Run on application tier VSI

# Update system and install dependencies
apt-get update
apt-get install -y nodejs npm

# Create directory for application
mkdir -p /opt/app

# Create package.json
cat > /opt/app/package.json << 'EOF'
{
  "name": "three-tier-test-app",
  "version": "1.0.0",
  "description": "Simple three-tier application for IBM Cloud VPC testing",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.17.1",
    "pg": "^8.7.1",
    "cors": "^2.8.5"
  }
}
EOF

# Create application server
cat > /opt/app/server.js << 'EOF'
const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');

const app = express();
const PORT = 3000;

// Enable CORS for all routes
app.use(cors());
app.use(express.json());

// Create PostgreSQL connection pool
const pool = new Pool({
  host: 'DB_TIER_IP',
  port: 5432,
  database: 'testdb',
  user: 'testuser',
  password: 'testpassword'
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'Application server is running' });
});

// Database health check endpoint
app.get('/db-health', async (req, res) => {
  try {
    const client = await pool.connect();
    await client.query('SELECT NOW()');
    client.release();
    res.json({ status: 'connected', message: 'Database connection successful' });
  } catch (err) {
    console.error('Database connection error:', err);
    res.status(500).json({ status: 'disconnected', message: 'Database connection failed', error: err.message });
  }
});

// Create a record
app.post('/records', async (req, res) => {
  try {
    const { name, value, timestamp } = req.body;
    const result = await pool.query(
      'INSERT INTO test_records (name, value, created_at) VALUES ($1, $2, $3) RETURNING *',
      [name, value, timestamp]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error creating record:', err);
    res.status(500).json({ error: 'Failed to create record', details: err.message });
  }
});

// Get all records
app.get('/records', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM test_records ORDER BY created_at DESC');
    res.json(result.rows);
  } catch (err) {
    console.error('Error retrieving records:', err);
    res.status(500).json({ error: 'Failed to retrieve records', details: err.message });
  }
});

// Start the server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Application server running on port ${PORT}`);
});
EOF

# Create a script to update the database URL
cat > /usr/local/bin/update-db-url << 'EOF'
#!/bin/bash
DB_IP=$1
if [ -z "$DB_IP" ]; then
    echo "Usage: $0 <db-ip>"
    exit 1
fi
sed -i "s/DB_TIER_IP/$DB_IP/g" /opt/app/server.js
echo "Database URL updated to: $DB_IP"
EOF

chmod +x /usr/local/bin/update-db-url

# Install application dependencies
cd /opt/app
npm install

# Create systemd service for the application
cat > /etc/systemd/system/app-server.service << 'EOF'
[Unit]
Description=Three-Tier Test Application Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/app
ExecStart=/usr/bin/node /opt/app/server.js
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
systemctl enable app-server
systemctl start app-server

echo "Application tier setup complete"
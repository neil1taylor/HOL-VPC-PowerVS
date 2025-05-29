#### WEB TIER (FRONTEND) SCRIPT ####
#!/bin/bash

# web-tier-init.sh - Run on frontend VSI

# Update system and install dependencies
apt-get update
apt-get install -y nginx

# Create simple frontend application
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Three-Tier Test Application</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }
        .status {
            padding: 10px;
            border-radius: 5px;
            margin: 10px 0;
        }
        .success {
            background-color: #d4edda;
            color: #155724;
        }
        .error {
            background-color: #f8d7da;
            color: #721c24;
        }
        button {
            padding: 8px 16px;
            background-color: #0062ff;
            color: white;
            border: none;
            cursor: pointer;
            margin: 10px 0;
        }
    </style>
</head>
<body>
    <h1>IBM Cloud VPC Three-Tier Test Application</h1>
    
    <div id="status-container">
        <h2>System Status</h2>
        <div id="frontend-status" class="status">Checking frontend...</div>
        <div id="backend-status" class="status">Checking backend connection...</div>
        <div id="database-status" class="status">Checking database connection...</div>
    </div>
    
    <div>
        <h2>Test Functionality</h2>
        <button id="test-connection">Test All Connections</button>
        <button id="create-record">Create Test Record</button>
        <button id="retrieve-records">Retrieve Records</button>
    </div>
    
    <div>
        <h2>Results</h2>
        <pre id="results">No results yet</pre>
    </div>

    <script>
        // Backend URL - update this with your application tier's IP or DNS
        const backendUrl = 'http://APP_TIER_IP:3000';
        
        // Check frontend status
        document.getElementById('frontend-status').innerHTML = 'Frontend: Active ✅';
        document.getElementById('frontend-status').className = 'status success';
        
        // Function to test connections
        async function testConnections() {
            // Test backend connection
            try {
                const backendResponse = await fetch(`${backendUrl}/health`);
                if (backendResponse.ok) {
                    document.getElementById('backend-status').innerHTML = 'Backend: Connected ✅';
                    document.getElementById('backend-status').className = 'status success';
                    
                    // If backend is accessible, check database connection
                    const dbResponse = await fetch(`${backendUrl}/db-health`);
                    const dbData = await dbResponse.json();
                    
                    if (dbData.status === 'connected') {
                        document.getElementById('database-status').innerHTML = 'Database: Connected ✅';
                        document.getElementById('database-status').className = 'status success';
                    } else {
                        throw new Error('Database connection failed');
                    }
                } else {
                    throw new Error('Backend health check failed');
                }
            } catch (error) {
                if (error.message === 'Database connection failed') {
                    document.getElementById('database-status').innerHTML = 'Database: Disconnected ❌';
                    document.getElementById('database-status').className = 'status error';
                } else {
                    document.getElementById('backend-status').innerHTML = 'Backend: Disconnected ❌';
                    document.getElementById('backend-status').className = 'status error';
                    document.getElementById('database-status').innerHTML = 'Database: Not checked';
                    document.getElementById('database-status').className = 'status';
                }
                document.getElementById('results').innerText = `Error: ${error.message}`;
            }
        }
        
        // Function to create a test record
        async function createRecord() {
            try {
                const response = await fetch(`${backendUrl}/records`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        name: 'Test Record',
                        value: Math.floor(Math.random() * 1000),
                        timestamp: new Date().toISOString()
                    })
                });
                
                const data = await response.json();
                document.getElementById('results').innerText = JSON.stringify(data, null, 2);
            } catch (error) {
                document.getElementById('results').innerText = `Error creating record: ${error.message}`;
            }
        }
        
        // Function to retrieve records
        async function retrieveRecords() {
            try {
                const response = await fetch(`${backendUrl}/records`);
                const data = await response.json();
                document.getElementById('results').innerText = JSON.stringify(data, null, 2);
            } catch (error) {
                document.getElementById('results').innerText = `Error retrieving records: ${error.message}`;
            }
        }
        
        // Add event listeners to buttons
        document.getElementById('test-connection').addEventListener('click', testConnections);
        document.getElementById('create-record').addEventListener('click', createRecord);
        document.getElementById('retrieve-records').addEventListener('click', retrieveRecords);
        
        // Initial connection test
        testConnections();
    </script>
</body>
</html>
EOF

# Configure Nginx
cat > /etc/nginx/sites-available/default << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    root /var/www/html;
    index index.html;
    server_name _;
    location / {
        try_files $uri $uri/ =404;
    }
}
EOF

# Apply configuration and restart Nginx
systemctl restart nginx

# Create a script to update the backend URL
cat > /usr/local/bin/update-backend-url << 'EOF'
#!/bin/bash
BACKEND_IP=$1
if [ -z "$BACKEND_IP" ]; then
    echo "Usage: $0 <backend-ip>"
    exit 1
fi
sed -i "s/APP_TIER_IP/$BACKEND_IP/g" /var/www/html/index.html
echo "Backend URL updated to: $BACKEND_IP"
EOF

chmod +x /usr/local/bin/update-backend-url

echo "Web tier setup complete"
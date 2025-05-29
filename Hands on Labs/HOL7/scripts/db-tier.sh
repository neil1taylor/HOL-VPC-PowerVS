#### DATABASE TIER SCRIPT ####
#!/bin/bash

# db-tier-init.sh - Run on database tier VSI

# Update system and install PostgreSQL
apt-get update
apt-get install -y postgresql postgresql-contrib

# Configure PostgreSQL to listen on all interfaces
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/*/main/postgresql.conf

# Allow connections from application tier
cat >> /etc/postgresql/*/main/pg_hba.conf << EOF
# Allow connections from any IP (restrict this in production)
host    all             all             0.0.0.0/0               md5
EOF

# Restart PostgreSQL to apply changes
systemctl restart postgresql

# Create test database and user
sudo -u postgres psql -c "CREATE USER testuser WITH PASSWORD 'testpassword';"
sudo -u postgres psql -c "CREATE DATABASE testdb OWNER testuser;"
sudo -u postgres psql -d testdb -c "CREATE TABLE test_records (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  value INTEGER NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);"
sudo -u postgres psql -d testdb -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO testuser;"
sudo -u postgres psql -d testdb -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO testuser;"

echo "Database tier setup complete"
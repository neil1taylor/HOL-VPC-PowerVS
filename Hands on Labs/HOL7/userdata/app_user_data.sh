#### APPLICATION TIER USER DATA ####
#cloud-config

package_update: true
package_upgrade: true

packages:
  - git
  - curl

write_files:
  - path: /opt/setup/deploy.sh
    permissions: '0755'
    content: |
      #!/bin/bash
      # Clone the repository containing deployment scripts
      git clone https://github.com/YOUR_USERNAME/vpc-three-tier-app.git /opt/deployment
      
      # Run the application tier script
      chmod +x /opt/deployment/app-tier.sh
      /opt/deployment/app-tier.sh
      
      # Log completion
      echo "$(date): Application tier deployment completed" >> /var/log/deployment.log

runcmd:
  - /opt/setup/deploy.sh
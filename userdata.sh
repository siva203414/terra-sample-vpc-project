#!/bin/bash

set -e

# Log User Data output for troubleshooting
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

# Update packages
dnf update -y

# Install Apache only; Amazon Linux 2023 may already have curl-minimal
dnf install -y httpd

# Get EC2 Instance ID using IMDSv2
TOKEN=$(curl -X PUT \
  "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" \
  -sS --fail)

INSTANCE_ID=$(curl \
  -H "X-aws-ec2-metadata-token: $TOKEN" \
  -sS --fail \
  http://169.254.169.254/latest/meta-data/instance-id)

# Create website directory
mkdir -p /var/www/html

# Create Villa website
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>My Villa | Holiday Destination</title>

  <style>
    * {
      box-sizing: border-box;
    }

    body {
      font-family: Arial, sans-serif;
      margin: 0;
      text-align: center;
      background: #f0f8ff;
      color: #333;
    }

    header {
      background: linear-gradient(135deg, #145a32, #239b56);
      color: white;
      padding: 40px 15px;
    }

    @keyframes colorChange {
      0%   { color: #ffcc00; }
      50%  { color: #00ff99; }
      100% { color: #66ccff; }
    }

    h1 {
      animation: colorChange 3s infinite;
      font-size: clamp(28px, 5vw, 44px);
    }

    .content {
      padding: 25px 15px;
    }

    .card {
      background: white;
      max-width: 650px;
      margin: 20px auto;
      padding: 25px;
      border-radius: 12px;
      box-shadow: 0 3px 12px #ccc;
    }

    h2 {
      color: #145a32;
    }

    .instance {
      color: #16803c;
      font-weight: bold;
      overflow-wrap: anywhere;
    }

    footer {
      background: #222;
      color: white;
      padding: 18px;
      margin-top: 25px;
    }
  </style>
</head>

<body>
  <header>
    <h1>Welcome to My Villa</h1>
    <p>Your Dream Holiday Destination</p>
  </header>

  <main class="content">
    <section class="card">
      <h2>About Our Villa</h2>
      <p>Enjoy a peaceful and comfortable stay at our beautiful villa.</p>
      <p>Relax, refresh and create wonderful memories with your family.</p>
    </section>

    <section class="card">
      <h2>Our Facilities</h2>
      <p>Swimming Pool</p>
      <p>Free Wi-Fi</p>
      <p>Beautiful Garden</p>
      <p>Free Parking</p>
      <p>Comfortable Rooms</p>
    </section>

    <section class="card">
      <h2>Server Details</h2>
      <p>Hosted on AWS EC2 using Terraform</p>
      <p>Instance ID:</p>
      <p class="instance">$INSTANCE_ID</p>
    </section>

    <section class="card">
      <h2>Contact Us</h2>
      <p>Phone: 9876543210</p>
      <p>Email: myvilla@example.com</p>
    </section>
  </main>

  <footer>
    <p>My Villa | Powered by AWS EC2 and Terraform</p>
  </footer>
</body>
</html>
EOF

# Set file permissions
chmod 644 /var/www/html/index.html

# Start Apache and enable it after reboot
systemctl enable --now httpd

# Verify Apache responds successfully
curl --fail --silent --show-error http://localhost/ >/dev/null

echo "User Data completed successfully. Instance ID: $INSTANCE_ID"

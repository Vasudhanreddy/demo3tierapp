// app.js
const express = require('express');
const mysql = require('mysql');
const app = express();
const port = 80; // Changed to port 80, typical for web servers/ALB targets

// --- Database Configuration ---
// Get database credentials from environment variables
const db_host = process.env.DB_HOST;
const db_user = process.env.DB_USER;
const db_password = process.env.DB_PASSWORD;

let dbConnectionStatus = 'Not Connected';

// Configure the database connection
const db = mysql.createConnection({
  host: db_host,
  user: db_user,
  password: db_password,
  database: 'webappdb'
});

// Attempt to connect to the database
// Note: This only attempts to connect once at startup. For production,
// it is better to pool connections and check connection health on demand.
db.connect(err => {
  if (err) {
    console.error('Error connecting to database:', err);
    dbConnectionStatus = `Error: ${err.message}`;
    return;
  }
  console.log('Successfully connected to the database.');
  dbConnectionStatus = 'Successfully Connected!';
});
// ------------------------------


// Main route to display a message and DB status
app.get('/', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>AWS Simple App</title>
        <style>
            body { font-family: sans-serif; text-align: center; margin-top: 50px; background-color: #f4f4f9; color: #333; }
            h1 { color: #007bff; }
            h3 { padding: 10px; border-radius: 5px; display: inline-block; }
            .success { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
            .error { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        </style>
    </head>
    <body>
        <h1>Hello from our AWS App!</h1>
        <p>This application is running on an EC2 instance behind a load balancer.</p>
        <h3 class="${dbConnectionStatus.startsWith('Error') ? 'error' : 'success'}">Database Connection Status: ${dbConnectionStatus}</h3>
    </body>
    </html>
  `);
});

// Health check route for the Load Balancer
// This is critical for auto-scaling and target group monitoring.
app.get('/health', (req, res) => {
    // Optionally check if the DB is still connected here before sending 200
    res.status(200).send('OK');
});

// Start the server
app.listen(port, () => {
  console.log(`App listening at http://localhost:${port}`);
});

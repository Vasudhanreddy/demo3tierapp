const express = require('express');
const mysql = require('mysql');
const app = express();
const port = 80;

// --- Database Configuration ---
// Get database credentials from environment variables
const db_host = process.env.DB_HOST;
const db_user = process.env.DB_USER;
const db_password = process.env.DB_PASSWORD;

let dbConnectionStatus = 'Not Connected';

// Configure the database connection (Do not use db.connect() here)
const db = mysql.createConnection({
  host: db_host,
  user: db_user,
  password: db_password,
  database: 'webappdb'
});

// Attempt to connect to the database, but DO NOT stop the server if it fails.
// This is crucial for passing the ALB health check and keeping the process alive.
function checkDbConnection() {
    db.connect(err => {
        if (err) {
            console.error('Error connecting to database:', err.message);
            // DO NOT EXIT THE PROCESS. Just update the status.
            dbConnectionStatus = `Error: ${err.message}`;
        } else {
            console.log('Successfully connected to the database.');
            dbConnectionStatus = 'Successfully Connected!';
            // End the connection check immediately if successful to prevent timeout
            db.end(); 
        }
    });
}

// Run the connection check at startup (and potentially periodically)
checkDbConnection();
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
    // The server is always available to respond to the health check
    res.status(200).send('OK');
});

// Start the server
app.listen(port, () => {
  console.log(`App listening at http://localhost:${port}`);
});

const express = require('express');
const mysql = require('mysql');
const app = express();
const port = 80;

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
db.connect(err => {
  if (err) {
    console.error('Error connecting to database:', err);
    dbConnectionStatus = `Error: ${err.message}`;
    return;
  }
  console.log('Successfully connected to the database.');
  dbConnectionStatus = 'Successfully Connected!';
});

// Main route to display a message and DB status
app.get('/', (req, res) => {
  res.send(`
    <h1>Hello from our AWS App!</h1>
    <p>This application is running on an EC2 instance behind a load balancer.</p>
    <h3>Database Connection Status: ${dbConnectionStatus}</h3>
  `);
});

// Health check route for the Load Balancer
app.get('/health', (req, res) => {
    res.status(200).send('OK');
});

app.listen(port, () => {
  console.log(`App listening at http://localhost:${port}`);
});

// Import necessary modules
const express = require('express');
const app = express();
// Define the port for the application, defaulting to 5000
const port = process.env.PORT || 5000;

// Track the deployment time of the application
const deploymentTime = new Date().toISOString();
// Get the application version from environment variables or default to 1.0.0
const version = process.env.APP_VERSION || '1.0.0';

// Middleware for parsing JSON requests
app.use(express.json());
// Serve static files from the 'public' directory
app.use(express.static('public'));

// Root endpoint: Returns a HTML page with application info
app.get('/', (req, res) => {
    res.send(`
<!DOCTYPE html>
<html>
<head>
    <title>CI/CD Pipeline App</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
        .container { max-width: 600px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .status { color: #28a745; font-weight: bold; }
        .info { background: #e9ecef; padding: 15px; border-radius: 5px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 CI/CD Pipeline App</h1>
        <p class="status">Status: Running</p>
        <div class="info">
            <p><strong>Version:</strong> ${version}</p>
            <p><strong>Deployed:</strong> ${deploymentTime}</p>
        </div>
        <p>Application successfully deployed and running!</p>
    </div>
</body>
</html>
    `);
});

// API Info endpoint: Returns application version and status in JSON format
app.get('/api/info', (req, res) => {
    res.json({
        version,
        deploymentTime,
        status: "running"
    });
});

// Health check endpoint for monitoring systems and container health checks
app.get('/health', (req, res) => {
    res.status(200).json({
        status: "healthy"
    });
});

// Start the server if the file is run directly
if (require.main === module) {
    app.listen(port, '0.0.0.0', () => {
        console.log(`Server running on port ${port}`);
    });
}

// Export the app for testing purposes
module.exports = app;
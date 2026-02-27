// Import Supertest for HTTP testing
const request = require("supertest");
// Import the application to be tested
const app = require("./app");

// Group application related tests
describe("App Tests", () => {
  // Test for the root endpoint
  test("GET / should return HTML page", async () => {
    const response = await request(app).get("/");
    // Assert a successful status code
    expect(response.status).toBe(200);
    // Assert that the returned HTML contains the expected title
    expect(response.text).toContain("CI/CD Pipeline App");
    // Assert that the HTML contains version info
    expect(response.text).toContain("Version:");
    // Assert that the HTML contains deployment time
    expect(response.text).toContain("Deployed:");
  });

  // Test for the health check endpoint
  test("GET /health should return healthy status", async () => {
    const response = await request(app).get("/health");
    // Assert successful response status
    expect(response.status).toBe(200);
    // Assert the returned health status
    expect(response.body.status).toBe("healthy");
  });

  // Test for the API info endpoint
  test("GET /api/info should return app info", async () => {
    const response = await request(app).get("/api/info");
    // Assert successful status code
    expect(response.status).toBe(200);
    // Assert presence of version and status properties in JSON response
    expect(response.body).toHaveProperty("version");
    expect(response.body).toHaveProperty("status");
    // Assert status is running
    expect(response.body.status).toBe("running");
  });

  // Test for the API info endpoint to include deployment time
  test("GET /api/info should return deployment time", async () => {
    const response = await request(app).get("/api/info");
    // Assert presence of deploymentTime property
    expect(response.body).toHaveProperty("deploymentTime");
  });

  // Test root endpoint returns proper HTML structure
  test("GET / should return proper HTML structure", async () => {
    const response = await request(app).get("/");
    // Assert HTML contains required elements
    expect(response.text).toContain("<!DOCTYPE html>");
    expect(response.text).toContain("<html>");
    expect(response.text).toContain("</html>");
    expect(response.text).toContain("Status: Running");
  });
});

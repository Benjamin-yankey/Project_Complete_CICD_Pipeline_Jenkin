/**
 * Jest Configuration File
 * Configures the test environment, coverage collection, and reporting.
 */
module.exports = {
  // Use Node.js as the test environment.
  testEnvironment: 'node',
  // Files to ignore when generating coverage reports.
  coveragePathIgnorePatterns: ['/node_modules/'],
  // Default timeout for each test case in milliseconds.
  testTimeout: 10000,
  // Define which files should be included in coverage collection.
  collectCoverageFrom: [
    '*.js',
    '!jest.config.js',
    '!.eslintrc.js'
  ],
  // Minimum coverage thresholds that must be met for tests to pass.
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 75,
      lines: 80,
      statements: 80
    }
  },
  // Configure test results reporting.
  reporters: [
    'default', // Default console reporter.
    ['jest-junit', {
      outputDirectory: 'test-results', // Directory for JUnit XML reports.
      outputName: 'junit.xml'         // Filename for the report.
    }]
  ]
};

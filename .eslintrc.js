/**
 * ESLint Configuration File
 * Defines rules and environments for static code analysis.
 */
module.exports = {
  // Environments define global variables that are predefined.
  env: {
    node: true,      // Node.js global variables and Node.js scoping.
    es2021: true,    // Adds all ECMAScript 2021 globals and automatically sets the ecmaVersion parser option to 12.
    jest: true       // Jest global variables.
  },
  // Use the recommended rules from ESLint.
  extends: 'eslint:recommended',
  // Specify the JavaScript language options you want to support.
  parserOptions: {
    ecmaVersion: 12  // Supports ES12 syntax.
  },
  // Custom rules configuration.
  rules: {
    'no-console': 'off',    // Allow use of console.log.
    'no-unused-vars': 'warn' // Show warnings for variables that are declared but not used.
  }
};

# Use official Node.js Alpine image for a lightweight and secure base
FROM node:18-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json to install dependencies
COPY package*.json ./
# Install production dependencies only to reduce image size
RUN npm ci --only=production

# Copy the application source code
COPY app.js .

# Expose port 5000 for the application
EXPOSE 5000

# Add a health check to ensure the application is responding
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:5000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Run as a non-privileged user for better security
USER node

# Command to start the application
CMD ["npm", "start"]

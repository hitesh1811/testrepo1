# Use official Node.js runtime as base image
FROM node:18-alpine

# Set working directory inside container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json first (for better caching)
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy the rest of the application code
COPY . .

# Expose the app port (update if your app uses a different port)
EXPOSE 3000

# Start the application
CMD ["node", "app.js"]

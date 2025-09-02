# Use official Node.js runtime as base image
FROM node:18-alpine

# Set working directory inside container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json first
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy the rest of the application
COPY . .

# Expose the app port (update if needed)
EXPOSE 3000

# Start app with npm
CMD ["npm", "start"]

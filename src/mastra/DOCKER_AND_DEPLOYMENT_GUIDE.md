# Docker and Deployment Guide

This guide provides detailed steps for setting up, building, and deploying the GitHub Reporter within a Docker environment. Follow these instructions to run the application locally or deploy it in a production environment.

## Prerequisites

- [Docker](https://www.docker.com/get-started) installed on your machine.
- [Node.js](https://nodejs.org) for local development.
- Ensure environment variables are prepared, specifically for API configurations.

## Building the Docker Image

1. **Navigate to the project root:**
   ```bash
   cd /path/to/your/project
   ```

2. **Build the Docker image:**
   ```bash
   docker build -t github-reporter .
   ```

*Note: Ensure to update the version tag after changes that require a fresh build.*

## Running the Docker Container

1. **Run the container:**
   ```bash
   docker run -d -p 8080:8080 --name github-reporter github-reporter
   ```

2. **Environment variables:**
   You can pass necessary environment variables using `-e` flag:
   ```bash
   docker run -d -p 8080:8080 --name github-reporter \
     -e API_BASE_URL='http://your-api-url' \
     -e MODEL_NAME_AT_ENDPOINT='your-model-name' \
     github-reporter
   ```

## Health Check and Verification

- **Verify the application is accessible:**
  Open a browser and go to `http://localhost:8080/health` to check the health status.

## Usage of npm Scripts inside the Container

- **Execute npm scripts if needed:**
  ```bash
  docker exec -it github-reporter npm run <script-name>
  ```

## Deployment Suggestions

- Consider using services such as AWS ECS, Google Cloud Run, or Kubernetes for deployment.
- Adjust your deployment strategy based on traffic and performance requirements.

## Monitoring and Troubleshooting

- **Logs:** Access logs using:
  ```bash
  docker logs github-reporter
  ```
- **Shell access:**
  ```bash
  docker exec -it github-reporter /bin/bash
  ```

## Updating and Redeploying

- After making code changes, rebuild the Docker image and redeploy the container.

## Persistent Storage

- To retain application data, mount volumes using the `-v` flag in `docker run`.

## Best Practices

- Regularly update base images to mitigate potential security vulnerabilities.
- Keep environment variables secure and avoid hardcoding sensitive info in your code.

This guide serves as a starting point for deploying the GitHub Reporter agent. Adjust as necessary for your specific environment and setup.

# Docker Compose Configuration for a Next.js Application

This repository provides a comprehensive solution for deploying Next.js applications using Docker Compose and Traefik. Designed for flexibility and high configurability, this setup includes automatic update management via GitHub webhooks, streamlining continuous integration and continuous deployment (CI/CD) processes. It also offers secure HTTPS support with Let’s Encrypt, ensuring automatic SSL certificate renewal for enhanced security. Ideal for production deployments, this configuration enables fast and reliable setup of modern applications while reducing maintenance overhead through automation.

[🇫🇷 Version française disponible ici](readme.fr.md)

## Prerequisites

- Docker
- Docker Compose

## Service Structure

### Traefik

Traefik is used as a reverse proxy and SSL certificate manager via Let's Encrypt.

### App

The Next.js application is deployed via a Docker service that connects to Traefik for route and certificate management. Commands to manage the Next.js application use `pnpm` as the package manager.

## Environment Variables

The following environment variables can be set to configure the behavior of Traefik and the application.

### `ACME_EMAIL`

- **Description**: Email used by Traefik for managing Let's Encrypt certificates. This email is used to receive notifications from Let's Encrypt regarding SSL certificates' status.
- **Example**: `example@example.com`
- **Note**: It is important to use a valid email to receive notifications in case of issues with the certificates.

### `TRUSTED_IPS`

- **Description**: List of trusted IP addresses for forwarding headers (`X-Forwarded-For`, etc.). This secures connections by ensuring that only requests from these IPs are considered reliable.
- **Example**: `127.0.0.1/32,192.168.1.1`
- **Note**: Ensure this list is correctly configured to include only trusted IP addresses.

### `APP_DOMAIN`

- **Description**: The main domain name used to access the application. Traefik uses this variable to route HTTP/HTTPS traffic to the correct service.
- **Example**: `example.com`
- **Note**: This domain must point to the IP address of your server where this Docker Compose configuration is deployed.

### `WEBHOOK_PATH`

- **Description**: URL path used for GitHub webhooks. This path is used to set up a specific route for webhook requests.
- **Example**: `/webhook`
- **Note**: The path must match the one configured in your GitHub repository settings for webhooks.

### `GITHUB_SECRET`

- **Description**: Secret key used to secure GitHub webhooks. This key is used to verify that webhook requests are indeed coming from GitHub.

### `REPO_URL`

- **Description**: GitHub repository URL containing the Next.js application code. This parameter is used to clone or update the application's code from GitHub.
- **Example**: `https://github.com/your-username/your-repo.git`

### `BRANCH`

- **Description**: GitHub repository branch to deploy. By default, the `main` branch is used.
- **Example**: `main`
- **Note**: You can specify another branch to test features or deploy specific versions of your application.

### `POST_BUILD_COMMANDS`

- **Description**: Additional commands to run after the application build. This can include database migrations, cleanup commands, etc.
- **Example**: `pnpm run migrate && pnpm run build`
- **Note**: `pnpm` is used to manage commands and packages for the Next.js application.

### `DATABASE_URL`

- **Description**: Connection URL for the database used by the application. This parameter is essential for the application to connect to the database.
- **Example**: `postgresql://user:password@localhost:5432/database`

## GitHub Webhook Configuration

To automatically update your Next.js application when you push changes to your GitHub repository, a webhook must be configured.

### Steps to Configure the GitHub Webhook

1. **Access your GitHub repository settings**:

   - Go to the main page of your repository on GitHub.
   - Click on the **Settings** tab.

2. **Access the Webhooks section**:

   - In the left sidebar, click on **Webhooks**.
   - Then click on the **Add webhook** button.

3. **Configure the Webhook URL**:

   - In the **Payload URL** field, enter your server's URL followed by the webhook path. For example:
     ```
     https://example.com/webhook/
     ```
   - This URL corresponds to the domain defined in the `APP_DOMAIN` variable followed by the path defined in `WEBHOOK_PATH`.

4. **Choose the content type**:

   - In the **Content type** field, select `application/json`.

5. **Select the events to trigger**:

   - Under **Which events would you like to trigger this webhook?**, select **Just the push event.**
   - This means the webhook will only trigger when you push new commits to your repository.

6. **Set up a secret**:

   - You need to define a secret in the **Secret** field to secure the webhook requests.
   - Use the same secret as in the `GITHUB_SECRET` environment variable.

7. **Save the Webhook**:

   - Click on **Add webhook** to save the settings.

## Environment Variables for the Next.js Application

All environment variables needed for the Next.js application can be set in a `.env.app` file. This file is automatically loaded by the Docker service and can contain variables such as those for database configuration, external APIs, or any other application-specific settings.

### Example `.env.app` File:

```env
# Example configuration for the Next.js application

DATABASE_URL=postgresql://user:password@localhost:5432/database
NEXT_PUBLIC_API_URL=https://api.example.com
```

This `.env.app` file should be placed at the root of your project. It is automatically considered when deploying your application via Docker Compose.

## How to Use This Configuration

1. Clone this repository.
2. Create a `.env` file at the root of the project with the environment variables defined for Traefik.
3. Create a `.env.app` file at the root of the project with the necessary environment variables for your Next.js application.
4. Start Docker Compose:
   ```bash
   docker-compose up -d
   ```
5. Traefik and the application will be automatically launched with the specified configurations.

### Example .env File

Here is an example of a `.env` file that you can use to configure Traefik:

```.env
# GitHub repository URL to clone
REPO_URL=git@github.com:example/example.git

# Branch to clone
BRANCH=main

# SSH key to clone the project from GitHub
SSH_PRIVATE_KEY="-----BEGIN OPENSSH PRIVATE KEY-----
.....
.....
.....
.....
.....
.....
-----END OPENSSH PRIVATE KEY-----"

# Secret used in the GitHub webhook
GITHUB_SECRET="my github secret"

# Path for the GitHub webhook
WEBHOOK_PATH=/webhook

# Command to run after building the sources
POST_BUILD_COMMANDS=pnpm prisma migrate deploy

# Email configuration for Let's Encrypt
ACME_EMAIL=example@example.com

# Trusted IP addresses for forwarding headers
TRUSTED_IPS=127.0.0.1/32,192.168.1.1

# Application domain
APP_DOMAIN=example.com
```

### Example .env.app File

Here is an example of a `.env.app` file for your Next.js application:

```.env
DATABASE_URL=postgresql://user:password@localhost:5432/database
NEXT_PUBLIC_API_URL=https://api.example.com
```

## Support and Contact

**Offroadlabs** is a development studio specializing in React, TypeScript, Next.js, Symfony, Docker, and many other technologies. If you need development services or support for your projects, feel free to contact us at: **sebastien[at]offroadlabs.com**.
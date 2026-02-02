# NearVendor Application Deployment

This directory contains all the necessary files to build, deploy, and manage the NearVendor application stack using Docker Compose.

The setup is self-contained and designed for an internal server using an IP address. It includes:
-   `frontend` (Next.js)
-   `backend` (NestJS)
-   `nginx` (as a reverse proxy)
-   `db` (PostGIS/PostgreSQL)
-   `redis` (for caching and queues)

HTTPS is enabled using a self-signed SSL certificate.

---

## Deployment Instructions

### Step 0: Install Prerequisites (Run on a Fresh Server)

Before deploying, you need to install Docker and Docker Compose. A script is provided for Debian-based systems like Ubuntu.

Run the script with `sudo`:

```bash
sudo sh ./install-prereqs.sh
```

### Step 1: Configure the Environment

1.  **Open the `.env` file.**
2.  **Update the following values:**
    -   `SERVER_IP`: The public IP address of this server.
    -   `DB_PASSWORD`: A secure password for the PostgreSQL database.
    -   `REDIS_PASSWORD`: A secure password for the Redis instance.
    -   `JWT_SECRET`: A long, random, and secret string.

### Step 2: Generate Self-Signed SSL Certificate (One-Time Setup)

From within this `deployment` directory, run:

```bash
sh ./generate-ssl.sh
```

### Step 3: Launch the Application

Once the `.env` file is configured and the SSL certificate is generated, you can build and start all services.

```bash
sh ./deploy.sh start
```

Your application will be accessible at `https://<your_server_ip>`.

> **Browser Security Warning:** Because this uses a self-signed certificate, your browser will show a security warning. This is expected. You will need to accept the warning to proceed.

---

## Managing the Deployment

-   **Start Services:** `sh ./deploy.sh start`
-   **Stop Services:** `sh ./deploy.sh stop`
-   **View Logs:** `sh ./deploy.sh logs-f`
-   **Stop and Remove Everything:** `sh ./deploy.sh down`
-   **Rebuild Images:** `sh ./deploy.sh build`

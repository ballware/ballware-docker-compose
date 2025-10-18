# Ballware Docker Compose Demo Environment

This repository contains a complete demo and evaluation environment for the Ballware Rapid Business Software Development Platform. It creates a ready-to-use Docker application for evaluating and testing Ballware software.

**🇩🇪 [Deutsche Version / German Version](README_DE.md)**

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)  
- [Environment Variables Configuration](#environment-variables-configuration)
- [Trust TLS Certificate](#trust-tls-certificate)
- [Start Application](#start-application)
- [Access Applications](#access-applications)
- [Default Credentials](#default-credentials)
- [Architecture](#architecture)
- [Troubleshooting](#troubleshooting)
- [Advanced Configuration](#advanced-configuration)


## 🔧 Prerequisites

- **Docker**: Version 20.10 or higher
- **Docker Compose**: Version 2.0 or higher
- **At least 8 GB RAM**: For all services
- **Free ports**: 3000, 3002, 5001-5005, 5432, 8025, 9000, 9001
- **GitHub Personal Access Token**: For accessing Ballware repositories
- **DevExpress License**: Required for successful application build

Check your Docker installation:
```bash
docker --version
docker compose version
```

## ⚡ Quick Start

1. **Clone repository**:
   ```bash
   git clone https://github.com/ballware/ballware-docker-compose.git
   cd ballware-docker-compose
   ```

2. **Set up environment variables** (see [Environment Variables](#environment-variables-configuration))

3. **Start services**:
   ```bash
   docker compose up -d
   ```

4. **Trust TLS certificate** (see [Trust TLS Certificate](#trust-tls-certificate))

5. **Open application**: http://localhost:3000

## 🔐 Environment Variables Configuration

Create a `.env` file in the project directory with the following **required** variables:

```bash
# GitHub Credentials (REQUIRED)
# Needed for accessing publicly available NuGet packages from Ballware
GITHUB_USERNAME=your-github-username
GITHUB_PAT=your-github-personal-access-token

# DevExpress Licenses (REQUIRED)
# Both values are necessary for successful application build
BALLWARE_DEVEXTREMEKEY=your-devextreme-license-key
DEVEXPRESS_NUGETFEED=https://nuget.devexpress.com/your-feed-key/api

# Google Maps API (optional)
BALLWARE_GOOGLEKEY=your-google-maps-api-key
```

### Create GitHub Personal Access Token

GitHub credentials are required to access NuGet packages published by Ballware on GitHub. **Only any valid GitHub account is required - no special permissions or access to private repositories.**

1. Go to GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Select the following minimal scopes:
   - `read:packages` (Download packages from GitHub Package Registry)
   - Optional: `repo` (only if you also want access to private Ballware repositories)
4. Copy the token to your `.env` file

**Note**: You can use any valid GitHub account. No special permissions or organization memberships are required.

### Configure DevExpress License

Both DevExpress values are required for successful application build:

1. **DevExtreme License Key**: Get this from your DevExpress account
2. **DevExpress NuGet Feed**: Your personal NuGet feed URL from DevExpress

Without this configuration, the service build will fail. If you don't have a DevExpress license yet, visit [DevExpress.com](https://www.devexpress.com/) for more information.

### Optional Environment Variables

All passwords have default values and can be overridden:

```bash
# Database Passwords
DB_ADMIN_PASSWORD=YourAdminPassword
DB_KEYCLOAK_PASSWORD=YourKeycloakPassword
DB_QUARTZ_PASSWORD=YourQuartzPassword
DB_STORAGE_PASSWORD=YourStoragePassword
DB_META_PASSWORD=YourMetaPassword
DB_TENANT_PASSWORD=YourTenantPassword
DB_ML_PASSWORD=YourMLPassword
DB_REPORTING_PASSWORD=YourReportingPassword

# Keycloak Admin
KEYCLOAK_ADMIN_USER=admin@ballware.local
KEYCLOAK_ADMIN_PASSWORD=YourKeycloakAdminPassword

# MinIO (Object Storage)
MINIO_ROOT_USER=admin@ballware.local
MINIO_ROOT_PASSWORD=YourMinIOPassword

# Service Client Secrets
STORAGE_CLIENT_SECRET=YourStorageClientSecret
META_CLIENT_SECRET=YourMetaClientSecret
ML_CLIENT_SECRET=YourMLClientSecret
GENERIC_CLIENT_SECRET=YourGenericClientSecret
REPORTING_CLIENT_SECRET=YourReportingClientSecret
```

## 🔒 Trust TLS Certificate

Ballware uses Keycloak for authentication over HTTPS. The `preseed-keycloak` container automatically creates a self-signed TLS certificate that you need to mark as trusted in your browser.

### macOS - Add certificate to Keychain:

```bash
# Extract certificate from container
docker compose up preseed-keycloak
docker compose cp preseed-keycloak:/certs-out/tls.crt ./keycloak-cert.crt

# Add certificate to system keychain
sudo security add-trusted-cert -d -r trustRoot -k /System/Library/Keychains/SystemRootCertificates.keychain ./keycloak-cert.crt
```

### Linux - Add certificate to system:

```bash
# Extract certificate from container
docker compose up preseed-keycloak
docker compose cp preseed-keycloak:/certs-out/tls.crt ./keycloak-cert.crt

# Add certificate to system (Ubuntu/Debian)
sudo cp ./keycloak-cert.crt /usr/local/share/ca-certificates/keycloak.crt
sudo update-ca-certificates
```

### Windows - Import certificate:

```powershell
# Extract certificate from container
docker compose up preseed-keycloak
docker compose cp preseed-keycloak:/certs-out/tls.crt ./keycloak-cert.crt

# Manually import certificate:
# 1. Double-click on keycloak-cert.crt
# 2. "Install Certificate" → "Local Machine"
# 3. Select "Trusted Root Certification Authorities"
```

### Alternative: Accept browser warning

If you don't want to install the certificate system-wide:

1. Open https://localhost:3002 in your browser
2. Click "Advanced" → "Proceed to localhost (unsafe)"
3. The certificate will be accepted for this session

## 🚀 Start Application

```bash
# Start all services
docker compose up -d

# Follow logs
docker compose logs -f

# Check status
docker compose ps

# Stop services
docker compose down
```

## 🌐 Access Applications

All Ballware services provide interactive API documentation via Swagger UI under the `/swagger` path. The Reporting Service additionally provides Report Designer and Document Viewer as microfrontends that are seamlessly integrated into the main application.

| Service | URL | Description |
|---------|-----|-------------|
| **Ballware Web App** | http://localhost:3000 | Main application |
| **Keycloak Admin** | https://localhost:3002 | Identity & Access Management |
| **Meta Service** | http://localhost:5001 | Metadata API |
| **Meta Service API Docs** | http://localhost:5001/swagger | Swagger UI for Meta Service |
| **Generic Service** | http://localhost:5002 | Generic Data API |
| **Generic Service API Docs** | http://localhost:5002/swagger | Swagger UI for Generic Service |
| **ML Service** | http://localhost:5003 | Machine Learning API |
| **ML Service API Docs** | http://localhost:5003/swagger | Swagger UI for ML Service |
| **Reporting Service** | http://localhost:5004 | Document/Report API |
| **Reporting Service API Docs** | http://localhost:5004/swagger | Swagger UI for Reporting Service |
| **Report Designer** | http://localhost:5004/designer | Report Designer (Microfrontend) |
| **Document Viewer** | http://localhost:5004/viewer | Document Viewer (Microfrontend) |
| **Storage Service** | http://localhost:5005 | File Storage API |
| **Storage Service API Docs** | http://localhost:5005/swagger | Swagger UI for Storage Service |
| **MinIO Console** | http://localhost:9001 | Object Storage Management |
| **MailPit** | http://localhost:8025 | Email Development Server |
| **PostgreSQL** | localhost:5432 | Database |

## 👤 Default Credentials

### Ballware Web App (http://localhost:3000)
Default users are automatically created on first startup. Additional users can be created through Keycloak administration.

### Keycloak Admin (https://localhost:3002)
- **Username**: `admin@ballware.local`
- **Password**: `ChangeMe2025!` (or your `KEYCLOAK_ADMIN_PASSWORD`)

### MinIO Console (http://localhost:9001)
- **Username**: `admin@ballware.local`
- **Password**: `ChangeMe2025!` (or your `MINIO_ROOT_PASSWORD`)

### PostgreSQL (localhost:5432)
- **Username**: `admin`
- **Password**: `ChangeMe2025!` (or your `DB_ADMIN_PASSWORD`)

## 🏗️ Architecture

The Ballware platform consists of the following components:

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Web Client    │    │    Keycloak      │    │   PostgreSQL    │
│   (Angular)     │◄──►│  (Identity)      │    │   (Database)    │
│   Port: 3000    │    │   Port: 3002     │    │   Port: 5432    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │
         └───────────────────────┼─────────────────┐
                                │                 │
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│  Meta Service   │    │ Generic Service  │    │  Storage Svc    │
│   Port: 5001    │    │   Port: 5002     │    │   Port: 5005    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                │
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   ML Service    │    │ Reporting Svc    │    │      MinIO      │
│   Port: 5003    │    │   Port: 5004     │    │   Port: 9000    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

### Service Descriptions:

- **Web Client**: Angular frontend for the user interface
- **Keycloak**: OpenID Connect Identity Provider for authentication
- **Meta Service**: Manages application metadata and configurations
- **Generic Service**: Manages dynamic business data
- **Storage Service**: File and document management
- **ML Service**: Machine Learning and data analysis
- **Reporting Service**: Reports and document generation
- **PostgreSQL**: Relational database for all services
- **MinIO**: S3-compatible object storage

## 🔧 Troubleshooting

### Common Issues:

**1. Service won't start / Port already in use:**
```bash
# Check which processes are using the ports
lsof -i :3000
lsof -i :5432

# Stop and restart services
docker compose down
docker compose up -d
```

**2. GitHub Authentication Error:**
```bash
# Check your .env file
cat .env | grep GITHUB

# Test your PAT
curl -H "Authorization: token YOUR_GITHUB_PAT" https://api.github.com/user
```

**3. Database Connection Error:**
```bash
# Check PostgreSQL logs
docker compose logs postgres

# Check database status
docker compose exec postgres pg_isready -U admin -d postgres
```

**4. Certificate Error (ERR_CERT_AUTHORITY_INVALID):**
- See [Trust TLS Certificate](#trust-tls-certificate)
- Make sure you are using https://localhost:3002

**5. Services won't build (Network errors):**
```bash
# Clear Docker cache
docker system prune -a

# Build services individually
docker compose build --no-cache
```

### View Logs:

```bash
# All service logs
docker compose logs -f

# Specific service logs
docker compose logs -f keycloak
docker compose logs -f postgres
docker compose logs -f app
```

### Restart Services:

```bash
# Restart individual service
docker compose restart keycloak

# Restart all services
docker compose restart

# Rebuild service container
docker compose build --no-cache keycloak
docker compose up -d keycloak
```

## ⚙️ Advanced Configuration

### Configure External Keycloak URL:

If you want to use Keycloak over an external domain:

```bash
# Add to .env
KEYCLOAK_REALM_BASE=https://your-keycloak-domain.com/realms/ballware
```

### Production-like Configuration:

For a more production-like environment:

1. **Set stronger passwords**:
```bash
# Generate secure passwords
openssl rand -base64 32
```

2. **Use external volumes**:
```yaml
# In docker-compose.override.yml
volumes:
  pgdata:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /path/to/your/postgres/data
```

3. **Add resource limits**:
```yaml
# In docker-compose.override.yml  
services:
  postgres:
    deploy:
      resources:
        limits:
          memory: 2G
          cpus: '1.0'
```

### Development Mode:

For development with local code changes:

```bash
# Create docker-compose.dev.yml for local development
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d
```

## 📞 Support

For issues or questions:

1. Check the [Troubleshooting](#troubleshooting) section
2. Look at the Docker Compose logs: `docker compose logs -f`
3. Open an issue in the [ballware-docker-compose](https://github.com/ballware/ballware-docker-compose) repository

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.



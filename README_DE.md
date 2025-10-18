# Ballware Docker Compose Demo Environment

Diese Repository enthält eine vollständige Demo- und Evaluierungsumgebung für die Ballware Rapid Business Software Development Platform. Es erstellt eine sofort einsatzbereite Docker-Anwendung zur Evaluierung und zum Testen der Ballware-Software.

**🇺🇸 [English Version / Englische Version](README.md)**

## 📋 Inhaltsverzeichnis

- [Voraussetzungen](#voraussetzungen)
- [Schnellstart](#schnellstart)  
- [Umgebungsvariablen konfigurieren](#umgebungsvariablen-konfigurieren)
- [TLS-Zertifikat vertrauen](#tls-zertifikat-vertrauen)
- [Anwendung starten](#anwendung-starten)
- [Zugriff auf die Anwendungen](#zugriff-auf-die-anwendungen)
- [Standard-Anmeldedaten](#standard-anmeldedaten)
- [Architektur](#architektur)
- [Troubleshooting](#troubleshooting)
- [Erweiterte Konfiguration](#erweiterte-konfiguration)

## 🔧 Voraussetzungen

- **Docker**: Version 20.10 oder höher
- **Docker Compose**: Version 2.0 oder höher
- **Mindestens 8 GB RAM**: Für alle Services
- **Freie Ports**: 3000, 3002, 5001-5005, 5432, 8025, 9000, 9001
- **GitHub Personal Access Token**: Für den Zugriff auf Ballware-Repositories
- **DevExpress Lizenz**: Erforderlich für erfolgreiches Build der Anwendung

Überprüfen Sie Ihre Docker-Installation:
```bash
docker --version
docker compose version
```

## ⚡ Schnellstart

1. **Repository klonen**:
   ```bash
   git clone https://github.com/ballware/ballware-docker-compose.git
   cd ballware-docker-compose
   ```

2. **Umgebungsvariablen einrichten** (siehe [Umgebungsvariablen konfigurieren](#umgebungsvariablen-konfigurieren))

3. **Services starten**:
   ```bash
   docker compose up -d
   ```

4. **TLS-Zertifikat vertrauen** (siehe [TLS-Zertifikat vertrauen](#tls-zertifikat-vertrauen))

5. **Anwendung öffnen**: http://localhost:3000

## 🔐 Umgebungsvariablen konfigurieren

Erstellen Sie eine `.env` Datei im Projektverzeichnis mit den folgenden **erforderlichen** Variablen:

```bash
# GitHub Zugangsdaten (ERFORDERLICH)
# Benötigt für den Zugriff auf öffentlich verfügbare NuGet-Pakete von Ballware
GITHUB_USERNAME=ihr-github-benutzername
GITHUB_PAT=ihr-github-personal-access-token

# DevExpress Lizenzen (ERFORDERLICH)
# Beide Werte sind für ein erfolgreiches Build der Anwendung notwendig
BALLWARE_DEVEXTREMEKEY=ihr-devextreme-lizenzschlüssel
DEVEXPRESS_NUGETFEED=https://nuget.devexpress.com/ihr-feed-key/api

# Google Maps API (optional)
BALLWARE_GOOGLEKEY=ihr-google-maps-api-schlüssel
```

### GitHub Personal Access Token erstellen

Die GitHub-Credentials werden benötigt, um auf die von Ballware auf GitHub veröffentlichten NuGet-Pakete zugreifen zu können. **Es ist lediglich ein beliebiger gültiger GitHub-Zugang erforderlich - keine besonderen Berechtigungen oder Zugriff auf private Repositories.**

1. Gehen Sie zu GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Klicken Sie "Generate new token (classic)"
3. Wählen Sie die folgenden minimalen Scopes:
   - `read:packages` (Download packages from GitHub Package Registry)
   - Optional: `repo` (nur falls Sie auch auf private Ballware-Repositories zugreifen möchten)
4. Kopieren Sie den Token in Ihre `.env` Datei

**Hinweis**: Sie können jeden beliebigen gültigen GitHub-Account verwenden. Es sind keine speziellen Berechtigungen oder Organisationsmitgliedschaften erforderlich.

### DevExpress Lizenz konfigurieren

Für ein erfolgreiches Build der Anwendung sind beide DevExpress-Werte erforderlich:

1. **DevExtreme Lizenzschlüssel**: Erhalten Sie diesen von Ihrem DevExpress-Account
2. **DevExpress NuGet Feed**: Ihr persönlicher NuGet-Feed-URL von DevExpress

Ohne diese Konfiguration schlägt das Build der Services fehl. Falls Sie noch keine DevExpress-Lizenz haben, besuchen Sie [DevExpress.com](https://www.devexpress.com/) für weitere Informationen.

### Optionale Umgebungsvariablen

Alle Passwörter haben Standardwerte und können überschrieben werden:

```bash
# Datenbank-Passwörter
DB_ADMIN_PASSWORD=IhrAdminPasswort
DB_KEYCLOAK_PASSWORD=IhrKeycloakPasswort
DB_QUARTZ_PASSWORD=IhrQuartzPasswort
DB_STORAGE_PASSWORD=IhrStoragePasswort
DB_META_PASSWORD=IhrMetaPasswort
DB_TENANT_PASSWORD=IhrTenantPasswort
DB_ML_PASSWORD=IhrMLPasswort
DB_REPORTING_PASSWORD=IhrReportingPasswort

# Keycloak Admin
KEYCLOAK_ADMIN_USER=admin@ballware.local
KEYCLOAK_ADMIN_PASSWORD=IhrKeycloakAdminPasswort

# MinIO (Object Storage)
MINIO_ROOT_USER=admin@ballware.local
MINIO_ROOT_PASSWORD=IhrMinIOPasswort

# Service Client Secrets
STORAGE_CLIENT_SECRET=IhrStorageClientSecret
META_CLIENT_SECRET=IhrMetaClientSecret
ML_CLIENT_SECRET=IhrMLClientSecret
GENERIC_CLIENT_SECRET=IhrGenericClientSecret
REPORTING_CLIENT_SECRET=IhrReportingClientSecret
```

## 🔒 TLS-Zertifikat vertrauen

Ballware verwendet Keycloak für die Authentifizierung über HTTPS. Der `preseed-keycloak` Container erstellt automatisch ein selbstsigniertes TLS-Zertifikat, das Sie in Ihrem Browser als vertrauenswürdig markieren müssen.

### macOS - Zertifikat zur Keychain hinzufügen:

```bash
# Zertifikat aus dem Container extrahieren
docker compose up preseed-keycloak
docker compose cp preseed-keycloak:/certs-out/tls.crt ./keycloak-cert.crt

# Zertifikat zur System-Keychain hinzufügen
sudo security add-trusted-cert -d -r trustRoot -k /System/Library/Keychains/SystemRootCertificates.keychain ./keycloak-cert.crt
```

### Linux - Zertifikat zum System hinzufügen:

```bash
# Zertifikat aus dem Container extrahieren
docker compose up preseed-keycloak
docker compose cp preseed-keycloak:/certs-out/tls.crt ./keycloak-cert.crt

# Zertifikat zum System hinzufügen (Ubuntu/Debian)
sudo cp ./keycloak-cert.crt /usr/local/share/ca-certificates/keycloak.crt
sudo update-ca-certificates
```

### Windows - Zertifikat importieren:

```powershell
# Zertifikat aus dem Container extrahieren
docker compose up preseed-keycloak
docker compose cp preseed-keycloak:/certs-out/tls.crt ./keycloak-cert.crt

# Zertifikat manuell importieren:
# 1. Doppelklick auf keycloak-cert.crt
# 2. "Install Certificate" → "Local Machine"
# 3. "Trusted Root Certification Authorities" auswählen
```

### Alternative: Browser-Warnung akzeptieren

Falls Sie das Zertifikat nicht systemweit installieren möchten:

1. Öffnen Sie https://localhost:3002 in Ihrem Browser
2. Klicken Sie "Advanced" → "Proceed to localhost (unsafe)"
3. Das Zertifikat wird für diese Sitzung akzeptiert

## 🚀 Anwendung starten

```bash
# Alle Services starten
docker compose up -d

# Logs verfolgen
docker compose logs -f

# Status überprüfen
docker compose ps

# Services stoppen
docker compose down
```

## 🌐 Zugriff auf die Anwendungen

Alle Ballware-Services bieten eine interaktive API-Dokumentation über Swagger-UI unter dem `/swagger` Pfad. Der Reporting Service stellt zusätzlich Report-Designer und Dokumentenviewer als Microfrontends bereit, die nahtlos in die Hauptanwendung integriert werden.

| Service | URL | Beschreibung |
|---------|-----|--------------|
| **Ballware Web App** | http://localhost:3000 | Haupt-Anwendung |
| **Keycloak Admin** | https://localhost:3002 | Identity & Access Management |
| **Meta Service** | http://localhost:5001 | Metadaten-API |
| **Meta Service API Docs** | http://localhost:5001/swagger | Swagger-UI für Meta Service |
| **Generic Service** | http://localhost:5002 | Generische Daten-API |
| **Generic Service API Docs** | http://localhost:5002/swagger | Swagger-UI für Generic Service |
| **ML Service** | http://localhost:5003 | Machine Learning API |
| **ML Service API Docs** | http://localhost:5003/swagger | Swagger-UI für ML Service |
| **Reporting Service** | http://localhost:5004 | Dokumenten-/Report-API |
| **Reporting Service API Docs** | http://localhost:5004/swagger | Swagger-UI für Reporting Service |
| **Report Designer** | http://localhost:5004/designer | Report-Designer (Microfrontend) |
| **Document Viewer** | http://localhost:5004/viewer | Dokumentenviewer (Microfrontend) |
| **Storage Service** | http://localhost:5005 | Dateispeicher-API |
| **Storage Service API Docs** | http://localhost:5005/swagger | Swagger-UI für Storage Service |
| **MinIO Console** | http://localhost:9001 | Object Storage Management |
| **MailPit** | http://localhost:8025 | E-Mail-Entwicklungsserver |
| **PostgreSQL** | localhost:5432 | Datenbank |

## 👤 Standard-Anmeldedaten

### Ballware Web App (http://localhost:3000)
Die Standard-Benutzer werden automatisch beim ersten Start erstellt. Weitere Benutzer können über die Keycloak-Administration erstellt werden.

### Keycloak Admin (https://localhost:3002)
- **Benutzername**: `admin@ballware.local`
- **Passwort**: `ChangeMe2025!` (oder Ihr `KEYCLOAK_ADMIN_PASSWORD`)

### MinIO Console (http://localhost:9001)
- **Benutzername**: `admin@ballware.local`
- **Passwort**: `ChangeMe2025!` (oder Ihr `MINIO_ROOT_PASSWORD`)

### PostgreSQL (localhost:5432)
- **Benutzername**: `admin`
- **Passwort**: `ChangeMe2025!` (oder Ihr `DB_ADMIN_PASSWORD`)

## 🏗️ Architektur

Die Ballware-Plattform besteht aus folgenden Komponenten:

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

### Service-Beschreibungen:

- **Web Client**: Angular-Frontend für die Benutzeroberfläche
- **Keycloak**: OpenID Connect Identity Provider für Authentifizierung
- **Meta Service**: Verwaltet Anwendungsmetadaten und Konfigurationen
- **Generic Service**: Verwaltet dynamische Geschäftsdaten
- **Storage Service**: Datei- und Dokumentenverwaltung
- **ML Service**: Machine Learning und Datenanalyse
- **Reporting Service**: Berichte und Dokumentenerstellung
- **PostgreSQL**: Relationale Datenbank für alle Services
- **MinIO**: S3-kompatible Objektspeicherung

## 🔧 Troubleshooting

### Häufige Probleme:

**1. Service startet nicht / Port bereits belegt:**
```bash
# Überprüfen welche Prozesse die Ports verwenden
lsof -i :3000
lsof -i :5432

# Services stoppen und neu starten
docker compose down
docker compose up -d
```

**2. GitHub Authentication Fehler:**
```bash
# Überprüfen Sie Ihre .env Datei
cat .env | grep GITHUB

# Testen Sie Ihr PAT
curl -H "Authorization: token YOUR_GITHUB_PAT" https://api.github.com/user
```

**3. Database Connection Fehler:**
```bash
# PostgreSQL Logs überprüfen
docker compose logs postgres

# Database Status überprüfen
docker compose exec postgres pg_isready -U admin -d postgres
```

**4. Zertifikatsfehler (ERR_CERT_AUTHORITY_INVALID):**
- Siehe [TLS-Zertifikat vertrauen](#tls-zertifikat-vertrauen)
- Stellen Sie sicher, dass Sie https://localhost:3002 verwenden

**5. Services bauen nicht (Network errors):**
```bash
# Docker cache löschen
docker system prune -a

# Services einzeln bauen
docker compose build --no-cache
```

### Logs anzeigen:

```bash
# Alle Service-Logs
docker compose logs -f

# Spezifische Service-Logs
docker compose logs -f keycloak
docker compose logs -f postgres
docker compose logs -f app
```

### Services neu starten:

```bash
# Einzelnen Service neu starten
docker compose restart keycloak

# Alle Services neu starten
docker compose restart

# Service-Container neu bauen
docker compose build --no-cache keycloak
docker compose up -d keycloak
```

## ⚙️ Erweiterte Konfiguration

### Externe Keycloak-URL konfigurieren:

Wenn Sie Keycloak über eine externe Domain verwenden möchten:

```bash
# In .env hinzufügen
KEYCLOAK_REALM_BASE=https://ihr-keycloak-domain.com/realms/ballware
```

### Produktions-ähnliche Konfiguration:

Für eine produktions-ähnlichere Umgebung:

1. **Stärkere Passwörter setzen**:
```bash
# Generieren Sie sichere Passwörter
openssl rand -base64 32
```

2. **External Volumes verwenden**:
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

3. **Ressourcenlimits hinzufügen**:
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

### Entwicklungsmodus:

Für die Entwicklung mit lokalen Code-Änderungen:

```bash
# docker-compose.dev.yml erstellen für lokale Entwicklung
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d
```

## 📞 Support

Bei Problemen oder Fragen:

1. Überprüfen Sie die [Troubleshooting](#troubleshooting) Sektion
2. Schauen Sie in die Docker Compose Logs: `docker compose logs -f`
3. Öffnen Sie ein Issue im [ballware-docker-compose](https://github.com/ballware/ballware-docker-compose) Repository

## 📄 Lizenz

Dieses Projekt steht unter der MIT-Lizenz. Details finden Sie in der [LICENSE](LICENSE) Datei.

## 👤 Autor

**ballware Software & Consulting Frank Ballmeyer**  
Website: [https://www.ballware.de](https://www.ballware.de)

---

*Copyright (c) 2025 ballware Software & Consulting Frank Ballmeyer*
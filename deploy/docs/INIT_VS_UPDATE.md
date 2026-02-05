# 📖 Init vs Update

This project relies on a hybrid pipeline (GitHub Actions & Docker Compose) with two distinct modes.
Although the flow may look linear, `init` mode triggers specific mechanisms to automate infrastructure configuration.

## 🚀 Modes Overview

| Aspect             | `init` mode                                       | `update` mode                                |
|:-------------------|:--------------------------------------------------|:---------------------------------------------|
| **Goal**           | First installation or full reset.                 | Application update of the services.          |
| **Keycloak**       | Generates and imports the Realm (clients, URLs).  | Uses the existing database.                  |
| **Docker Compose** | Includes `docker-compose.overlay-init.yml`.       | Base + Proxy only.                           |
| **Build strategy** | Forces a rebuild of the Keycloak image.           | Builds only if the version is missing from the registry. |
⚠️ Running `init` on an already initialized environment may overwrite or invalidate authentication data.  
Always use `update` for normal deployments.
---

## 🛠 Keycloak subtlety: Realm rendering

Keycloak configuration is the most critical step because it must know the application's public URL at initialization time to handle redirects.

### 1. Build phase (GitHub Actions)
In `init` mode, the workflow does more than just check whether the image exists:
* **URL injection**: the `secrets.APP_URL` value is used to replace the `https://app.change.me` placeholder in the realm template.
* **Packaging**: the resulting file (`realm-import.json`) is placed in Keycloak's build directory.
* **Forced build**: the Keycloak Docker image is rebuilt with this configuration "baked in" to guarantee an immediate import.

### 2. Deployment phase (server)
The `deploy.sh` script assembles the Compose files via overlays:
* **Initialization overlay**: `docker-compose.overlay-init.yml` adds the `--import-realm` argument to Keycloak.
* **Startup behavior**: Keycloak detects the imported file. If the realm doesn't exist in the database yet, it is automatically created with the correct settings.

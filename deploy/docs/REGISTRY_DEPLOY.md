## Deploy ka-starter with GitHub Container Registry (ghcr.io)

Images are built in **GitHub Actions** and stored on **ghcr.io**.

### GitHub Actions configuration

To use the GitHub Actions pipelines, configure the following **secrets** in your repository:

**Settings → Secrets and variables → Actions → New repository secret**

| Secret            | Description                                                                      |
|-------------------|----------------------------------------------------------------------------------|
| `SSH_HOST`        | Server IP address or domain (e.g. `123.45.67.89`)                                |
| `SSH_USER`        | SSH user (e.g. `root`)                                                           |
| `SSH_PRIVATE_KEY` | SSH private key                                                                  |
| `SSH_HOST_PATH`   | project path on the server (e.g. `/opt/ka-starter`)                              |
| `REGISTRY_TOKEN`  | GitHub Personal Access Token with `read:packages` + `write:packages`  permission |
| `APP_URL`         | Public application URL used by Keycloak for redirects (init)                     |

### Initial setup

**1. Create a GitHub Personal Access Token**
- Settings → Developer settings → Personal access tokens → Tokens (classic)
- Generate new token
- Permissions: `read:packages` + `write:packages`
- Copy the token

**2. Create a secret in your repository :**
- Settings → Secrets and variables → Actions → New repository secret
- name : `REGISTRY_TOKEN` 
- value : paste the token there

`APP_URL` must match the public URL of your frontend (used by Keycloak during realm initialization).  
e.g. `https://myapp.com` or `https://app.mydomain.com`

### First installation

**1. Build and automatic setup**
```bash
GitHub → Actions → Initialize Registry Deployment → Run workflow
```
This pipeline:
- ✅ Copies the deployment scripts to the server
- ✅ Creates `.env` with the built versions and template values

**2. Configure and manual init**
```bash
# SSH into the server
ssh user@server
cd /opt/ka-starter # example project path

# Configure .env
nano .env  # Fill in your secrets (versions are already filled in)
```

### Initial deployment (with Keycloak realm import)
Once files copied and `.env` configured:
```bash
GitHub → Actions → Deploy (Registry Mode) → Run workflow → choose `init`
```

### Next deployments

**1. Update versions** (if needed)
```bash
# Bump a service version
echo "1.1.0" > ka-front/VERSION
git add ka-front/VERSION
git commit -m "chore: bump ka-front to 1.1.0"
git push
```

**2. Update `.env` on the server**

Via FTP or SSH, edit `/opt/ka-starter/.env`:
```bash
KA_FRONT_IMAGE=ghcr.io/franzk/ka-starter/ka-front:1.1.0
```

**3. Deploy**
```bash
GitHub → Actions → Deploy (Registry Mode) → Run workflow → choose `update`
```

### Rollback (Registry only)

```bash
# Edit .env with the old version
ssh user@server
cd /opt/ka-starter
nano .env
# KA_FRONT_IMAGE=ghcr.io/franzk/ka-starter/ka-front:1.0.0

GitHub → Actions → Deploy (Registry Mode) → Run workflow → choose `update`

```

---

## Troubleshooting

**Deploy but no changes**
→ Check that the image versions in `.env` match the versions defined in the `*/VERSION` files

**"unauthorized: authentication required"**
→ Run `docker login ghcr.io -u YOUR_USERNAME` again

**"image not found"**
→ Ensure the version in `.env` matches an image built on ghcr.io

→ Check logs: `docker compose logs -f`

---
## Init vs update difference

- **init**: First installation, imports the Keycloak realm (only once)
- **update**: Normal deployments, restarts updated services

⚠️ Never run `init` again on an environment that has already been initialized.
[INIT_VS_UPDATE.md](INIT_VS_UPDATE.md)

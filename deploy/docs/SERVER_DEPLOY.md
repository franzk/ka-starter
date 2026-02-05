## Build & deploy ka-starter directly on the server using SSH-based workflow

Images are built **directly on the server**.  
This workflow is intended for quick setups, early MVPs, or experimentation.
For production environments, the registry-based workflow is recommended.


### First installation

```bash
# 1. SSH into the server
ssh user@server
cd /opt/ka-starter # example project path

git clone https://github.com/franzk/ka-starter.git
 

# 2. Configure .env
cd ka-starter/deploy/deploy-bundle
cp .env.ssh.example .env
nano .env  # Fill in your secrets

# 3. Initial deployment (with Keycloak realm import)
chmod +x scripts/*
./scripts/deploy.sh ssh init
```

### Next deployments

```bash
ssh user@server
cd /opt/ka-starter # example project path
git pull
cd ka-starter/deploy/deploy-bundle
./scripts/deploy.sh ssh update
```

## Troubleshooting

**"Out of memory" during the build**
→ The server is short on RAM. Switch to Registry mode or increase RAM.

**Services don't start**
→ Check logs: `docker compose logs -f`

---
## Init vs update difference

- **init**: First installation, imports the Keycloak realm (only once)
- **update**: Normal deployments, restarts updated services

⚠️ Never run `init` again on an environment that has already been initialized.
[INIT_VS_UPDATE.md](INIT_VS_UPDATE.md)
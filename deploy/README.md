# Déploiement ka-starter sur VPS

## Prérequis

- Un VPS avec Docker et Docker Compose installés
- Accès SSH au VPS
- Un compte GitHub avec accès au dépôt ka-starter

## Configuration GitHub Actions

Pour utiliser les pipelines GitHub Actions, configurer les **secrets** suivants dans votre dépôt :

**Settings → Secrets and variables → Actions → New repository secret**

- `SSH_HOST` : adresse IP ou domaine du VPS (ex: `123.45.67.89`)
- `SSH_USER` : utilisateur SSH (ex: `root`)
- `SSH_PRIVATE_KEY` : clé privée SSH
- `SSH_HOST_PATH` : chemin du projet sur le VPS (ex: `/opt/ka-starter`)

## Modes de déploiement

Deux modes disponibles : **SSH** (simple) ou **Registry** (professionnel).

| Mode | Build | Rollback | Multi-env | Recommandé pour |
|------|-------|----------|-----------|-----------------|
| SSH | Sur VPS | Difficile | Complexe | MVP, dev rapide |
| Registry | GitHub Actions | Facile | Simple | Staging + Prod |

---

## Mode SSH

Les images sont buildées **directement sur le VPS**.

### Première installation

```bash
# 1. SSH sur le VPS
ssh user@vps
cd /opt/ka-starter # exemple de chemin du projet

# 2. Configurer .env
cp .env.ssh.example .env
nano .env  # Renseigner vos secrets

# 3. Déploiement initial (avec import Keycloak realm)
DEPLOY_MODE=ssh ./deploy/scripts/deploy.sh init
```

### Déploiements suivants

**Option A - Via pipeline GitHub :**
1. GitHub → **Actions** → **Deploy (SSH Mode)**
2. **Run workflow**

**Option B - Manuel :**
```bash
ssh user@vps
cd /opt/ka-starter # exemple de chemin du projet
git pull
DEPLOY_MODE=ssh ./deploy/scripts/deploy.sh update
```

---

## Mode Registry

Les images sont buildées dans **GitHub Actions** et stockées sur **ghcr.io**.

### Configuration initiale

**1. Créer un Personal Access Token GitHub**
- Settings → Developer settings → Personal access tokens → Tokens (classic)
- Generate new token
- Permissions : `read:packages`
- Copier le token

**2. Authentifier Docker sur le VPS**
```bash
ssh user@vps
docker login ghcr.io -u VOTRE_USERNAME_GITHUB
# Password: coller le token
```

### Première installation

**1. Build et setup automatique**
```bash
GitHub → Actions → Build Images (Registry) → Run workflow
```
Cette pipeline :
- ✅ Build toutes les images
- ✅ Push sur ghcr.io
- ✅ Copie les scripts de déploiement sur le VPS
- ✅ Crée `.env.example` avec les versions buildées

**2. Configuration et init manuel**
```bash
# SSH sur le VPS
ssh user@vps
cd /opt/ka-starter

# Configurer .env
cp .env.example .env
nano .env  # Renseigner vos secrets (les versions sont déjà renseignées)

# Déploiement initial (avec import Keycloak realm)
DEPLOY_MODE=registry ./deploy/scripts/deploy.sh init
```

### Déploiements suivants

**1. Modifier les versions** (si besoin)
```bash
# Bumper la version d'un service
echo "1.1.0" > ka-front/VERSION
git add ka-front/VERSION
git commit -m "chore: bump ka-front to 1.1.0"
git push
```

**2. Mettre à jour .env sur le VPS**

Via FTP ou SSH, modifier `/opt/ka-starter/.env` :
```bash
KA_FRONT_IMAGE=ghcr.io/franzk/ka-starter/ka-front:1.1.0
```

**3. Déployer**
```bash
GitHub → Actions → Deploy (Registry Mode) → Run workflow
```

### Rollback (Registry uniquement)

```bash
# Modifier .env avec l'ancienne version
ssh user@vps
cd /opt/ka-starter
nano .env
# KA_FRONT_IMAGE=ghcr.io/franzk/ka-starter/ka-front:1.0.0

# Redéployer
DEPLOY_MODE=registry ./deploy/scripts/deploy.sh update
```

---

## Troubleshooting

### Mode SSH

**"Out of memory" pendant le build**
→ VPS manque de RAM. Passer en mode Registry ou augmenter la RAM.

**Services ne démarrent pas**
→ `docker compose -f deploy/docker-compose.ssh.yml logs -f`

### Mode Registry

**"unauthorized: authentication required"**
→ Refaire `docker login ghcr.io -u VOTRE_USERNAME`

**"image not found"**
→ Vérifier que la version dans `.env` correspond à une image buildée sur ghcr.io

**Les deux modes**
→ Vérifier les logs : `docker compose logs -f`

---

## Différence init vs update

- **init** : Première installation, importe le realm Keycloak (une seule fois)
- **update** : Déploiements normaux, redémarre les services modifiés

⚠️ Ne jamais refaire `init` sur un environnement déjà initialisé.
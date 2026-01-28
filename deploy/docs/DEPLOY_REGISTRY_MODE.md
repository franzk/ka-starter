# 🎨 Mode Registry - Documentation

## 🎯 Principe

Les images Docker sont **buildées dans GitHub Actions**, poussées vers **ghcr.io** (GitHub Container Registry), puis **pullées** sur le VPS.

## ✅ Avantages

- ✅ Build dans le cloud (pas de charge sur VPS)
- ✅ Images immuables et versionnées
- ✅ Rollback instantané (changer version dans .env)
- ✅ Multi-environnements facile
- ✅ Traçabilité complète
- ✅ Déploiement rapide (pull vs build)

## ❌ Inconvénients

- ❌ Setup initial plus complexe
- ❌ Gestion des versions d'images
- ❌ Besoin de token ghcr.io sur VPS
- ❌ Modifier .env à chaque nouvelle version

## 📋 Configuration initiale

### 1. Secrets GitHub

Dans **Settings > Secrets and variables > Actions** :

- `SSH_HOST` : IP ou domaine du VPS
- `SSH_USER` : Utilisateur SSH
- `SSH_PRIVATE_KEY` : Clé SSH privée
- `SSH_HOST_PATH` : Chemin du projet (ex: `/opt/ka-starter`)

### 2. Authentification ghcr.io sur le VPS

#### 2.1 Créer un Personal Access Token (PAT)

1. GitHub → **Settings** → **Developer settings**
2. **Personal access tokens** → **Tokens (classic)**
3. **Generate new token (classic)**
4. Nom : `ka-starter-vps-pull`
5. Permissions : Cocher **read:packages**
6. **Generate token**
7. **Copier le token** (tu ne pourras plus le voir après)

#### 2.2 Login Docker sur le VPS

```bash
# SSH sur le VPS
ssh user@vps

# Login ghcr.io
docker login ghcr.io -u TON_USERNAME_GITHUB
# Password: coller le PAT

# Vérifier
docker pull ghcr.io/franzk/ka-starter/ka-front:1.0.0  # Test (si déjà pushé)
```

### 3. Structure sur le VPS

```bash
/opt/ka-starter/
├── .env                              # Variables d'env + versions images
├── deploy/
│   ├── docker-compose.registry.yml   # Compose avec image: ghcr.io/...
│   ├── docker-compose.overlay-*.yml
│   └── scripts/
│       ├── deploy.sh
│       └── lib.sh
```

**Note** : Le code source n'est **pas nécessaire** sur le VPS en mode Registry (seulement les configs).

### 4. Fichier .env sur le VPS

```bash
# ===================================
# VERSIONS DES IMAGES (ghcr.io)
# ===================================
JAVA_BASE_BUILDER_IMAGE=ghcr.io/franzk/ka-starter/java-base-builder:1.0.0
KA_FRONT_IMAGE=ghcr.io/franzk/ka-starter/ka-front:1.0.0
KA_GATEWAY_IMAGE=ghcr.io/franzk/ka-starter/ka-gateway:1.0.0
SERVICE_EXAMPLE_IMAGE=ghcr.io/franzk/ka-starter/service-example:1.0.0
KA_SMTP_BRIDGE_IMAGE=ghcr.io/franzk/ka-starter/ka-smtp-bridge:1.0.0
KA_MAILER_IMAGE=ghcr.io/franzk/ka-starter/ka-mailer:1.0.0
KA_KEYCLOAK_IMAGE=ghcr.io/franzk/ka-starter/ka-keycloak:1.0.0

# ===================================
# VARIABLES APPLICATIVES
# ===================================
KEYCLOAK_URL=https://auth.example.com
KEYCLOAK_ISSUER=https://auth.example.com/realms/ka-starter
KEYCLOAK_HOST=ka-keycloak:8080

VITE_KEYCLOAK_REALM=ka-starter
VITE_KEYCLOAK_CLIENT_ID=ka-front
VITE_API_URL=https://api.example.com

BACK_URL=http://service-example:8080
APP_URL=https://app.example.com

KC_DB_PASSWORD=change-me
KC_BOOTSTRAP_ADMIN_USERNAME=admin
KC_BOOTSTRAP_ADMIN_PASSWORD=change-me

SMTP_HOST=smtp.example.com
SMTP_PORT=587
SMTP_USERNAME=user@example.com
SMTP_PASSWORD=change-me
SMTP_AUTH=true
SMTP_SSL=true

MAILER_URL=http://ka-mailer:8080

PROJECT=ka-starter
```

### 5. Installer les pipelines

**Deux pipelines pour le mode Registry :**

1. **Build Images (Registry)** - Pour builder les images sans déployer
2. **Deploy (Registry Mode)** - Pour builder + déployer automatiquement

```bash
# Dans ton repo local
cp build-images-registry.yml .github/workflows/
cp deploy-registry.yml .github/workflows/
git add .github/workflows/
git commit -m "feat: add Registry workflows"
git push
```

### 6. Première installation (init)

⚠️ **Le mode `init` est manuel** (pas dans la pipeline) car il :
- Importe le realm Keycloak
- Configure l'environnement initial
- Ne se fait qu'une seule fois

**Processus :**

```bash
# 1. Builder les images (SANS déployer)
GitHub Actions → Build Images (Registry) → Run workflow

# 2. Attendre que les images soient buildées et pushées sur ghcr.io
# La pipeline affichera les versions buildées dans les logs

# 3. SSH sur le VPS
ssh user@vps
cd /opt/ka-starter

# 4. Vérifier que le code est bien présent
# (git clone si première fois, ou git pull)

# 5. Configurer .env avec les versions (copiées depuis les logs de la pipeline)
cp .env.registry.example .env
nano .env

# Exemple :
# JAVA_BASE_BUILDER_IMAGE=ghcr.io/franzk/ka-starter/java-base-builder:1.0.0
# KA_FRONT_IMAGE=ghcr.io/franzk/ka-starter/ka-front:1.0.0
# ...

# 6. Lancer le déploiement initial (avec import realm)
DEPLOY_MODE=registry ./deploy/scripts/deploy.sh init

# 7. Vérifier
docker compose -f deploy/docker-compose.registry.yml ps
```

**Après le init :** Utiliser la pipeline **Deploy (Registry Mode)** qui fera automatiquement les `update`.

## 🚀 Workflow de déploiement

### 1. Développer et bumper les versions

```bash
# Modifier le code
vim ka-front/src/App.vue

git add .
git commit -m "feat: nouvelle fonctionnalité"

# Bumper la version du service modifié
echo "1.1.0" > ka-front/VERSION

git add ka-front/VERSION
git commit -m "chore: bump ka-front to 1.1.0"
git push
```

### 2. Mettre à jour .env sur le VPS

**Via FTP** ou **SSH** :

```bash
# SSH sur le VPS
ssh user@vps
cd /opt/ka-starter
nano .env

# Modifier la version
# AVANT: KA_FRONT_IMAGE=ghcr.io/franzk/ka-starter/ka-front:1.0.0
# APRÈS: KA_FRONT_IMAGE=ghcr.io/franzk/ka-starter/ka-front:1.1.0
```

**OU via FTP** : Éditer `/opt/ka-starter/.env` directement

### 3. Lancer la pipeline

1. Aller sur GitHub → **Actions**
2. Sélectionner **Deploy (Registry Mode)**
3. Cliquer **Run workflow** → **Run workflow**

### 4. Ce que fait la pipeline

**Job 1 : build-and-push**
```bash
# Dans GitHub Actions
docker build -t ghcr.io/franzk/ka-starter/ka-front:1.1.0 ka-front
docker push ghcr.io/franzk/ka-starter/ka-front:1.1.0
# ... pour tous les services
```

**Job 2 : deploy**
```bash
# Sur le VPS via SSH
cd /opt/ka-starter
docker login ghcr.io
DEPLOY_MODE=registry ./deploy/scripts/deploy.sh update
```

Le script `deploy.sh` :
- Charge le `.env`
- Utilise `docker-compose.registry.yml`
- Exécute `docker compose pull` (télécharge les images)
- Exécute `docker compose up -d --force-recreate`

### 5. Vérifier

```bash
# SSH sur le VPS
ssh user@vps

cd /opt/ka-starter
docker compose -f deploy/docker-compose.registry.yml ps
docker images | grep ghcr.io
```

## 🔄 Rollback

Le rollback est **instantané** en mode Registry :

```bash
# SSH sur le VPS
cd /opt/ka-starter
nano .env

# Revenir à l'ancienne version
# KA_FRONT_IMAGE=ghcr.io/franzk/ka-starter/ka-front:1.0.0

# Redéployer
DEPLOY_MODE=registry ./deploy/scripts/deploy.sh update
```

✅ Les anciennes images sont toujours disponibles sur ghcr.io !

## 📝 Gestion des versions

### Convention de versionnage

Utiliser **semver** : `MAJOR.MINOR.PATCH`

- `MAJOR` : Breaking changes
- `MINOR` : Nouvelles features (rétrocompatibles)
- `PATCH` : Bug fixes

Exemples :
- `1.0.0` → `1.0.1` : Bug fix
- `1.0.1` → `1.1.0` : Nouvelle feature
- `1.1.0` → `2.0.0` : Breaking change

### Bumper les versions

```bash
# Bug fix
echo "1.0.1" > ka-front/VERSION

# Nouvelle feature
echo "1.1.0" > ka-gateway/VERSION

# Breaking change
echo "2.0.0" > ka-mailer/VERSION
```

### Voir les images disponibles

Sur ghcr.io :
1. Aller sur https://github.com/franzk?tab=packages
2. Cliquer sur le package (ex: `ka-front`)
3. Voir toutes les versions disponibles

## 🔧 Déploiement manuel (sans pipeline)

### Mode update (normal)

Si besoin de déployer manuellement une nouvelle version :

```bash
# 1. Modifier .env sur le VPS
ssh user@vps
cd /opt/ka-starter
nano .env
# Changer les versions

# 2. Redéployer
DEPLOY_MODE=registry ./deploy/scripts/deploy.sh update
```

### Mode init (première installation uniquement)

⚠️ **Le mode `init` ne se fait qu'une fois** lors de la première installation.

Il diffère du mode `update` car il :
- Importe le realm Keycloak (configuration SSO initiale)
- Configure l'environnement de base

**Quand faire un init ?**
- ✅ Première installation du projet
- ✅ Réinstallation complète (après suppression de la BDD)
- ❌ PAS pour les mises à jour normales (utiliser `update`)

**Processus init :**

```bash
# 1. S'assurer que les images sont déjà sur ghcr.io
# (lancer la pipeline Registry une première fois)

# 2. SSH sur le VPS
ssh user@vps
cd /opt/ka-starter

# 3. Configurer .env avec les bonnes versions
nano .env

# 4. Lancer le init
DEPLOY_MODE=registry ./deploy/scripts/deploy.sh init

# 5. Vérifier
docker compose -f deploy/docker-compose.registry.yml ps
```

**Différence init vs update :**
- `init` : Utilise `docker-compose.overlay-init.yml` → importe le realm Keycloak
- `update` : Redémarre juste les services avec les nouvelles versions

## 🌍 Multi-environnements

Mode Registry facilite le multi-env :

### Sur le VPS Staging

`.env.staging` :
```bash
KA_FRONT_IMAGE=ghcr.io/franzk/ka-starter/ka-front:1.1.0-rc
KEYCLOAK_URL=https://auth.staging.example.com
# ...
```

### Sur le VPS Production

`.env.prod` :
```bash
KA_FRONT_IMAGE=ghcr.io/franzk/ka-starter/ka-front:1.0.0
KEYCLOAK_URL=https://auth.example.com
# ...
```

## 🆘 Troubleshooting

### "unauthorized: authentication required"

→ Token ghcr.io expiré, refaire le login :
```bash
docker login ghcr.io -u TON_USERNAME
```

### "manifest unknown" / "image not found"

→ L'image n'existe pas sur ghcr.io. Vérifier :
1. Que la pipeline a bien pushé l'image
2. Que la version dans `.env` correspond bien

### "no space left on device"

→ Nettoyer les anciennes images :
```bash
docker image prune -a
```

### Pipeline échoue au push

→ Vérifier les permissions packages :
1. Settings → Actions → General
2. Workflow permissions → Read and write permissions

## 💡 Tips

- **Images publiques** : Par défaut, les images sur ghcr.io sont privées. Pour les rendre publiques : Package settings → Change visibility
- **Cache** : GitHub Actions cache les layers Docker pour accélérer les builds
- **Tester avant prod** : Déploie d'abord sur staging avec la nouvelle version
- **Monitoring** : Surveille l'espace disque et les images Docker
- **Backup .env** : Garde un backup du .env avec les versions stables

## 📊 Voir les images sur ghcr.io

```bash
# Lister les images disponibles
curl -H "Authorization: Bearer <PAT>" \
  https://ghcr.io/v2/franzk/ka-starter/ka-front/tags/list

# Ou via l'interface web
https://github.com/franzk?tab=packages
```

## 🔄 Migration depuis SSH

Si tu migres depuis le mode SSH :

1. Créer les fichiers VERSION
2. Lancer la pipeline Registry une première fois
3. Modifier le `.env` sur le VPS avec les variables d'images
4. Redéployer

Les données (volumes Docker) sont conservées !

# 📦 Mode SSH - Documentation

## 🎯 Principe

Le code est pullé sur le VPS depuis GitHub, puis les images Docker sont **buildées localement** sur le VPS.

## ✅ Avantages

- ✅ Setup simple et rapide
- ✅ Pas besoin de registry externe
- ✅ Pas de gestion de versions d'images
- ✅ Idéal pour itération rapide

## ❌ Inconvénients

- ❌ Build sur le VPS (consomme CPU/RAM)
- ❌ Temps de déploiement plus long
- ❌ Rollback complexe (git revert)
- ❌ Difficile pour multi-environnements

## 📋 Configuration initiale

### 1. Secrets GitHub

Dans **Settings > Secrets and variables > Actions** :

- `SSH_HOST` : IP ou domaine du VPS
- `SSH_USER` : Utilisateur SSH
- `SSH_PRIVATE_KEY` : Clé SSH privée
- `SSH_HOST_PATH` : Chemin du projet (ex: `/opt/ka-starter`)

### 2. Structure sur le VPS

```bash
/opt/ka-starter/
├── .env                          # Variables d'environnement
├── deploy/
│   ├── docker-compose.ssh.yml    # Compose avec build:
│   ├── docker-compose.overlay-*.yml
│   └── scripts/
│       ├── deploy.sh
│       └── lib.sh
├── infra/
│   └── base-java/
├── ka-front/
├── ka-gateway/
# ... autres services
```

### 3. Fichier .env sur le VPS

```bash
# Variables applicatives (PAS de variables d'images)
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

### 4. Installer la pipeline

```bash
# Dans ton repo local
cp deploy-ssh.yml .github/workflows/
git add .github/workflows/deploy-ssh.yml
git commit -m "feat: add SSH deploy pipeline"
git push
```

## 🚀 Workflow de déploiement

### 1. Développer

```bash
# Modifier le code
vim ka-front/src/App.vue

git add .
git commit -m "feat: nouvelle fonctionnalité"
git push
```

### 2. Lancer la pipeline

1. Aller sur GitHub → **Actions**
2. Sélectionner **Deploy (SSH Mode)**
3. Cliquer **Run workflow** → **Run workflow**

### 3. Ce que fait la pipeline

```bash
# Sur le VPS via SSH
cd /opt/ka-starter
git pull
chmod +x ./deploy/scripts/*
DEPLOY_MODE=ssh ./deploy/scripts/deploy.sh update
```

Le script `deploy.sh` :
- Charge le `.env`
- Utilise `docker-compose.ssh.yml`
- Exécute `docker compose up -d --build --force-recreate`

### 4. Vérifier

```bash
# SSH sur le VPS
ssh user@vps

cd /opt/ka-starter
docker compose -f deploy/docker-compose.ssh.yml ps
docker compose -f deploy/docker-compose.ssh.yml logs -f ka-front
```

## 🔧 Déploiement manuel (sans pipeline)

Si besoin de déployer manuellement :

```bash
# SSH sur le VPS
ssh user@vps
cd /opt/ka-starter

# Pull les dernières modifications
git pull

# Déployer
DEPLOY_MODE=ssh ./deploy/scripts/deploy.sh update
```

## 📝 Personnalisation

### Changer de branche déployée

Par défaut, la pipeline déploie la branche depuis laquelle elle est lancée.

Pour déployer une branche spécifique :
1. Aller dans **Actions**
2. Lancer le workflow depuis la branche voulue

### Déploiement initial (init)

Pour la toute première installation :

```bash
# SSH sur le VPS
cd /opt/ka-starter

# Créer le .env
cp .env.example .env
nano .env

# Premier déploiement (avec import realm Keycloak)
DEPLOY_MODE=ssh ./deploy/scripts/deploy.sh init
```

## 🆘 Troubleshooting

### "Build failed"

→ Vérifier les logs Docker :
```bash
docker compose -f deploy/docker-compose.ssh.yml logs
```

### "Out of memory"

→ VPS n'a pas assez de RAM pour builder. Options :
1. Augmenter la RAM du VPS
2. Ajouter du swap
3. **Passer au mode Registry** (build dans GitHub Actions)

### "Permission denied"

→ Vérifier les droits :
```bash
chmod +x ./deploy/scripts/*
```

### Rollback

En cas de problème, rollback Git :

```bash
# SSH sur le VPS
cd /opt/ka-starter

# Revenir au commit précédent
git log --oneline -5
git checkout <commit-hash>

# Redéployer
DEPLOY_MODE=ssh ./deploy/scripts/deploy.sh update
```

⚠️ **Attention** : Le rollback en mode SSH est moins fiable car il faut reconstruire les images.

## 📊 Monitoring

### Voir les services actifs

```bash
docker compose -f deploy/docker-compose.ssh.yml ps
```

### Voir les logs en temps réel

```bash
docker compose -f deploy/docker-compose.ssh.yml logs -f
```

### Voir l'utilisation des ressources

```bash
docker stats
```

## 🔄 Migration vers Registry

Quand tu voudras migrer vers le mode Registry :

1. Voir le guide `DEPLOY_MODES_GUIDE.md`
2. Suivre les instructions `DEPLOY_REGISTRY_MODE.md`
3. La migration est **non destructive** (les données sont conservées)

## 💡 Tips

- **Tester localement** : Utilise `docker-compose.ssh.yml` en local avant de push
- **Logs** : Active les logs Docker pour debug
- **Backup** : Fais un snapshot du VPS avant les gros changements
- **RAM** : Surveille la consommation pendant le build

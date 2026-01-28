# 🔄 Init vs Update - Explication

## 📋 Différence entre les deux modes

### Mode `init` (première installation)

**Quand l'utiliser :**
- ✅ Toute première installation du projet
- ✅ Réinstallation complète après suppression de la BDD
- ✅ Création d'un nouvel environnement (staging, prod)

**Ce qu'il fait en plus :**
- Import du **realm Keycloak** (configuration SSO)
- Utilise le fichier `docker-compose.overlay-init.yml`
- Génère le fichier `realm-import.json` à partir du template

**Commande :**
```bash
# Mode SSH
DEPLOY_MODE=ssh ./deploy/scripts/deploy.sh init

# Mode Registry
DEPLOY_MODE=registry ./deploy/scripts/deploy.sh init
```

### Mode `update` (déploiement normal)

**Quand l'utiliser :**
- ✅ Toutes les mises à jour après le premier `init`
- ✅ Déploiement de nouvelles versions
- ✅ Redémarrage des services

**Ce qu'il fait :**
- Pull les nouvelles images (Registry) ou rebuild (SSH)
- Redémarre les services modifiés
- **Ne touche PAS au realm Keycloak**

**Commande :**
```bash
# Mode SSH
DEPLOY_MODE=ssh ./deploy/scripts/deploy.sh update

# Mode Registry
DEPLOY_MODE=registry ./deploy/scripts/deploy.sh update
```

## 🎯 Workflow recommandé

### Première installation (une seule fois)

#### Mode SSH

```bash
# 1. SSH sur le VPS
ssh user@vps
cd /opt/ka-starter

# 2. Configurer .env
cp .env.ssh.example .env
nano .env

# 3. Init (build + import realm)
DEPLOY_MODE=ssh ./deploy/scripts/deploy.sh init
```

#### Mode Registry

**Pour la première installation (init) :**

```bash
# 1. Builder les images SANS déployer
GitHub Actions → Build Images (Registry) → Run workflow
# ↑ Cette pipeline build et push sur ghcr.io, mais ne déploie PAS

# 2. SSH sur le VPS
ssh user@vps
cd /opt/ka-starter

# 3. Configurer .env avec les versions buildées
# (copiées depuis les logs de la pipeline "Build Images")
cp .env.registry.example .env
nano .env

# 4. Init (pull + import realm)
DEPLOY_MODE=registry ./deploy/scripts/deploy.sh init
```

**Pour les déploiements suivants (update) :**

```bash
# Lancer la pipeline complète (build + deploy automatique)
GitHub Actions → Deploy (Registry Mode) → Run workflow
# ↑ Cette pipeline build, push ET déploie en mode "update"
```

**Pourquoi deux pipelines ?**
- **Build Images (Registry)** : Pour le premier build (sans deploy)
- **Deploy (Registry Mode)** : Pour tous les déploiements suivants (build + deploy)

### Déploiements suivants (tous les autres)

#### Mode SSH

```bash
# Lancer la pipeline
GitHub Actions → Deploy (SSH Mode) → Run workflow
```

La pipeline fait automatiquement un `update`.

#### Mode Registry

```bash
# 1. Modifier .env sur le VPS avec nouvelles versions

# 2. Lancer la pipeline
GitHub Actions → Deploy (Registry Mode) → Run workflow
```

La pipeline fait automatiquement un `update`.

## 🔍 Comment savoir si j'ai déjà fait un init ?

### Vérifier si Keycloak a un realm importé

```bash
# SSH sur le VPS
docker compose -f deploy/docker-compose.registry.yml exec ka-keycloak \
  /opt/keycloak/bin/kcadm.sh get realms --no-config --server http://localhost:8080 \
  --realm master --user admin --password <ADMIN_PASSWORD>
```

Si tu vois le realm `ka-starter`, alors le `init` a déjà été fait.

### Vérifier les volumes Docker

```bash
docker volume ls | grep keycloak
```

Si le volume `ka_keycloak_pgdata` existe et n'est pas vide, alors le `init` a été fait.

## ⚠️ Points d'attention

### Ne PAS faire init plusieurs fois

Si tu refais un `init` sur un environnement déjà initialisé :
- ⚠️ Le realm sera réimporté (peut écraser des modifs manuelles)
- ⚠️ Les données utilisateurs seront conservées (volume DB)

### Cas d'usage : Réinitialiser complètement

Si tu veux vraiment repartir de zéro :

```bash
# 1. Arrêter et supprimer tout
docker compose -f deploy/docker-compose.registry.yml down -v

# 2. Supprimer les volumes (⚠️ PERTE DE DONNÉES)
docker volume rm ka_keycloak_pgdata

# 3. Refaire un init
DEPLOY_MODE=registry ./deploy/scripts/deploy.sh init
```

## 📝 Résumé

| Action | Commande | Quand | Fréquence |
|--------|----------|-------|-----------|
| **Première installation** | `deploy.sh init` | Setup initial | 1 fois |
| **Mise à jour** | `deploy.sh update` | Déploiement | À chaque fois |
| **Réinitialisation** | `down -v` + `init` | Problème majeur | Très rare |

## 💡 Tips

- **En cas de doute** : Utilise `update`, c'est plus sûr
- **Test local** : Utilise `init` pour créer un environnement de dev local
- **Multi-env** : Fais un `init` pour chaque environnement (dev, staging, prod)
- **Documentation** : Note quelque part la date du dernier `init` pour chaque environnement

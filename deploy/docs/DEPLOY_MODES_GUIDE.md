# 🚀 Guide de déploiement - Deux modes disponibles

## 📊 Comparaison des modes

| Critère | Mode SSH | Mode Registry |
|---------|----------|---------------|
| **Build** | Sur le VPS | Dans GitHub Actions |
| **Images** | Locales | ghcr.io (immuables) |
| **Ressources VPS** | Moyennes/Élevées | Faibles |
| **Setup initial** | Simple | Moyen (token ghcr.io) |
| **Rollback** | Difficile (git revert) | Facile (changer version) |
| **Multi-env** | Complexe | Simple |
| **Traçabilité** | Moyenne | Élevée |
| **Temps de deploy** | Moyen/Long (build) | Rapide (pull) |

## 🎯 Quel mode choisir ?

### ✅ Mode SSH - Recommandé si :

- Tu as **un seul environnement** (prod uniquement)
- Ton VPS a **assez de ressources** pour builder (CPU, RAM)
- Tu veux la **simplicité** de setup
- Tu es en **phase de développement rapide** (itérations fréquentes)
- Tu n'as **pas besoin de rollback** rapide

**Exemple de cas d'usage :**
> "Je développe mon MVP sur mon VPS perso avec 4GB RAM, je push souvent, je veux juste que ça déploie automatiquement."

### ✅ Mode Registry - Recommandé si :

- Tu as **plusieurs environnements** (dev, staging, prod)
- Ton VPS a **peu de ressources** (1-2GB RAM)
- Tu veux des **images immuables et versionnées**
- Tu veux pouvoir **rollback facilement**
- Tu veux **séparer build et runtime**
- Tu prévois de **scaler** (plusieurs VPS)

**Exemple de cas d'usage :**
> "J'ai un VPS prod 2GB RAM et un VPS staging. Je veux pouvoir tester une version sur staging puis la déployer sur prod, et rollback facilement si problème."

## 🔄 Workflows comparés

### Mode SSH

```
┌─────────────┐
│  Dev local  │
└──────┬──────┘
       │ git push
       ▼
┌─────────────┐
│   GitHub    │
└──────┬──────┘
       │ trigger pipeline
       ▼
┌─────────────┐
│     VPS     │◄─── git pull
│             │◄─── docker compose build
│             │◄─── docker compose up
└─────────────┘
```

**Commandes :**
```bash
# Dev
git add . && git commit -m "feat: ma feature"
git push

# Pipeline GitHub
# → SSH sur VPS
# → git pull
# → docker compose up --build
```

### Mode Registry

```
┌─────────────┐
│  Dev local  │
│  + VERSION  │
└──────┬──────┘
       │ git push
       ▼
┌─────────────┐
│   GitHub    │
│   Actions   │──┐
└─────────────┘  │ build all
                 │ push ghcr.io
                 │
       ┌─────────┘
       ▼
┌─────────────┐
│   ghcr.io   │
└──────┬──────┘
       │
       │ docker pull
       ▼
┌─────────────┐
│     VPS     │◄─── SSH deploy
│   (.env)    │◄─── docker compose pull
│             │◄─── docker compose up
└─────────────┘
```

**Commandes :**
```bash
# Dev
git add . && git commit -m "feat: ma feature"
echo "1.1.0" > ka-front/VERSION
git add . && git commit -m "chore: bump version"
git push

# Modifier .env sur VPS (FTP)
# JAVA_BASE_BUILDER_IMAGE=ghcr.io/.../java-base-builder:1.0.0
# KA_FRONT_IMAGE=ghcr.io/.../ka-front:1.1.0
# ...

# Pipeline GitHub
# → Build all services
# → Push to ghcr.io
# → SSH sur VPS
# → docker compose pull
# → docker compose up
```

## 📁 Structure des fichiers

### Mode SSH

```
deploy/
├── docker-compose.ssh.yml       # Compose avec build:
├── docker-compose.overlay-*.yml # Overlays (proxy, init)
└── scripts/
    ├── deploy.sh                # DEPLOY_MODE=ssh
    └── lib.sh

.github/workflows/
└── deploy-ssh.yml               # Pipeline SSH
```

**Sur le VPS** : `.env` (sans variables d'images)

### Mode Registry

```
deploy/
├── docker-compose.registry.yml  # Compose avec image: ghcr.io/...
├── docker-compose.overlay-*.yml # Overlays (proxy, init)
└── scripts/
    ├── deploy.sh                # DEPLOY_MODE=registry
    └── lib.sh

.github/workflows/
└── deploy-registry.yml          # Pipeline Registry

infra/base-java/VERSION
ka-front/VERSION
ka-gateway/VERSION
# ... autres VERSION
```

**Sur le VPS** : `.env` (avec variables d'images)

## 🔀 Basculer d'un mode à l'autre

### SSH → Registry

1. Créer tous les fichiers `VERSION`
2. Installer `docker-compose.registry.yml`
3. Créer `.env` avec les variables d'images
4. Faire `docker login ghcr.io` sur le VPS
5. Installer `deploy-registry.yml`
6. Lancer la pipeline Registry

### Registry → SSH

1. Installer `docker-compose.ssh.yml`
2. Nettoyer les variables d'images du `.env`
3. Installer `deploy-ssh.yml`
4. Lancer la pipeline SSH

## 🎓 Recommandation pour ka-starter

Comme c'est un **projet starter pour MVP**, je recommande :

### Phase 1 : Démarrage (0-3 mois)
→ **Mode SSH** : Simple, rapide à setup, itérations rapides

### Phase 2 : Stabilisation (3-6 mois)
→ **Mode Registry** : Plus professionnel, rollback facile, multi-env

### Phase 3 : Production (6+ mois)
→ **Mode Registry + CD avancé** : Ajouter tests, staging, monitoring

## 📚 Documentation détaillée

- **Mode SSH** : Voir `DEPLOY_SSH_MODE.md`
- **Mode Registry** : Voir `DEPLOY_REGISTRY_MODE.md`

## 🆘 Support

**Mode SSH** : Plus simple, moins de points de friction
**Mode Registry** : Plus de setup initial, mais plus flexible ensuite

En cas de doute, commence avec **Mode SSH** et migre vers **Registry** quand tu en as besoin.

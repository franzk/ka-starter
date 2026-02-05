# Using ka-starter as a boilerplate

This document describes how to reuse ka-starter as a starting point
for your own project.

The goal is to keep the core infrastructure and architecture,
while replacing the example services with your own application logic.

---

## 1. Clone the repository

```bash
git clone https://github.com/franzk/ka-starter.git my-project
cd my-project
```

(Optional, but recommended)

```bash
git remote remove origin
git remote add origin git@github.com:you/my-project.git
```

---

## 2. Rename the project and services

Search and replace the `ka-` prefix across the repository:

- Docker service names
- image names
- container names
- folder names (optional)

Typical files to update:
- docker-compose*.yml
- .env.example
- deployment scripts
- GitHub Actions workflows

> The `ka-` prefix is only a convention and can be fully customized.

---

## 3. Replace example services

ka-starter includes example backend services for demonstration purposes.

You can:
- remove the example service entirely
- or keep it as a reference and rename it

Typical steps:
- delete the example module
- remove it from Docker Compose
- update the gateway routing if needed

---

## 5. Add your own services

To add a new backend service:
- create a new Spring Boot module (or any other stack)
- expose it only on the internal Docker network
- route requests through the API gateway

The gateway should remain the single entry point.

---

## 6. Authentication and security model

Authentication is handled by Keycloak (OIDC).

Key principles:
- the frontend authenticates users via Keycloak
- access tokens are sent to the gateway
- the gateway validates tokens and forwards requests
- backend services trust the gateway

You are encouraged to adapt:
- realms
- clients
- roles
- token claims

But the trust boundaries should remain explicit.

---

## 7. Deployment

Once adapted, you can deploy your project using:
- registry-based workflow (recommended)
- SSH-based workflow

Refer to:
- deploy/docs/REGISTRY_DEPLOY.md
- deploy/docs/SERVER_DEPLOY.md

The init / update distinction still applies.

---

## 8. What ka-starter does NOT enforce

ka-starter does not impose:
- a UI framework beyond the provided example
- a specific backend business architecture
- a database for application data
- Kubernetes or cloud-specific tooling

It provides infrastructure, not product decisions.

---

## Final note

ka-starter is intentionally opinionated.
It is meant to be adapted, not abstracted.

If you find yourself fighting the architecture,
it is probably not the right tool for your use case.

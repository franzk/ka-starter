# Local development

Local development is intended for feature development and debugging.
Services can be run independently, depending on what you are working on.

## Infrastructure services

Keycloak, PostgreSQL, MailHog, SMTP bridge:

```bash
cd dev
docker compose up
```

## Frontend (SPA)

```bash
cd ka-front
pnpm install
pnpm dev
```

## Backend services

Gateway, backend services, mailer (Spring Boot):

```bash
# From any Spring Boot service directory:
./gradlew bootRun
```

You can mix and match these commands depending on which part of the stack
you want to work on.

### Check it

Once everything is running, you can:
- access the frontend at http://localhost:5173
- create an account
- open MailHog at http://localhost:5125 to find the verification email
- click the verification link
- log in and explore the app

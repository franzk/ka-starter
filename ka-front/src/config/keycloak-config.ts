interface AppConfig {
  keycloakUrl?: string
  keycloakRealm?: string
  keycloakClientId?: string
  apiUrl?: string
}

declare global {
  interface Window {
    APP_CONFIG?: AppConfig
  }
}

export default {
  url: window.APP_CONFIG?.keycloakUrl || import.meta.env.VITE_KEYCLOAK_URL,
  realm: window.APP_CONFIG?.keycloakRealm || import.meta.env.VITE_KEYCLOAK_REALM,
  clientId: window.APP_CONFIG?.keycloakClientId || import.meta.env.VITE_KEYCLOAK_CLIENT_ID,
}

import './assets/stylesheets/styles.scss'

import { createApp } from 'vue'
import { createPinia } from 'pinia'

import App from './App.vue'
import router from './router'
import { useAuthStore } from './store/authStore'

const app = createApp(App)

app.use(createPinia())
app.use(router)

const authStore = useAuthStore()
authStore.initKeycloak().then(() => {
  if (authStore.isAuthenticated) {
    app.mount('#app')
  } else {
    console.error('Authentication failed')
  }
})

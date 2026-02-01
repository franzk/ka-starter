import axios from 'axios'
import { useAuthStore } from '@/store/authStore'

const api = axios.create()


api.interceptors.request.use((config) => {
  // 1. On ajoute le token JWT dans les headers si on en a un
  const authStore = useAuthStore()
  const token = authStore.token
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }

  // 2. On force la baseURL dynamiquement depuis window.APP_CONFIG
  // On s'assure de prendre la valeur la plus fraîche
  const runtimeUrl = window.APP_CONFIG?.apiUrl

  if (runtimeUrl) {
    config.baseURL = runtimeUrl
  } else {
    console.error('❌ Runtime API URL is missing in window.APP_CONFIG')
  }

  return config
})

export default api

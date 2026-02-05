import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'
import SomethingView from '@/views/SomethingView.vue'
import MeView from '@/views/MeView.vue'

const routes: Array<RouteRecordRaw> = [
  { path: '/', component: SomethingView, name: 'something' },
  { path: '/me', component: MeView, name: 'me' },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

router.beforeEach(async (to, from, next) => {
  next()
})

export default router

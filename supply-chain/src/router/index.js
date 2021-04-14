import Vue from 'vue'
import VueRouter from 'vue-router'
import Home from '../pages/Home'

Vue.use(VueRouter)

const routes = [
  {
    path: '/',
    name: 'Home',
    component: Home
  },
  {
    path: '/purchases',
    name: 'Purchases',
    component: () => import(/* webpackChunkName: "Purchases" */ '@/pages/Purchases.vue')
  },
  {
    path: '/profile',
    name: 'Profile',
    component: () => import(/* webpackChunkName: "Profile" */ '@/pages/Profile.vue')
  },
  {
    path: '/create-order',
    name: 'CreateOrder',
    component: () => import(/* webpackChunkName: "CreateOrder" */ '@/pages/CreateOrder.vue')
  }
]

const router = new VueRouter({
  mode: 'history',
  base: process.env.BASE_URL,
  routes
})

export default router

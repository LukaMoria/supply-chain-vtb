<template>
  <q-layout view="lHh Lpr lFf">
    <q-header elevated class="glossy">
      <q-toolbar>
        <q-btn
          flat
          dense
          round
          @click="leftDrawerOpen = !leftDrawerOpen"
          aria-label="Menu"
          icon="menu"
        />

        <q-toolbar-title>
          VMarket
        </q-toolbar-title>

        <div>version: 0.0.1</div>
      </q-toolbar>
    </q-header>

    <left-menu :leftMenuDrawer="leftDrawerOpen" @input="setValue" />

    <q-page-container>
      <router-view />
    </q-page-container>
  </q-layout>
</template>

<script>
import leftMenu from '@/components/layout/leftMenu'

export default {
  name: 'LayoutDefault',

  components: {
    leftMenu
  },

  data () {
    return {
      leftDrawerOpen: false
    }
  },

  methods: {
    setValue(val) {
      this.leftDrawerOpen = val
    }
  }
}
</script>

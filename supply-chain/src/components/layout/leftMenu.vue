<template>
    <q-drawer
      :value="leftMenuDrawer"
      @input="(value) => $emit('input', value)"
      show-if-above
      bordered
      content-class="bg-grey-2"
    >
      <q-list>
        <q-item-label header class="label">Меню</q-item-label>
        <q-item v-for="(item,index) in links" :key="index" :to="item.href" clickable>
          <q-item-section avatar>
            <q-icon :name="item.icon" />
          </q-item-section>
          <q-item-section class="label">
            <q-item-label>{{ item.name }}</q-item-label>
          </q-item-section>
        </q-item>
      </q-list>
    </q-drawer>
</template>

<script>
export default {
  name:'Menu',
  props: {
    leftMenuDrawer: {
      type: Boolean,
      required: true
    }
  },
  data() {
    return {
      links: [
        { href: '/profile', name: 'Мой профиль', icon: 'face' },
        { href: '/offers', name: 'Предложения', icon: 'shop'},
        { href: '/purchases', name: 'Мои покупки', icon: 'cases'}
      ]
    }
  }
}
</script>

<style scoped>
  .label {
    font-size: 1rem;
    font-weight: 600;
  }
</style>
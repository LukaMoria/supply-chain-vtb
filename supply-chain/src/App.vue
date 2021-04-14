<template>
  <div id="app">
    <button @click="createOffer">createOffer</button>
  </div>
</template>

<script>
import instance from './contracts/marketplaceBoxInstance'

export default {
  name: 'App',
  components: {},
  async mounted() {
    console.log(instance)
    const res = await instance.methods.returnAllOffers().call({from: '0x06221c24fBa452c2a2716F9Ec705fd001536296a'})
    console.log(res)
  },
  methods:{
    async createOffer() {
      const res = await instance.methods.createOffer('test', 250, 'qweqwe', 150).send({from: '0x06221c24fBa452c2a2716F9Ec705fd001536296a'})
      console.log(res)
      const res2 = await instance.methods.returnAllOffers().send({from: '0x06221c24fBa452c2a2716F9Ec705fd001536296a'})
      console.log(res2)
    }
  }
}
</script>

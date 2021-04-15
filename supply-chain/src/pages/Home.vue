<template>
  <div>
    <offer-card
      :style="{'max-width': '400px'}"
      v-for="(item, index) in offers" 
      :key="index"
      :offer="item"
    />
  </div>
</template>

<script>
import { createContract, address } from '../contracts/offer'
import OfferCard from '../components/Card'

export default {
  name: 'Home',
  components: {
    OfferCard
  },

  data () {
    return {
      offers: []
    }
  },

  async created() {
    const contract = createContract(address)
    const res = await contract.methods.returnAllOffers().call({from: '0x06221c24fBa452c2a2716F9Ec705fd001536296a'})
    this.offers = res
  }
}
</script>

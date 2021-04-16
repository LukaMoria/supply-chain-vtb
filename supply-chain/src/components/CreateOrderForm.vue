<template>
  <div class="q-pa-md" style="display:flex; justify-content:center">

    <q-form
      @submit="onSubmit"
      @reset="onReset"
      class="q-gutter-md"
      style="width:100%"
    >
      <q-input
        filled
        v-model="name"
        label="Название компании"
        hint="Название компании"
        lazy-rules
        :rules="[ val => val && val.length > 0 || 'Please type something']"
      ></q-input>

      <q-select :options="typeOfVacineOptions" filled label="Тип вакцины" v-model="typeOfVacine" hint="Тип вакцины"/>

      <q-input
        filled
        v-model="amount"
        label="Количество"
        hint="Количество шт."
        lazy-rules
        :rules="[ val => val && val.length > 0 && Number(val) > 0 || 'Число должно быть больше 0']"
      ></q-input>

      <q-input
        filled
        v-model="finalPrice"
        label="Цена"
        hint="Цена за все предложение"
        lazy-rules
        :rules="[ val => val && val.length > 0 && Number(val) > 0 || 'Число должно быть больше 0']"
      ></q-input>

      <q-select :options="currencies" filled label="Валюта" v-model="currency" hint="Тип валюты"/>

      <q-input
        filled
        v-model="seller"
        label="Кошелек"
        hint="Номер кошелька продавца"
        lazy-rules
        :rules="[ val => val && val.length > 0 || 'Please type something']"
      ></q-input>

      <q-toggle v-model="accept" label="Я принимаю условия использования"></q-toggle>

      <div>
        <q-btn label="Submit" type="submit" color="primary" :disabled="isSubmitDisabled"></q-btn>
        <q-btn label="Reset" type="reset" color="primary" flat class="q-ml-sm"></q-btn>
      </div>
    </q-form>

  </div>
</template>

<script>
import { createContract, address } from '../contracts/offer'
import { v4 as uuidv4 } from 'uuid';

export default {
  name: 'CreateOrderForm',
  data() {
    return {
      name: null,
      typeOfVacineOptions: [
        {
        label: 'Спутник V',
        value: 'sputnik V'
        },
        {
          label: 'Эпивак',
          value: 'Epivac'
        },
        {
          label: 'Ковивак',
          value: 'kovivac'
        }
      ],
      currencies: [ {label: 'RUB', value: 0}, {label: 'USD', value: 1}, {label: 'EUR', value: 2} ],
      amount: null,
      typeOfVacine: null,
      accept: false,
      seller: '0x06221c24fBa452c2a2716F9Ec705fd001536296a', //hardcode
      finalPrice: null,
      currency: null
    }
  },
  computed: {
    isSubmitDisabled() {
      return !this.name && !this.amount && !this.typeOfVacine && !this.accept
    }
  },
  methods: {
    async onSubmit () {
      const contract = createContract(address)
      console.log(contract)
      const uuid = uuidv4(); // ⇨ '9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d'
      const res = await contract.methods.createOffer(uuid, this.name, this.typeOfVacine.value, this.finalPrice, this.amount, this.currency.value, this.seller)
        .send({from: this.seller})
      console.log(res)
    },

    onReset () {
      this.name = null
      this.amount = null
      this.accept = false
      this.seller  = null
      this.finalPrice = null
      this.typeOfVacine = null
    }
  }
}
</script>
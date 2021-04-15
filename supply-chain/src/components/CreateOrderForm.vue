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

      <q-input
        filled
        v-model="buyer"
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
import { createContract, data } from '../contracts/offer'

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
      amount: null,
      typeOfVacine: null,
      accept: false,
      buyer: null,
      finalPrice: null
    }
  },
  computed: {
    isSubmitDisabled() {
      return !this.name && !this.amount && !this.typeOfVacine && !this.accept
    }
  },
  methods: {
    async onSubmit () {
      const contract = createContract('')
      console.log(contract)
      const shadow = await contract.deploy({data, arguments: []})
      console.log(data)
      const deployedContract = await shadow.send()
      console.log(deployedContract)
    },

    onReset () {
      this.name = null
      this.amount = null
      this.accept = false
      this.typeOfVacine = null
    }
  }
}
</script>
<template>
  <q-card class="my-card">
    <q-img :src="this.images[offer[2]] ? this.images[offer[2]].img : 'https://s0.rbk.ru/v6_top_pics/media/img/5/83/756041016842835.jpg'" />
    <q-card-section>
      <q-btn
        fab
        color="primary"
        icon="place"
        class="absolute"
        style="top: 0; right: 12px; transform: translateY(-50%);"
      ></q-btn>

      <div class="row no-wrap items-center">
        <div class="col text-h6 ellipsis">
          {{ this.images[offer[2]] ? this.images[offer[2]].name : 'Вакцина' }}
        </div>
        <div class="col-auto text-grey text-caption q-pt-md row no-wrap items-center">
          <q-icon name="place" />
          163 km
        </div>
      </div>

      <q-rating v-model="stars" :max="5" size="32px" />
    </q-card-section>

    <q-card-section class="q-pt-none">
      <div class="text-subtitle1">
          {{`${offer[4]}$ ・ ${offer[3]} шт. ${offer[1]}`}}
      </div>
      <div class="text-caption text-grey">
          
      </div>
    </q-card-section>

    <q-separator></q-separator>

    <q-card-actions>
        <q-btn v-show="!isInputOpen" flat color="primary" @click="isInputOpen = true">
          Зарезервировать
        </q-btn>
        <q-input
          :style="{'min-width': '100%'}"
          v-show="isInputOpen"
          filled
          v-model="buyer"
          label="Адрес кошелька"
          lazy-rules
          :rules="[ val => val && val.length > 0 || 'Please type something']"
        />
        <q-btn v-show="isInputOpen" flat color="primary" @click="createESM">
          Открыть сделку
        </q-btn>
    </q-card-actions>
  </q-card>
</template>

<script>

export default {
  name: 'Card',
  props: {
    offer: {
      type: Array,
      required: true
    }
  },
  data() {
    return {
      buyer: null,
      isInputOpen: false,
      stars: 5,
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
      images: {
        'sputnik V': {
            img: 'https://gdb.rferl.org/c14b9059-cb02-47da-9afc-7f518419372d_w1200_r1.jpg',
            name: 'Спутник V'
        },
        'Epivac': {
            img: 'https://s0.rbk.ru/v6_top_pics/media/img/6/91/755995703153916.jpg',
            name: 'ЭпиВакКорона'
        },
        'kovivac': {
            img: 'http://cdn.iz.ru/sites/default/files/styles/900x506/public/news-2021-02/TASS_44414013_1.jpg?itok=P7ZEJWnX',
            name: 'Ковивак'
        }
      }
    }
  },
  methods: {
    createESM() {
      console.log('Сделка открыта!')
    }
  }
}
</script>

<style scoped>

</style>
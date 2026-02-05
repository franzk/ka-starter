<template>
  <div class="something-view">
    <SimpleCard class="something-card">
      <p class="something-message">{{ something?.message }}</p>
      <p class="something-date">{{ dayjs(something?.date).format('YYYY-MM-DD HH:mm:ss') }}</p>
      <p v-if="error">{{ error }}</p>
    </SimpleCard>
  </div>
</template>

<script setup lang="ts">
import SimpleCard from '@/components/SimpleCard.vue'
import api from '@/config/axios'
import type { Something } from '@/domain/Something'
import { ref } from 'vue'
import dayjs from 'dayjs'

const something = ref<Something>()
const error = ref<string>()

api
  .get('/something')
  .then((response) => (something.value = response.data))
  .catch((error) => (error.value = 'Error fetching data:' + error))
</script>

<style scoped lang="scss">
.something-view {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: $spacing-xl;
}

.something-card {
  display: flex;
  flex-direction: column;
}

.something-message {
  flex: 1;
  display: flex;
  justify-content: center;
  font-size: 1.2rem;
  font-weight: 500;
  padding: $spacing-xxl;
}

.something-date {
  text-align: right;
  font-size: 0.875rem;
  color: #888;
  padding-right: $spacing-l;
  margin: 0;
}
</style>

<template>
  <TheHeader />
  <main>
    <router-view />
  </main>
  <!-- Footer here -->
</template>

<script setup lang="ts">
import TheHeader from '@/components/TheHeader.vue'
</script>

<style scoped lang="scss">
main {
  flex: 1;
  display: flex;
  flex-direction: column;
  max-width: 100vw;
}
</style>

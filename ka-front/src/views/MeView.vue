<template>
  <div class="me-view">
    <SimpleCard class="profile-card">
      <h1 class="profile-title">Welcome back, {{ me?.name }} !</h1>
      <div class="profile-details">
        <div class="detail">
          <span class="label">Name:</span>
          <span class="value">{{ me?.name }}</span>
        </div>
        <div class="detail">
          <span class="label">Email:</span>
          <span class="value">{{ me?.email }}</span>
        </div>
      </div>
    </SimpleCard>
  </div>
</template>

<script setup lang="ts">
import SimpleCard from '@/components/SimpleCard.vue'
import { useAuthStore } from '@/store/authStore'

const authStore = useAuthStore()
const me = authStore.me
</script>

<style scoped lang="scss">
.me-view {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: $spacing-xxl;
}

.profile-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: $spacing-xxl;
  gap: $spacing-xl;
}

.profile-title {
  text-align: center;
  margin: 0 0 $spacing-xl 0;
  color: $color-primary;
  letter-spacing: 0.01em;
  inline-size: 100%;
  overflow-wrap: break-word;
}

.profile-details {
  display: flex;
  flex-direction: column;
  gap: $spacing-l;
  width: 100%;
  inline-size: 100%;
  overflow-wrap: break-word;
}

.detail {
  display: flex;
  align-items: center;
  justify-content: space-between;

  flex-wrap: wrap;

  padding: $spacing-m $spacing-l;
  border-radius: $border-radius-m;

  background:
    linear-gradient(180deg, rgba(255, 255, 255, 0.04), rgba(255, 255, 255, 0.02)), #1f2430;
  border: 1px solid #2a3647;
  box-shadow: 0 6px 18px rgba(0, 0, 0, 0.35);

  transition:
    background 0.2s ease,
    transform 0.15s ease,
    box-shadow 0.15s ease;
}

.detail:hover {
  background: #242a36;
  transform: translateY(-1px);
  box-shadow: 0 12px 28px rgba(0, 0, 0, 0.4);
}

.detail .label {
  font-weight: 600;
  color: $color-primary;
}

.detail .value {
  flex: 1;
  width: 100%;
  overflow-wrap: break-word;
  text-align: right;
  color: $color-accent;
}
</style>

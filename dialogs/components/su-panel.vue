<template>
  <div class="su-panel">
    <slot></slot>
  </div>
</template>

<script lang="ts">
import Vue from "vue";
export default Vue.extend({
  name: 'su-panel'
})
</script>

<style>
.su-panel {
  padding: 1rem;
}
</style>

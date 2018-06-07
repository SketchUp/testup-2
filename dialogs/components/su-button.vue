<template>
  <div class="su-button">
    <slot></slot>
  </div>
</template>

<script lang="ts">
import Vue from "vue";
export default Vue.extend({
  name: 'su-button'
})
</script>

<style>
.su-button {
  padding: 1rem;
}
.su-button:hover {
  background: #ccc;
}
</style>

<template>
  <button class="su-button">
    <slot></slot>
  </button>
</template>

<script lang="ts">
import Vue from "vue";
export default Vue.extend({
  name: 'su-button'
})
</script>

<style>
.su-button {
  display: inline-block;
  padding: 0.5rem 1rem;
  background: #aaa;
  text-align: center;
  border: none;
}
.su-button:hover {
  background: #ccc;
}
.su-button:disabled, .su-button:disabled:hover {
  opacity: 0.5;
}
</style>

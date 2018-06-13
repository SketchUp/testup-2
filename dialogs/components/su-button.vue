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
  display: inline-block;
  padding: 0.5rem 1rem;
  background: #aaa;
  text-align: center;
}
.su-button:hover {
  background: #ccc;
}
</style>

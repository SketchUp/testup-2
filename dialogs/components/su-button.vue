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
  /* background: #aaa; */
  background: transparent;
  color: #bc0911;
  text-align: center;
  border: none;
  border-radius: 2px;
}
.su-button:hover {
  background: #afafb3;
}
.su-button:disabled, .su-button:disabled:hover {
  opacity: 0.5;
}
.su-button.primary {
  background: #e72b2d;
  color: #ffffff;
}
.su-button.tertiary {
  color: #333333;
}
</style>

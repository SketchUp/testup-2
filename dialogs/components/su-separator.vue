<template>
  <span class="su-separator" v-bind:class="{ vertical: vertical }">
  </span>
</template>

<script lang="ts">
import Vue from "vue";
export default Vue.extend({
  name: 'su-separator',
  props: {
    vertical: Boolean
  }
})
</script>

<style>
.su-separator {
  display: block;
  background: #999;
  height: 1px;
  margin: 0.25rem 0;
}
.su-separator.vertical {
  display: inline-block;
  width: 0;
  height: 1rem;
  margin: 0 0.25rem;
}
</style>

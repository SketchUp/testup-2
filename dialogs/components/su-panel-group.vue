<template>
  <div class="su-panel-group">
    <slot></slot>
  </div>
</template>

<script lang="ts">
import Vue from "vue";
export default Vue.extend({
  name: 'su-panel-group'
})
</script>

<style>
.su-panel-group > * {
  display: inline-block;
  background: #bbb;
}
</style>

<template>
  <div class="su-scrollable"><slot></slot></div>
</template>

<script lang="ts">
import Vue from "vue";
export default Vue.extend({
  name: 'su-scrollable'
})
</script>

<style>
.su-scrollable {
  overflow: auto;
}
</style>

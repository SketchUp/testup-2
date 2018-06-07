<template>
  <div class="su-statusbar"><slot></slot></div>
</template>

<script lang="ts">
import Vue from "vue";
export default Vue.extend({
  name: 'su-statusbar'
})
</script>

<style>
.su-statusbar {
  background: #999;
  border-top: #666;
  padding: 0.25rem 0.5rem;
  font-size: 12px;
}
</style>

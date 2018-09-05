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
  color: #666;
  background: #eaeaef;
  border-top: #eaeaef;
  padding: 0.5rem 0.75rem;
  font-size: 12px;
}
</style>

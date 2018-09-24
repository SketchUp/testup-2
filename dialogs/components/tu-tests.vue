<template>
  <ul class="tu-tests"><slot></slot></ul>
</template>

<script lang="ts">
import Vue from "vue";
export default Vue.extend({
  name: 'tu-tests'
})
</script>

<style>
.tu-tests {
  margin-bottom: 0.5rem;
}
</style>

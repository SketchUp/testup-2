<template>
  <div class="su-listbox">
    <select size="10">
      <option v-for="item in items">{{ item }}</option>
    </select>
  </div>
</template>

<script lang="ts">
import Vue from "vue";
export default Vue.extend({
  name: 'su-listbox',
  props: ['items'],
})
</script>

<style>
.su-listbox {
  display: inline-block;
}
.su-listbox select {
  /* padding: 0.25rem; */
  width: 100%;
}
.su-listbox option {
  padding: 0.25rem;
}
</style>

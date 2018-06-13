<template>
  <fieldset class="su-group">
    <legend>{{ title }}</legend>
    <div>
      <slot></slot>
    </div>
  </fieldset>
</template>

<script lang="ts">
import Vue from "vue";
export default Vue.extend({
  name: 'su-group',
  props: ['title'],
})
</script>

<style>
.su-group {
  border: 1px solid #aaa;
}
.su-group > div {
  padding: 0.25rem;
}
</style>

<template>
  <span class="su-checkbox">
    <label>
      <input type="checkbox"
        v-bind:checked="value"
        v-bind:disabled="disabled"
        v-on:change="$emit('input', $event.target.checked)">
      <slot></slot>
    </label>
  </span>
</template>

<script lang="ts">
import Vue from "vue";
export default Vue.extend({
  name: 'su-checkbox',
  props: ['value', 'disabled'],
})
</script>

<style>
.su-checkbox input {
  vertical-align: bottom;
  margin-bottom: 2px; /* Windows 10, Chrome */
}
</style>

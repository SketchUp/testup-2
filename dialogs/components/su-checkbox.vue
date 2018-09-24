<template>
  <span class="su-checkbox">
    <label v-bind:class="{ checked: value }">
      <span class="su-checkbox-tick">
        <img src="../images/check.svg" width="12">
      </span>
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
  visibility: hidden;
  position: absolute;
}
.su-checkbox > label {
  position: relative;
}
.su-checkbox > label > .su-checkbox-tick {
  display: inline-block;
  width: 18px;
  height: 18px;
  background: #d8d8de;
  border-radius: 2px;
  margin: 0 0.5rem;
}
.su-checkbox > label > .su-checkbox-tick:hover {
  background: #c6c6cc;
}
.su-checkbox > label > .su-checkbox-tick:active {
  background: #949499;
}
.su-checkbox > label > .su-checkbox-tick > img {
  position: relative;
  left: 3px;
  top: 1px;
  visibility: hidden;
}
.su-checkbox > label.checked > .su-checkbox-tick > img {
  visibility: visible;
}
</style>

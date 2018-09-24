<template>
  <label class="su-input" v-bind:class="{ hasLabel: label }">
    <span v-if="label">{{ label }}</span>
    <input v-bind:value="value" />
  </label>
</template>

<script lang="ts">
import Vue from "vue";
export default Vue.extend({
  name: 'su-input',
  props: ['value', 'label'],
})
</script>

<style>
.su-input {
  display: block;
  width: 100%;
}
.su-input input {
  display: inline-block;
  padding: 0.25rem;
  width: 100%;
}
.su-input.hasLabel {
  text-align: right;
}
.su-input.hasLabel span {
  margin-right: 0.5rem;
}
.su-input.hasLabel input {
  width: 80%;
}
/* .su-input.hasLabel span, .su-input input {
  display: block;
  float: right;
} */
</style>

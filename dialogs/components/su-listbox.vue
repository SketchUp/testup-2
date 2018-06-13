<template>
  <div class="su-listbox">
    <select size="10" v-on:change="onChange" v-bind:value="traceValue">
      <option v-for="(item, index) in items" v-bind:value="item">
        {{ item }}
      </option>
    </select>
  </div>
</template>

<script lang="ts">
import Vue from "vue";
export default Vue.extend({
  name: 'su-listbox',
  props: ['items', 'value', 'selectedIndex'],
  methods: {
    onChange(event: Event) {
      let element = event.target as HTMLSelectElement;
      let index = element.selectedIndex;
      let value = element.value;
      this.$emit('change', index, value);
    }
  },
  computed: {
    traceValue(): string {
      console.log('traceValue', this.value, this.items);
      return this.value;
    },
  }
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

<template>
  <div class="su-listbox">
    <select size="10" v-on:change="onChange" v-bind:value="value">
      <option v-for="(item, index) in items">
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
  // computed: {
  //   traceValue(): string {
  //     console.log('traceValue', this.value, this.items);
  //     // this.$forceUpdate();
  //     return this.value;
  //   },
  // },
  watch: {
    value(newValue, oldValue) {
      // For some reason the `value` attribute of the SELECT element doesn't
      // properly update, making the selection appear out of sync with the
      // component data. This kludge of forcing an update in the next tick
      // works around this.
      Vue.nextTick(() => {
        this.$forceUpdate();
      });
    }
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

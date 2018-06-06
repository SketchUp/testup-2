<template>
  <div class="su-tab" v-show="active">
    <slot></slot>
  </div>
</template>


<script lang="ts">
import Vue from "vue";

// https://vuejs.org/v2/guide/typescript.html#Augmenting-Types-for-Use-with-Plugins
declare module 'vue/types/vue' {
  interface Vue {
    registerTab(vue: Vue): void
  }
}

export default Vue.extend({
  name: 'su-tab',
  props: ['title'],
  data: () => ({
    active: false,
  }),
  mounted() {
    // this.$emit('registerTab', this);
    // this.$parent.$emit('registerTab', this);
    this.$parent.registerTab(this);
  },
})
</script>

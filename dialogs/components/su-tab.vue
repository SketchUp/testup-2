<template>
  <div class="su-tab" v-show="active">
    <slot></slot>
  </div>
</template>


<script>
  export default {
    name: 'su-tab',
    props: ['title'],
    data: () => ({
      active: false,
    }),
    mounted() {
      this.$parent.registerTab(this);
    },
  }
</script>

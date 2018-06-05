<template>
  <div class="su-tabs">
    <div class="su-tab-bar">
      <div class="su-tab-title" v-for="(tab, index) in tabs"
            v-bind:class="{ 'active': tab.active }"
            v-on:click="selectTab(index)">
        {{ tab.title }}
      </div>
    </div>
    <div class="su-tab-content"><slot></slot></div>
  </div>
</template>


<script>
  export default {
    name: 'su-tabs',
    props: {
      selectedIndex: {
        type: Number,
        default: 0
      },
    },
    data: () => ({
      tabs: [],
    }),
    methods: {
      registerTab(tab) {
        this.tabs.push(tab);
        if (this.tabs.length - 1 == this.selectedIndex) {
          tab.active = true;
          this.selectTab(this.selectedIndex);
        }
      },
      selectTab(index) {
        console.log('selectTab:', index);
        this.$emit('tab-change', index);
      },
    },
    watch: {
      selectedIndex: function(newIndex, oldIndex) {
        console.log('selectedIndex changed:', oldIndex, newIndex);
        let selectedTab = this.tabs[newIndex];
        this.tabs.forEach(tab => {
          tab.active = (tab === selectedTab);
        });
      },
    },
  }
</script>

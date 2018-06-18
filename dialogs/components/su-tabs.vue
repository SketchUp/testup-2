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
import Vue from "vue";
export default Vue.extend({
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
        // this.selectTab(this.selectedIndex);
      }
    },
    selectTab(index) {
      console.log('selectTab:', index);
      // this.$emit('tab-change', index);
      this.selectedIndex = index;
    },
    reset() {
      this.tabs = [];
    }
  },
  watch: {
    selectedIndex: function(newIndex, oldIndex) {
      console.log('selectedIndex changed:', newIndex, oldIndex);
      let selectedTab = this.tabs[newIndex];
      this.tabs.forEach(tab => {
        tab.active = (tab === selectedTab);
      });
      // this.selectTab(newIndex);
      console.log('> event: tab-change:', newIndex);
      this.$emit('tab-change', newIndex);
    },
  },
})
</script>

<style>
.su-tab-bar {
  background: #bbb;
}
.su-tab-bar .su-tab-title {
  display: inline-block;
  background: #ddd;
  padding: 0.75em 1em;
}
.su-tab-bar .su-tab-title:hover {
  background: #e7e7e7;
}
.su-tab-bar .su-tab-title.active {
  background: #eee;
  font-weight: bold;
}
</style>

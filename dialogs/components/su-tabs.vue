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
      }
    },
    selectTab(index) {
      console.log('selectTab:', index);
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
      console.log('> event: tab-change:', newIndex);
      this.$emit('tab-change', newIndex);
    },
  },
})
</script>

<style>
.su-tab-bar {
  background: #f3f3f7;
}
.su-tab-bar .su-tab-title {
  display: inline-block;
  background: #f3f3f7;
  padding: 0.75em 1em;
  /* transition: border-bottom 0.2s linear; */
}
.su-tab-bar .su-tab-title:hover {
  /* background: #e7e7e7; */
  border-bottom: 2px solid #666;
}
.su-tab-bar .su-tab-title.active {
  /* background: #eee; */
  /* font-weight: bold; */
  border-bottom: 2px solid #e72b2d;
}
</style>

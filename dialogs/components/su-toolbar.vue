<template>
  <div class="su-toolbar"><slot></slot></div>
</template>

<script lang="ts">
import Vue from "vue";
export default Vue.extend({
  name: 'su-toolbar'
})
</script>

<style>
.su-toolbar {
  background: #eaeaef;
  border-bottom: #eaeaef;
  display: flex;
  padding: 15px 10px;
}
.su-toolbar > * {
  display: inline-block;
  /* background: #bbb; */
  margin-right: 5px;
}
.su-toolbar > :last-child {
  margin-right: 0;
}
.su-toolbar .su-flex {
  flex: 1;
  /* background: #faa; */
  background: none;
  padding: 0 !important;
  min-width: 0 !important;
  width: 0 !important;
  overflow: hidden;
  margin-right: 0;
}

.su-toolbar .su-button {
  padding: 1rem;
}

.su-toolbar .su-panel {
  padding: 1rem 0.5rem;
  min-width: 3rem;
  text-align: center;
}

.su-toolbar .su-panel {
  padding: 1rem 0.5rem;
  min-width: 3rem;
  text-align: center;
}
</style>

<template>
  <li class="tu-test" v-bind:class="classObject" v-bind:title="testTitle">
    <div class="tu-title">
      <su-checkbox v-model="test.enabled" v-bind:disabled="test.missing">{{ test.title }}</su-checkbox>
      <span v-if="test.result" class="tu-metadata">(Time: {{ test.result.run_time | formatTime }})</span>
    </div>
    <tu-test-result v-if="test.result" v-bind:result="test.result"/>
  </li>
</template>

<script>
  import SUCheckbox from "./su-checkbox.vue";
  import TUTestResult from "./tu-test-result.vue";

  export default {
    name: 'tu-test',
    props: ['test'],
    computed: {
      classObject() {
        let result = this.test.result;
        let classes = {};
        if (this.test.missing) classes['tu-missing'] = true;
        if (result) {
          if (result.passed) classes['tu-passed'] = true;
          if (result.error) classes['tu-error'] = true;
          if (result.skipped) classes['tu-skipped'] = true;
          // if (result.failed) classes['tu-failed'] = true;
          if (!(result.passed || result.error || result.skipped || result.missing)) {
            classes['tu-failed'] = true;
          }
        }
        return classes;
      },
      testTitle() {
        if (this.test.missing) return 'Missing';
        let result = this.test.result;
        if (result) {
          if (result.passed) return 'Passed';
          if (result.error) return 'Error';
          if (result.skipped) return 'Skipped';
          return 'Failed';
        }
        return 'Not run';
      }
    },
    filters: {
      formatTime(seconds) {
        return seconds.toFixed(3);
      },
    },
  }
</script>

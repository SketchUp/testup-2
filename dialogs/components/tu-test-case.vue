<template>
  <li class="tu-test-case" v-bind:class="classObject">
    <div class="tu-title" v-on:click="toggle">
      <su-checkbox
        v-model="testCase.enabled"
        v-bind:disabled="isAllMissing"
        v-on:input="selectTests(testCase, testCase.enabled)"></su-checkbox>
      <b>{{ testCase.title }}</b>
      <span class="tu-metadata">
        (
          Tests: <span class="size">{{ testCase.tests.length }}</span>,
          Passed: <span class="passed">{{ stats.passed }}</span>,
          Failed: <span class="failed">{{ stats.failed }}</span>,
          Errors: <span class="errors">{{ stats.errors }}</span>,
          Skipped: <span class="skipped">{{ stats.skipped }}</span>,
          Missing: <span class="missing">{{ stats.missing }}</span>
        )
        <!-- <img src="../images/accept.svg" width="16"> -->
      </span>
    </div>
    <transition name="fade">
      <tu-tests v-show="testCase.expanded">
        <tu-test
          v-for="test in testCase.tests"
          v-bind:key="test.id"
          v-bind:test="test"></tu-test>
      </tu-tests>
    </transition>
  </li>
</template>

<script>
import Vue from "vue";

import SUCheckbox from "./su-checkbox.vue";
import TUTests from "./tu-tests.vue";
import TUTest from "./tu-test.vue";

export default Vue.extend({
  name: 'tu-test-case',
  props: ['testCase'],
  components: {
    'su-checkbox': SUCheckbox,
    'tu-tests': TUTests,
    'tu-test': TUTest,
  },
  computed: {
    stats() {
      let data = {
        tests: this.testCase.tests.length,
        passed: 0,
        failed: 0,
        errors: 0,
        skipped: 0,
        missing: 0,
      }
      for (let test of this.testCase.tests) {
        data.missing += test.missing ? 1 : 0;
        if (!test.result) continue;
        let result = test.result;
        data.passed += result.passed ? 1 : 0;
        data.errors += result.error ? 1 : 0;
        data.skipped += result.skipped ? 1 : 0;
        // data.failed += result.failed ? 1 : 0;
        if (!(result.passed || result.error || result.skipped || result.missing)) {
          data.failed += 1;
        }
      }
      return data;
    },
    isAllMissing() {
      return this.stats.tests == this.stats.missing;
    },
    classObject() {
      let stats = this.stats;
      let classes = {};

      // Pick the most severe status from the tests for the testcase.
      if (stats.failed > 0) {
        classes['tu-failed'] = true;
      }
      else if (stats.errors > 0) {
        classes['tu-error'] = true;
      }
      else if (stats.passed > 0) {
        classes['tu-passed'] = true;
      }

      // Always add missing class to a test case as it doesn't exclude the
      // other statuses.
      if (stats.missing > 0)
      {
        classes['tu-missing'] = true;
      }

      // Mark test cases with partial coverage that hasn't been run yet.
      let partially_missing = stats.missing > 0 && stats.missing != stats.tests;
      if (partially_missing && stats.failed == 0 && stats.errors == 0 && stats.passed == 0)
      {
        classes['tu-partial'] = true;
      }

      return classes;
    },
  },
  methods: {
    selectTests(test_case, enabled) {
      for (let test of test_case.tests) {
        test.enabled = enabled
      }
    },
    toggle(event) {
      // console.log(event);
      if (event.srcElement.type !== 'checkbox') {
        this.testCase.expanded = !this.testCase.expanded
      }
    }
  },
  watch: {
    testCase(newTestCase, oldTestCase) {
      // console.log('Test Case Updated');
      // Roll down all test cases that have failed tests.
      for (let test of this.testCase.tests) {
        // Only unroll if tests that ran failed. This allow the user to roll
        // up failed tests while focusing on a sub-set.
        if (!(test.enabled && test.result)) continue;
        if (test.result.error || test.result.failed) {
          this.testCase.expanded = true
          return;
        }
      }
      return false;
    },
  },
})
</script>

<style>
.tu-test-case {
  /* padding: 0.25rem; */
  border-bottom: 1px solid #eaeaef;
}
.tu-test-case:hover {
  background: #eaeaef;
}
.tu-test-case > .tu-title {
  white-space: nowrap;
  padding: 0.5rem 1rem;
  padding-left: 25px;
  background: url(../images/not_run.svg) no-repeat 0.5rem center;
  background-size: 16px 16px;
}
</style>

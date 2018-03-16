/*******************************************************************************
 *
 * Copyright 2013-2018 Trimble Inc.
 * License: The MIT License (MIT)
 *
 ******************************************************************************/


Vue.component('su-toolbar', {
  template: `<div class="su-toolbar"><slot></slot></div>`,
});


Vue.component('su-button', {
  template: `
    <div class="su-button">
      <slot></slot>
    </div>`,
});

Vue.component('su-checkbox', {
  props: ['value'],
  template: `
    <span class="su-checkbox">
      <label>
        <input type="checkbox"
          v-bind:checked="value"
          v-on:change="$emit('input', $event.target.checked)">
        <slot></slot>
      </label>
    </span>`,
});


Vue.component('su-panel', {
  template: `<div class="su-panel"><slot></slot></div>`,
});

Vue.component('su-panel-group', {
  template: `<div class="su-panel-group"><slot></slot></div>`,
});


Vue.component('su-tabs', {
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
        this.selectTab(this.selectedIndex);
      }
    },
    selectTab(index) {
      let selectedTab = this.tabs[index];
      // TODO: Use a watcher instead?
      this.tabs.forEach(tab => {
        tab.active = (tab === selectedTab);
      });
      this.$emit('input', index);
    },
  },
  template: `
    <div class="su-tabs">
      <div class="su-tab-bar">
        <div class="su-tab-title" v-for="(tab, index) in tabs"
             v-bind:class="{ 'active': tab.active }"
             v-on:click="selectTab(index)">
          {{ tab.title }}
        </div>
      </div>
      <div class="su-tab-content"><slot></slot></div>
    </div>`,
});

Vue.component('su-tab', {
  props: ['title'],
  data: () => ({
    active: false,
  }),
  mounted() {
    this.$parent.registerTab(this);
  },
  template: `
    <div class="su-tab" v-show="active">
      <slot></slot>
    </div>`,
});


Vue.component('su-statusbar', {
  template: `<div class="su-statusbar"><slot></slot></div>`,
});


Vue.component('su-scollable', {
  template: `<div class="su-scollable"><slot></slot></div>`,
});


Vue.component('tu-test-suite', {
  template: `
  <ul class="tu-test-suite"><slot></slot></ul>`,
});

Vue.component('tu-test-case', {
  props: ['testCase'],
  methods: {
    selectTests(test_case, enabled) {
      for (test of test_case.tests) {
        test.enabled = enabled
      }
    },
    toggle() {
      this.testCase.expanded = !this.testCase.expanded
    }
  },
  template: `
    <li class="tu-test-case">
      <div class="tu-title" v-on:click="toggle">
        <img src="../images/not_run.png">
        <su-checkbox
          v-model="testCase.enabled"
          v-on:input="selectTests(testCase, testCase.enabled)">&nbsp;</su-checkbox>
        <b>{{ testCase.title }}</b>
        <span class="tu-metadata">
          (
            Tests: <span title="Tests" class="size">{{ testCase.tests.length }}</span>,
            Passed: <span title="Passed" class="passed">0</span>,
            Failed: <span title="Failed" class="failed">0</span>,
            Errors: <span title="Errors" class="errors">0</span>,
            Skipped: <span title="Skipped" class="skipped">0</span>
          )
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
    </li>`,
});

Vue.component('tu-tests', {
  template: `<ul class="tu-tests"><slot></slot></ul>`,
});

Vue.component('tu-test', {
  props: ['test'],
  computed: {
    classObject: function () {
      let result = this.test.result;
      let classes = {};
      if (result) {
        if (result.passed) classes['tu-passed'] = true;
        if (result.failed) classes['tu-failed'] = true;
        if (result.error) classes['tu-error'] = true;
        if (result.skipped) classes['tu-skipped'] = true;
        if (result.missing) classes['tu-missing'] = true;
      }
      return classes;
    }
  },
  template: `
    <li class="tu-test" v-bind:class="classObject">
      <div class="tu-title">
        <su-checkbox v-model="test.enabled">{{ test.title }}</su-checkbox>
        <span v-if="test.result">(Time: {{ test.result.run_time }})</span>
      </div>
      <tu-test-result v-if="test.result" v-bind:result="test.result"/>
    </li>
  `,
});

Vue.component('tu-test-result', {
  props: ['result'],
  filters: {
    linkify: function (message) {
      // TODO: Linkify source locations.
      return message;
    },
  },
  template: `
    <div class="tu-test-result">
      <div v-for="failure in result.failures" class="tu-test-failure">
        <div class="tu-title">
          <a href="#" title="Click to open file in editor">
            {{ failure.location }}
          </a>
        </div>
        <pre class="tu-message">{{ failure.message | linkify }}</pre>
      </div>
    </div>
  `,
});


let app = new Vue({
  el: '#app',
  data: {
    test_suites: [],
    activeTestSuiteIndex: 0,
    last_update: new Date(),
  },
  watch: {
    test_suites: function (val) {
      // TODO: Work around Chrome bug:
      // https://stackoverflow.com/questions/44778114/chrome-tolocaledatestring-returning-wrong-format
      this.last_update = new Date();
    },
  },
  methods: {
    update(discoveries) {
      this.test_suites = discoveries;
    },
    update_test_suite(test_suite) {
      console.log('Update Test Suite!', this.activeTestSuiteIndex);
      // let tsi = this.test_suites.find((ts) => {
      //   return ts.title == test_suite.title;
      // });
      // let index = this.test_suites.indexOf(tsi);
      // this.test_suites[index] = test_suite;
      // TODO: Find a better way to get the test_suite index. Don't rely on the
      //       active tab index.
      this.test_suites[this.activeTestSuiteIndex].test_cases = test_suite.test_cases;
    },
    selectTestSuite(test_suite, enabled) {
      for (test_case of test_suite.test_cases) {
        test_case.enabled = enabled;
        for (test of test_case.tests) {
          test.enabled = enabled
        }
      }
    },
    runTests() {
      let test_suite = this.test_suites[this.activeTestSuiteIndex];
      sketchup.runTests(test_suite);
    },
  },
  computed: {
    num_test_suites: function () {
      return this.test_suites.length;
    },
    num_test_cases: function () {
      let num = 0;
      for (test_suite of this.test_suites) {
        num += test_suite.test_cases.length
      }
      return num;
    },
    num_tests: function () {
      let num = 0;
      for (test_suite of this.test_suites) {
        for (test_case of test_suite.test_cases) {
          num += test_case.tests.length
        }
      }
      return num;
    },
  },
  mounted() {
    sketchup.ready();
  }
});

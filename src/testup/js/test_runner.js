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
  template: `<div class="su-button"><slot></slot></div>`,
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
  },
  template: `
    <li class="tu-test-case" v-bind:class="{ expanded: testCase.expanded }">
      <img src="../images/not_run.png">
      <su-checkbox
        v-model="testCase.enabled"
        v-on:input="selectTests(testCase, testCase.enabled)">&nbsp;</su-checkbox>
      <span class="tu-title" v-on:click="testCase.expanded = !testCase.expanded">
        {{ testCase.title }}
      </span>
      <span class="tu-metadata">
        (
          Tests: <span title="Tests" class="size">{{ testCase.tests.length }}</span>,
          Passed: <span title="Passed" class="passed">0</span>,
          Failed: <span title="Failed" class="failed">0</span>,
          Errors: <span title="Errors" class="errors">0</span>,
          Skipped: <span title="Skipped" class="skipped">0</span>
        )
      </span>
      <tu-tests>
        <tu-test
          v-for="test in testCase.tests"
          v-bind:key="test.id"
          v-bind:test="test"></tu-test>
      </tu-tests>
    </li>`,
});

Vue.component('tu-tests', {
  template: `<ul class="tu-tests"><slot></slot></ul>`,
});

Vue.component('tu-test', {
  props: ['test'],
  template: `
    <li>
      <img src="../images/not_run.png">
      <su-checkbox v-model="test.enabled">{{ test.title }}</su-checkbox>
    </li>
  `,
});


let app = new Vue({
  el: '#app',
  data: {
    message: 'Hello Vue!',
    test_suites: [],
    // tabIndex: 0,
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
    init(config) {
      this.message = 'Init!';
    },
    update(discoveries) {
      this.message = 'Update!';
      this.test_suites = discoveries;
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
      sketchup.runTests(this.test_suites[this.activeTestSuiteIndex]);
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

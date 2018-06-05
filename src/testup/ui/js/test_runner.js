/*******************************************************************************
 *
 * Copyright 2013-2018 Trimble Inc.
 * License: The MIT License (MIT)
 *
 ******************************************************************************/

/* TODO(thomthom): Move to separate module. (See SUbD) */
function sketchupErrorHandler(error, vm, info) {
  let data = {
    'message' : `Vue Error (${info}): ${error.message}`,
    'backtrace' : error.backtrace,
    'user-agent': navigator.userAgent,
    'document-mode': document.documentMode
  };
  sketchup.js_error(data);
  console.error(data.message);
  console.error(error);
}
Vue.config.errorHandler = sketchupErrorHandler;
// TODO(thomthom): Look into also hooking up warnHandler.
// https://vuejs.org/v2/api/#warnHandler

window.onerror = function(message, file, line, column, error) {
  try
  {
    // Not all browsers pass along the error object. Without that it's not
    // possible to get full backtrace.
    // http://blog.bugsnag.com/js-stacktraces
    var backtrace = [];
    if (error && error.stack)
    {
      backtrace = String(error.stack).split("\n");
    }
    else
    {
      backtrace = [file + ':' + line + ':' + column];
    }
    var data = {
      'message' : message,
      'backtrace' : backtrace,
      'user-agent': navigator.userAgent,
      'document-mode': document.documentMode
    };
    sketchup.js_error(data);
  }
  catch (error)
  {
    debugger;
    throw error;
  }
};


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
  props: ['value', 'disabled'],
  template: `
    <span class="su-checkbox">
      <label>
        <input type="checkbox"
          v-bind:checked="value"
          v-bind:disabled="disabled"
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
      for (test of this.testCase.tests) {
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
      for (test of test_case.tests) {
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
      for (test of this.testCase.tests) {
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
  template: `
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
  template: `
    <li class="tu-test" v-bind:class="classObject" v-bind:title="testTitle">
      <div class="tu-title">
        <su-checkbox v-model="test.enabled" v-bind:disabled="test.missing">{{ test.title }}</su-checkbox>
        <span v-if="test.result" class="tu-metadata">(Time: {{ test.result.run_time | formatTime }})</span>
      </div>
      <tu-test-result v-if="test.result" v-bind:result="test.result"/>
    </li>
  `,
});

Vue.component('tu-test-result', {
  props: ['result'],
  filters: {
    linkify(string) {
      let escaped = this.escape_html(string);
      var pattern = /^(\s*)(.+\.rb[es]?:\d+)/gm;
      var replacement = "$1<a href='$2' data-location='$2' title='Click to open file in editor'>$2</a>";
      var html = escaped.replace(pattern, replacement);
      return html;
    },
    escape_html(string) {
      let html = string.replace(/&/g, "&amp;");
      html = html.replace(/</g, "&lt;").replace(/>/g, "&gt;");
      return html;
    },
  },
  methods: {
    openEditor(location) {
      sketchup.openSourceFile(location);
    },
    interceptLinks(event) {
      // Because the content of .tu-message is dynamically generated by a
      // Vue filter normal Vue event listener cannot be attached on the
      // A elements. Instead the .tu-message click event is used to detect
      // clicks on child-A elements.
      if (event.srcElement.href) {
        event.preventDefault();
        sketchup.openSourceFile(event.srcElement.dataset.location);
      }
    },
  },
  template: `
    <div class="tu-test-result">
      <div v-for="failure in result.failures" class="tu-test-failure">
        <div class="tu-title">
          <a href="failure.location"
              v-on:click.prevent="openEditor(failure.location)"
              title="Click to open file in editor">
            {{ failure.location }}
          </a>
        </div>
        <pre class="tu-message"
          v-on:click="interceptLinks"
          v-html="$options.filters.linkify(failure.message)"></pre>
      </div>
    </div>
  `,
});


let app = new Vue({
  el: '#app',
  data: {
    test_suites: [],
    activeTestSuiteIndex: 0,
    statusBarText: '',
  },
  methods: {
    configure(config) {
      console.log('configure', config);
      let test_suite_title = config.active_tab;
      // this.test_suites[this.activeTestSuiteIndex];
      let index = this.test_suites.findIndex((test_suite) => {
        return test_suite.title == test_suite_title;
      });
      console.log('tab index:', index);
      this.activeTestSuiteIndex = index >= 0 ? index : 0;
    },
    discover(discoveries) {
      console.log('discover');
      this.test_suites = discoveries;
      this.statusBarText = `
        ${ this.num_test_suites } test suites,
        ${ this.num_test_cases } test cases,
        ${ this.num_tests - this.num_tests_missing } tests discovered,
        ${ this.num_tests_missing } tests missing
      `;
    },
    rediscover(discoveries) {
      console.log('rediscover');
      this.test_suites = discoveries;
      this.statusBarText = `
        ${ this.num_test_suites } test suites,
        ${ this.num_test_cases } test cases,
        ${ this.num_tests - this.num_tests.missing } tests discovered,
        ${ this.num_tests.missing } tests missing
      `;
    },
    update_results(test_suite) {
      console.log('update_results', this.activeTestSuiteIndex);
      // let tsi = this.test_suites.find((ts) => {
      //   return ts.title == test_suite.title;
      // });
      // let index = this.test_suites.indexOf(tsi);
      // this.test_suites[index] = test_suite;
      // TODO: Find a better way to get the test_suite index. Don't rely on the
      //       active tab index.
      // TODO: Update coverage
      this.test_suites[this.activeTestSuiteIndex].test_cases = test_suite.test_cases;
      // Update statusbar.
      let stats = this.test_suite_stats(test_suite);
      let total_time_formatted = stats.total_time.toFixed(3) + 's';
      this.statusBarText = `
        ${ stats.tests } tests from test suite ${ test_suite.title }
        run in ${ total_time_formatted }.
        ${ stats.passed } passed,
        ${ stats.failed } failed,
        ${ stats.errors } errors,
        ${ stats.skipped } skipped
      `;
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
    discoverTests() {
      // TODO: This appear to sometimes cause crashes.
      // sketchup.discoverTests(this.test_suites);
      // Workaround is to convert to a JSON string and have Ruby perform the
      // parsing itself. Might be a bug in the SketchUp code that converts the
      // callback data to Ruby objects.
      // Additionally, I don't think SU2016 supported all the types needed to
      // pass an object back as a Hash to Ruby.
      let json = JSON.stringify(this.test_suites);
      sketchup.discoverTests(json);
    },
    reRun() {
      sketchup.reRunTests();
    },
    changeTestSuite(index) {
      this.activeTestSuiteIndex = index;
      sketchup.changeActiveTestSuite(this.active_test_suite.title);
    },
    test_suite_stats(test_suite) {
      let data = {
        tests: 0,
        passed: 0,
        failed: 0,
        errors: 0,
        skipped: 0,
        missing: 0,
        total_time: 0,
      };
      if (test_suite) {
        for (test_case of test_suite.test_cases) {
          data.tests += test_case.tests.length;
          for (test of test_case.tests) {
            data.missing += test.missing ? 1 : 0;
            if (!test.result) continue;
            data.passed += test.result.passed ? 1 : 0;
            data.failed += test.result.failed ? 1 : 0;
            data.errors += test.result.error ? 1 : 0;
            data.skipped += test.result.skipped ? 1 : 0;
            data.total_time += test.result.run_time;
          }
        }
      }
      return data;
    },
  },
  computed: {
    num_test_suites: function () {
      return this.test_suites.length;
    },
    num_test_cases: function () {
      let num = 0;
      for (test_suite of this.test_suites) {
        num += test_suite.test_cases.length;
      }
      return num;
    },
    num_tests: function () {
      let num = 0;
      for (test_suite of this.test_suites) {
        for (test_case of test_suite.test_cases) {
          num += test_case.tests.length;
        }
      }
      return num;
    },
    num_tests_missing: function () {
      let num = 0;
      for (test_suite of this.test_suites) {
        for (test_case of test_suite.test_cases) {
          for (test of test_case.tests) {
            if (test.missing) num += 1;
          }
        }
      }
      return num;
    },
    active_test_suite() {
      console.log('active_test_suite');
      return this.test_suites[this.activeTestSuiteIndex];
    },
    active_test_suite_stats() {
      console.log('active_test_suite_stats');
      return this.test_suite_stats(this.active_test_suite);
    },
  },
  mounted() {
    sketchup.ready();
  }
});

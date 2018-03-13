/*******************************************************************************
 *
 * Copyright 2013-2018 Trimble Inc.
 * License: The MIT License (MIT)
 *
 ******************************************************************************/

var app = new Vue({
  el: '#app',
  data: {
    message: 'Hello Vue!',
    test_suites: [],
    tabIndex: 0,
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
        this.selectTests(test_case, enabled);
      }
    },
    selectTests(test_case, enabled) {
      for (test of test_case.tests) {
        test.enabled = enabled
      }
    },
    runTests() {
      sketchup.runTests(this.test_suites[this.tabIndex]);
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

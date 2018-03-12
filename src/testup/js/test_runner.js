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
  },
  methods: {
    init(config) {
      this.message = 'Init!';
    },
    update(discoveries) {
      this.message = 'Update!';
      this.test_suites = discoveries;
    },
    selectAll(test_suite) {
      for (test_case of test_suite.test_cases) {
        test_case.enabled = true;
      }
    },
    selectNone(test_suite) {
      for (test_case of test_suite.test_cases) {
        test_case.enabled = false;
      }
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

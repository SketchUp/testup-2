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
    test_suites: {}
  },
  methods: {
    init(config) {
      this.message = 'Init!';
    },
    update(discoveries) {
      this.message = 'Update!';
      this.test_suites = discoveries;
    }
  },
  mounted() {
    sketchup.ready();
  }
});

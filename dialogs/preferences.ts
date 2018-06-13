/*******************************************************************************
 *
 * Copyright 2013-2018 Trimble Inc.
 * License: The MIT License (MIT)
 *
 ******************************************************************************/

"use strict";

import Vue from "vue";
import * as suErrorHandler from "./ts/su-error-handler";

Vue.config.errorHandler = suErrorHandler.vueErrorHandler;
window.onerror = suErrorHandler.globalErrorHandler;

import { PreferencesWebDialogShim } from "./ts/webdialog/webdialog-preferences";
if (!window.sketchup) {
  window.sketchup = new PreferencesWebDialogShim;
}

import { SketchUpPreferences } from "./ts/interfaces/sketchup-preferences";
declare const sketchup: SketchUpPreferences;

import SUButton from "./components/su-button.vue";
import SUGroup from "./components/su-group.vue";
import SUInput from "./components/su-input.vue";
import SULabel from "./components/su-label.vue";
import SUListBox from "./components/su-listbox.vue";
import SUPanelGroup from "./components/su-panel-group.vue";
import SUPanel from "./components/su-panel.vue";
import SUScrollable from "./components/su-scrollable.vue";
import SUSeparator from "./components/su-separator.vue";
import SUStatusbar from "./components/su-statusbar.vue";
import SUTabs from "./components/su-tabs.vue";
import SUTab from "./components/su-tab.vue";
import SUToolbar from "./components/su-toolbar.vue";
import TUTestCase from "./components/tu-test-case.vue";
import TUTestSuite from "./components/tu-test-suite.vue";

declare global {
  interface Window { app: Vue; }
}

interface EditorConfig {
  executable: string,
  arguments: string,
}

interface PreferencesConfig {
  test_suite_paths: Array<string>,
  editor: EditorConfig,
}

window.app = new Vue({
  el: '#app',
  data() {
    return {
      config: <PreferencesConfig> {
        test_suite_paths: ['C:/hello/world'],
        editor: {
          executable: "vscode.exe",
          arguments: "{FILE}:{LINE}",
        },
      },
    };
  },
  methods: {
    configure(config: PreferencesConfig) {
      // console.log('configure', config);
      // let test_suite_title = config.active_tab;
      // // this.test_suites[this.activeTestSuiteIndex];
      // let index = this.test_suites.findIndex((test_suite: TestSuite) => {
      //   return test_suite.title == test_suite_title;
      // });
      // console.log('tab index:', index);
      // this.activeTestSuiteIndex = index >= 0 ? index : 0;
    },
    movePathUp() {
      // sketchup.movePathUp();
    },
    movePathDown() {
      // sketchup.movePathDown();
    },
    editPath() {
      let path = 'C:/hello/world';
      let index = 0;
      sketchup.editPath(path, index);
    },
    removePath() {
      // sketchup.removePath();
    },
    addPath() {
      sketchup.addPath();
    },
    cancel() {
      sketchup.cancel();
    },
    save() {
      sketchup.save();
    },
  },
  // computed: {
  //   num_test_suites: function () {
  //     return this.test_suites.length;
  //   },
  // },
  mounted() {
    // KLUDGE(thomthom):
    // For some reason, calling any methods on the global `app` instance from
    // the `ready`callback  will raise errors in IE11. Waiting a tick works
    // around this shenanigan.
    Vue.nextTick(function () {
      sketchup.ready();
    });
  },
  components: {
    'su-button': SUButton,
    'su-group': SUGroup,
    'su-input': SUInput,
    'su-label': SULabel,
    'su-listbox': SUListBox,
    'su-panel': SUPanel,
    'su-panel-group': SUPanelGroup,
    'su-scrollable': SUScrollable,
    'su-separator': SUSeparator,
    'su-statusbar': SUStatusbar,
    'su-tabs': SUTabs,
    'su-tab': SUTab,
    'su-toolbar': SUToolbar,
    'tu-test-case': TUTestCase,
    'tu-test-suite': TUTestSuite,
  },
});

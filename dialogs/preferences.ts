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

import { PreferencesConfig } from "./ts/interfaces/preferences-config";

import SUButton from "./components/su-button.vue";
import SUGroup from "./components/su-group.vue";
import SUInput from "./components/su-input.vue";
import SULabel from "./components/su-label.vue";
import SUListBox from "./components/su-listbox.vue";
import SUSeparator from "./components/su-separator.vue";

declare global {
  interface Window { app: Vue; }
}


window.app = new Vue({
  el: '#app',
  data() {
    return {
      config: <PreferencesConfig> {
        test_suite_paths: [],
        editor: {
          executable: "",
          arguments: "",
        },
      },
      selectedPathIndex: 0,
    };
  },
  methods: {
    configure(config: PreferencesConfig) {
      console.log('configure', config);
      this.config = config;
    },
    pathSelected(index: number, value: string) {
      console.log('pathSelected', index, value);
      this.selectedPathIndex = index;
    },
    movePath(from: number, offset: number) {
      let to = (this.selectedPathIndex + offset) % this.numPaths;
      let paths = this.config.test_suite_paths;
      paths.splice(to, 0, paths.splice(from, 1)[0]);
      // this.selectedPathIndex = to;
      Vue.nextTick(() => {
        this.selectedPathIndex = to;
      });
    },
    movePathUp() {
      this.movePath(this.selectedPathIndex, -1);
    },
    movePathDown() {
      this.movePath(this.selectedPathIndex, 1);
    },
    editPath() {
      sketchup.editPath(this.selectedPath, this.selectedPathIndex);
    },
    removePath() {
      let index = this.selectedPathIndex;
      if (index >= 0 && index < this.numPaths) {
        // let paths = this.config.test_suite_paths;
        // paths.splice(index, 1);
        let newIndex = Math.max(this.selectedPathIndex - 1, 0);
        console.log('Remove:', index, newIndex);
        // this.selectedPathIndex = newIndex;
        // this.selectedPathIndex += index == 0 ? 0 : -1;
        // this.config.test_suite_paths = paths;
        this.selectedPathIndex = -1;
        Vue.nextTick(() => {
          this.config.test_suite_paths.splice(index, 1);
          this.selectedPathIndex = newIndex;
        });
        // Vue.nextTick(() => {
        // });
        // this.selectedPathIndex = -1;
        // this.selectedPathIndex = index;
        // this.$forceUpdate();
      }
    },
    addPath() {
      sketchup.addPath();
    },
    cancel() {
      sketchup.cancel();
    },
    save() {
      sketchup.save(this.config);
    },
  },
  computed: {
    numPaths(): number {
      return this.config.test_suite_paths.length;
    },
    selectedPath(): string {
      console.log('selectedPath', this.selectedPathIndex, this.config.test_suite_paths);
      let index = this.selectedPathIndex;
      let num_paths = this.config.test_suite_paths.length;
      if (index >= 0 && index < num_paths) {
        return this.config.test_suite_paths[this.selectedPathIndex];
      } else {
        return '';
      }
    },
  },
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
    'su-separator': SUSeparator,
  },
});

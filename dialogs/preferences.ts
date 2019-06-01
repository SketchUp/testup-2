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
import * as UI from './ts/ui'

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
      selectedPathIndex: -1,
    };
  },
  methods: {
    configure(config: PreferencesConfig) {
      console.log('configure', config);
      this.config = config;
    },
    addPaths(path: string) {
      console.log('addPaths', path);
      this.config.test_suite_paths = this.config.test_suite_paths.concat(path);
    },
    updatePath(path: string, index: number) {
      console.log('updatePath', path, index);
      this.config.test_suite_paths.splice(index, 1, path);
    },
    pathSelected(index: number, value: string) {
      console.log('pathSelected', index, value);
      this.selectedPathIndex = index;
    },
    movePath(from: number, offset: number) {
      if (this.selectedPathIndex < 0) return;
      let to = (this.selectedPathIndex + offset) % this.numPaths;
      let paths = this.config.test_suite_paths;
      paths.splice(to, 0, paths.splice(from, 1)[0]);
      // Must do this the next tick for the SELECT element to correctly update
      // its selection.
      Vue.nextTick(() => {
        this.selectedPathIndex = to;
      });
    },
    movePathUp() {
      if (this.selectedPathIndex > 0)
        this.movePath(this.selectedPathIndex, -1);
    },
    movePathDown() {
      if (this.selectedPathIndex < this.numPaths - 1)
        this.movePath(this.selectedPathIndex, 1);
    },
    editPath() {
      sketchup.editPath(this.selectedPath, this.selectedPathIndex);
    },
    removePath() {
      let index = this.selectedPathIndex;
      if (index >= 0 && index < this.numPaths) {
        this.config.test_suite_paths.splice(index, 1);
      }
    },
    addPath() {
      sketchup.addPath();
    },
    changeEditorExecutable: function(ev) {
      this.config.editor.executable = ev.target.value;
      this.config.editor.application = ev.target.value;
    },
    changeEditorArguments: function(ev) {
      this.config.editor.arguments = ev.target.value;
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
      // console.log('selectedPath', this.selectedPathIndex, this.config.test_suite_paths);
      let index = this.selectedPathIndex;
      let num_paths = this.config.test_suite_paths.length;
      if (index >= 0 && index < num_paths) {
        return this.config.test_suite_paths[this.selectedPathIndex];
      } else {
        return '';
      }
    },
    isPathSelected(): boolean {
      return this.numPaths > 0 && this.selectedPathIndex >= 0;
    },
    canMovePathUp(): boolean {
      return this.isPathSelected && this.selectedPathIndex > 0;
    },
    canMovePathDown(): boolean {
      return this.isPathSelected && this.selectedPathIndex < this.numPaths - 1;
    },
  },
  mounted() {
    // Redirect normal links to be opened in an external browser.
    UI.redirect_links();
    // Disable native browser functions to make the dialog appear more native.
    UI.disable_select();
    UI.disable_context_menu();
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

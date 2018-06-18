import { SketchUpRunner } from '../interfaces/sketchup-runner'
import { WebDialogShim } from '../webdialog/webdialog-shim'
import { TestSuite } from '../types';

export class RunnerWebDialogShim extends WebDialogShim implements SketchUpRunner {
  changeActiveTestSuite(test_suite_title: string): void {
    this.sketchup('changeActiveTestSuite', [test_suite_title]);
  }
  discoverTests(test_suites: string): void {
    this.sketchup('test_suites', [test_suites]);
  }
  openPreferences(): void
  {
    this.sketchup('openPreferences');
  }
  reRunTests(): void
  {
    this.sketchup('reRunTests');
  }
  runTests(test_suite: TestSuite): void
  {
    this.sketchup('runTests', [test_suite]);
  }
}

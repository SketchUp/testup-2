import { SketchUp } from './sketchup';
import { TestSuite } from '../types';

export interface SketchUpRunner extends SketchUp {
  changeActiveTestSuite(test_suite_title: string): void;
  // Type is `string` only because the need to workaround a crash that. The
  // workaround is to pass a JSON string of the object.
  // discoverTests(test_suites: Array<TestSuite>): void;
  discoverTests(test_suites: string): void;
  openPreferences(): void;
  reRunTests(): void;
  runTests(test_suite: TestSuite): void;
}

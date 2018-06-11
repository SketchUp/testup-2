import { TestSuite } from './types';

export default interface SketchUp {
  changeActiveTestSuite(test_suite_title: string): void;
  discoverTests(test_suites: Array<TestSuite>): void;
  js_error(error_data: any): void;
  ready(): void;
  reRunTests(): void;
  runTests(test_suite: TestSuite): void;
}

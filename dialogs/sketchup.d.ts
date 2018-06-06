// TODO: Add type instead of any
interface SketchUp {
  changeActiveTestSuite(test_suite_title: string): void;
  discoverTests(test_suites: any): void;
  js_error(error_data: any): void;
  ready(): void;
  reRunTests(): void;
  runTests(test_suite: any): void;
}
declare const sketchup: SketchUp;

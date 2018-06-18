export interface RunnerConfig {
  active_tab: string;
}

export interface TestResult {
  passed: boolean;
  failed: boolean;
  error: boolean;
  skipped: boolean;
  run_time: number;
}

export interface Test {
  enabled: boolean;
  missing: boolean;
  result: TestResult;
}

export interface TestCase {
  enabled: boolean;
  expanded: boolean;
  tests: Array<Test>;
}

export interface TestSuite {
  test_cases: Array<TestCase>;
  title: string;
}

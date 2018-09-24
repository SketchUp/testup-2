export interface RunnerConfig {
  active_tab: string;
}

export interface TestFailure {
  type: string;
  message: string;
  location: string;
}

export interface TestResult {
  passed: boolean;
  error: boolean;
  skipped: boolean;
  assertions: number;
  failures: Array<TestFailure>;
  run_time: number;
}

export class Test {
  title: string;
  id: string;
  enabled: boolean;
  missing: boolean;
  result: TestResult;

  constructor(item: Test) {
    this.title = item.title;
    this.id = item.id;
    this.enabled = item.enabled;
    this.missing = item.missing;
    this.result = item.result;
  }

  public passed() {
    return this.result && this.result.passed;
  }

  // Failure if assertion failed or error was thrown.
  public failed() {
    if (!this.result) return false;
    if (this.result.skipped) return false;
    if (this.result.passed) return false;
    return true;
  }

  public skipped() {
    return this.result && this.result.skipped;
  }
}

export class TestCase {
  title: string;
  id: string;
  enabled: boolean;
  expanded: boolean;
  tests: Array<Test>;

  constructor(item: TestCase) {
    this.title = item.title;
    this.id = item.id;
    this.enabled = item.enabled;
    this.expanded = item.expanded;
    this.tests = item.tests.map(item => new Test(item));
  }

  public hasFailedTests() {
    for (let test of this.tests) {
      if (test.enabled && test.failed()) {
        return true;
      }
    }
    return false;
  }
}

export class TestSuite {
  title: string;
  path: string;
  test_cases: Array<TestCase>;
  coverage: any;

  constructor(item: TestSuite) {
    this.title = item.title;
    this.path = item.path;
    this.coverage = item.coverage;
    this.test_cases = item.test_cases.map(item => new TestCase(item));
  }
}

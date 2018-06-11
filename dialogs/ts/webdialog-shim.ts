import SketchUp from './sketchup'
import { TestSuite } from './types';

export class WebDialogShim implements SketchUp {
  changeActiveTestSuite(test_suite_title: string): void {
    this.sketchup('changeActiveTestSuite', [test_suite_title]);
  }
  discoverTests(test_suites: Array<TestSuite>): void {
    this.sketchup('test_suites', [test_suites]);
  }
  js_error(error_data: any): void
  {
    this.sketchup('js_error', [error_data]);
  }
  ready(): void
  {
    this.sketchup('ready');
  }
  reRunTests(): void
  {
    this.sketchup('reRunTests');
  }
  runTests(test_suite: TestSuite): void
  {
    this.sketchup('runTests', [test_suite]);
  }

  private sketchup(callback: string, params?: Array<any>) {
    let location = `skp:${callback}`;
    if (typeof(params) !== 'undefined') {
      let json_params = JSON.stringify(params);
      // We cannot pass enough data via the skp: protocol.
      // So we put the data into a hidden <textarea> element and fetch its value
      // from the Ruby side.
      let bridge: any = document.getElementById('suBridge');
      if (!bridge) {
        // Create the bridge element on demand so it's not needed to be coded
        // into the HTML document itself.
        bridge = document.createElement('textarea')
        bridge.id = 'suBridge';
        bridge.style.display = 'none';
        document.body.appendChild(bridge);
      }
      bridge.value = json_params;
      location = location.concat(`@true`);
    }
    // In order to be able to debug the dialogs in a normal browser we log to
    // the console instead of trying to use the skp: protocol.
    if (window.navigator.userAgent.indexOf('SketchUp') < 0) {
      console.log(location);
    } else {
      window.location.href = location;
    }
  }
}

declare global {
  interface Window { sketchup: any; }
}

// TODO(thomthom): This doesn't work. Need to do this in the file that includes
// this shim. Look for ways to make this automatic when the file is included.
// if (!window.sketchup) {
//   window.sketchup = new WebDialogShim;
// }

/*******************************************************************************
 *
 * Copyright 2013-2014 Trimble Inc.
 * License: The MIT License (MIT)
 *
 ******************************************************************************/

/*******************************************************************************
 *
 * module TestUp
 *
 ******************************************************************************/

var TestUp = function() {

  var debugger_ = false;
  var path_ = {};

  // Public
  return {


    init :  function(config) {
      debugger_ = config.debugger;
      path_ = config.path;
      init_error_catching();
      init_css(path_);
      TestUp.Toolbar.init(config);
      TestUp.Tabs.init();
      TestUp.TestSuites.init(config);
      TestUp.Statusbar.init();
    },


    reset :  function(config) {
      TestUp.TestSuites.reset();
    },


    // TODO: Move to TestSuites.
    update_results : function(results) {
      var testsuite = TestUp.TestSuites.active();
      var num_tests = results.length;
      var total_time = 0;
      var num_passed = 0;
      var num_failed = 0;
      var num_errors = 0;
      var num_skipped = 0;

      for (var i = 0; i < results.length; ++i)
      {
        var result = results[i];

        total_time += result.time;
        if (result.passed)  ++num_passed;
        if (result.failed)  ++num_failed;
        if (result.error)   ++num_errors;
        if (result.skipped) ++num_skipped;

        TestUp.Test.update_result(result);
      }
      TestUp.TestSuite.update_results();

      var total_time_formatted = total_time.toFixed(3) + 's';
      TestUp.Statusbar.text(
        num_tests + ' tests from test suite "' + testsuite +
        '" run in ' + total_time_formatted + '. ' +
        num_passed  + ' passed, ' +
        num_failed  + ' failed, ' +
        num_errors  + ' errors, ' +
        num_skipped + ' skipped' +
        ' - ' + new Date().toLocaleTimeString()
      );
      // Restore the wait cursor.
      $('body').css('cursor', 'default');
    },


    escape_html : function(string) {
      var html = string.replace(/&/g, "&amp;");
      html = html.replace(/</g, "&lt;").replace(/>/g, "&gt;");
      return html;
    },


    debug : function(output) {
      Sketchup.callback('TestUp.Console.output', output);
    }


  };
  // Private


  function init_css(testup_path) {
    $('<link/>', {
       rel: 'stylesheet',
       type: 'text/css',
       href: testup_path + '/css/testup.css'
    }).appendTo('head');
  }


  var debugger_activated = false;
  function init_error_catching() {
    window.onerror = function(message, location, linenumber, error) {
      if (!debugger_)
      {
        // Trigger an request to attach debugger.
        debugger;
        debugger_ = true;
        Sketchup.callback('TestUp.on_script_debugger_attached');
      }
      return false;
    };
  }


}(); // TestUp


function assert(value)
{
  if (!value)
  {
    // Helper variable to extract the HTML content when breaking.
    var html = $('body').html();
    debugger;
  }
}

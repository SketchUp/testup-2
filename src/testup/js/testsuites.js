/*******************************************************************************
 *
 * module TestUp.TestSuites
 *
 ******************************************************************************/

var TestUp = TestUp || {};

TestUp.TestSuites = function() {

  // Data structure containing the testsuites, testcases, and tests.
  var testsuites_ = {};

  var last_active_tab_ = null;

  // Public
  return {


    init :  function(config) {
      last_active_tab_ = config.active_tab;

      var $testsuites = $('<div id="testsuites"/>');
      $('body').append($testsuites);

      // Toggle test cases on/off.
      // * Check/uncheck tests belonging to the testcase.
      $(document).on('change', '.testcase > .title input[type=checkbox]',
        function(event)
      {
        event.stopPropagation();
        var $checkbox = $(this);
        var checked = $checkbox.prop('checked');
        var $testcase = $checkbox.parents('.testcase');
        var $tests = $testcase.find('input[type=checkbox]');
        $tests.prop('checked', checked);
      });

      // Toggle tests on/off.
      // * Remove checkmark from testcase when induvidual tests are checked.
      $(document).on('change', '.test > .title input[type=checkbox]',
        function(event)
      {
        event.stopPropagation();
        var $checkbox = $(this);
        var checked = $checkbox.prop('checked');
        var $testcase = $checkbox.parents('.testcase');
        var $title = $testcase.children('.title');
        var $testcase_checkbox = $title.find('input[type=checkbox]');
        $testcase_checkbox.prop('checked', false);
      });

      // This is needed to block the roll up/down event of the parent title
      // element from triggering when clicking the checkbox.
      $(document).on('click', '#testsuites input[type=checkbox]',
        function(event)
      {
        event.stopPropagation();
      });

      // Roll up/down
      $(document).on('click', '#testsuites .title',
        function(event)
      {
        var $parent = $(this).parent();
        var $container = $parent.children('.container');
        $container.slideToggle('fast');
      });
    },


    active : function() {
      return TestUp.Tabs.selected();
    },


    activate : function(testsuite_name) {
      // Change tab.
      var $tab = TestUp.Tabs.select(testsuite_name);
      last_active_tab_ = $.trim( $tab.text() );
      var $testsuite = testsuite_from_name(last_active_tab_);
      // Update coverage.
      var coverage = $testsuite.data('coverage');
      if (coverage === undefined)
      {
        $('#summary_coverage').hide();
      }
      else
      {
        $('#summary_coverage span').text( Math.round(coverage) + '%' );
        $('#summary_coverage').show();
      }
      // Display testsuite data.
      assert($testsuite.length);
      $('.testsuite').removeClass('active');
      $testsuite.addClass('active');
      TestUp.TestSuite.update_summary();
    },


    count : function() {
      return TestUp.Tabs.count();
    },


    update : function(testsuites) {
      testsuites_ = testsuites;
      for (testsuite_name in testsuites_)
      {
        var testsuite = testsuites_[testsuite_name];
        var testsuite_data = testsuite.testcases;
        ensure_tab_exists(testsuite_name);
        $testsuite = ensure_testsuite_exists(testsuite_name);
        update_missing_coverage($testsuite, testsuite);
        TestUp.TestSuite.update($testsuite, testsuite_data);
      }
      TestUp.TestSuites.activate(last_active_tab_);
      TestUp.TestSuite.update_results(false);
      update_discovered_status(testsuites);
    }


  };


  // Private


  function update_missing_coverage($testsuite, testsuite)
  {
    var missing = testsuite.missing_coverage;
    if (Object.keys(missing).length > 0)
    {
      $testsuite.data('coverage', testsuite.coverage);
    }
    for (testcase_name in missing)
    {
      var tests = missing[testcase_name];
      $testcase = TestUp.TestCase.ensure_exist($testsuite, testcase_name);
      for (var i = 0; i < tests.length; ++i)
      {
        var test_name = tests[i];
        var $test = TestUp.Test.ensure_exist($testcase, test_name);
        $test.addClass('missing');
      }
    }
  }


  function update_discovered_status(testsuites)
  {
    var num_testsuites = 0;
    var num_testcases = 0;
    var num_tests = 0;

    for (testsuite_name in testsuites)
    {
      var testsuite = testsuites[testsuite_name];
      var testsuite_data = testsuite.testcases;
      ++num_testsuites;
      for (testcase_name in testsuite_data)
      {
        ++num_testcases;
        var tests = testsuite_data[testcase_name];
        num_tests += tests.length;
      }
    }

    TestUp.Statusbar.text(
      num_testsuites + ' test suites, ' +
      num_testcases + ' test cases, ' +
      num_tests + ' tests discovered - ' +
      new Date().toLocaleTimeString()
    );
  }


  function ensure_testsuite_exists(testsuite_name) {
    var $testsuite = testsuite_from_name(testsuite_name);
    if ($testsuite.length == 0)
    {
      var testsuite_id = testsuite_id_from_name(testsuite_name);
      var html = '\
        <div class="testsuite" id="' + testsuite_id + '">\
        </div>\
      ';
      var $testsuite = $(html);
      $('#testsuites').append($testsuite);
    }
    return $testsuite;
  }


  function testsuite_from_name(testsuite_name) {
    var id = testsuite_id_from_name(testsuite_name)
    var $testsuite = $('#' + id);
    return $testsuite;
  }


  function testsuite_id_from_name(testsuite_name) {
    var id_name = testsuite_name.replace(/[^a-z0-9]+/ig, '-');
    return 'suite_' + id_name;
  }


  function ensure_tab_exists(tab_text) {
    var $tab = TestUp.Tabs.get(tab_text);
    if ($tab.length == 0)
    {
      $tab = TestUp.Tabs.add(tab_text);
      $tab.on('click', tab_change);
    }
    assert($tab.length);
    return $tab;
  }


  function tab_change() {
    var $tab = $(this);
    var testsuite_name = $.trim( $tab.text() );
    Sketchup.callback('TestUp.TestSuites.on_change', testsuite_name);
    var testsuite_data = testsuites_[testsuite_name];
    TestUp.TestSuites.activate(testsuite_name, testsuite_data);
  }

}(); // TestUp

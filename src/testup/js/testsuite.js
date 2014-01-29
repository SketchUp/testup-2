/*******************************************************************************
 *
 * module TestUp.TestSuite
 *
 ******************************************************************************/

var TestUp = TestUp || {};

TestUp.TestSuite = function() {

  // Public
  return {


    init :  function(active_tab) {
      var $suite_list = $('<div id="testsuites"/>');
      $('body').append($suite_list);
    },


    selected_tests : function() {
      var testcases = [];
      $(".testsuite.active .testcase > .title .name").each(function() {
        var $testcase_title = $(this);
        var testcase = $testcase_title.text();
        var $checkbox = $testcase_title.find('input[type=checkbox]');
        var checked = $checkbox.prop('checked');
        if (checked)
        {
          // The hash at the end is require to denote the end of the test case
          // name. Otherwise 'TC_Sketchup' would also run 'TC_Sketchup_Edge'
          // because the names are regex'd.
          testcases.push( testcase + '#.+' );
        }
        else
        {
          // Add induvidually selected tests.
          var $testcase = $testcase_title.parents('.testcase');
          $testcase.find('.test').each(function() {
            var $test = $(this);
            var $test_title = $test.children('.title'); // TODO
            var $checkbox = $test_title.find('input[type=checkbox]');
            var test_method = $test_title.text();
            var checked = $checkbox.prop('checked');
            if (checked)
            {
              testcases.push( testcase + '#' + test_method );
            }
          });
        }
      });
      return testcases;
    },


    update : function($testsuite, testsuite_data) {
      for (testcase_name in testsuite_data)
      {
        var $testcase = ensure_testcase_exist($testsuite, testcase_name);
        var tests = testsuite_data[testcase_name];
        TestUp.TestCase.update($testcase, tests);
      }
    },


    update_results : function(roll_up_down) {
      // This method is called when new tests are discovered, but then the view
      // should not be updated.
      if (roll_up_down == undefined) roll_up_down = true;

      var $testcases = $('.testsuite.active .testcase');
      $testcases.each(function() {
        var $testcase = $(this);
        var testcase_name = $testcase.find('> .title .name').text(); // DEBUG
        $testcase.removeClass('passed failed error skipped');

        var $checkbox = $testcase.find('> .title input[type=checkbox]');
        var selected = $checkbox.prop('checked');

        var tests   = $testcase.find('.test').length
        var passed  = $testcase.find('.test.passed').length
        var failed  = $testcase.find('.test.failed').length
        var errors  = $testcase.find('.test.error').length
        var skipped = $testcase.find('.test.skipped').length

        var $metadata = $testcase.find('> .title .metadata');
        $metadata.children('.size').text(tests);
        $metadata.children('.passed').text(passed);
        $metadata.children('.failed').text(failed);
        $metadata.children('.errors').text(errors);
        $metadata.children('.skipped').text(skipped);

        if (failed > 0)
        {
          $testcase.addClass('failed');
        }
        else if (errors > 0)
        {
          $testcase.addClass('error');
        }
        else if (passed > 0)
        {
          $testcase.addClass('passed');
        }

        // Roll down all test cases that have failed tests.
        // Roll up test cases only if they are selected. The user probably
        // rolled it down for a reason.
        if (roll_up_down)
        {
          var selected_failed = $testcase.find('.test.failed :checked').length;
          var selected_errors = $testcase.find('.test.error :checked').length;

          if (failed > 0 || errors > 0)
          {
            // Only unroll if tests that ran failed. This allow the user to roll
            // up failed tests while focusing on a sub-set.
            if (selected_failed > 0 || selected_errors > 0)
            {
              $testcase.find('.tests').slideDown('fast');
            }
          }
          else if (selected)
          {
            $testcase.find('.tests').slideUp('fast');
          }
        }
      });
    }


  };


  // Private


  function testcase_from_name(testcase_name) {
    return $('#' + testcase_name);
  }


  function ensure_testcase_exist($testsuite, testcase_name) {
    var $testcase = testcase_from_name(testcase_name);
    if ($testcase.length == 0)
    {
      var $testcase = $('<div class="testcase" />').attr({
        'class' : 'testcase',
        'id' : testcase_name,
      });

      var $title = $('<div class="title" />')

      var $checkbox = $('<input type="checkbox" checked />');
      $title.append($checkbox);

      var $name = $('<span class="name" />');
      $name.text(testcase_name);
      $title.append($name);

      var $metadata = $('<span class="metadata" />');
      $metadata.append('(');
      $metadata.append('Tests: <span title="Tests" class="size">0</span>, ');
      $metadata.append('Passed: <span title="Passed" class="passed">0</span>, ');
      $metadata.append('Failed: <span title="Failed" class="failed">0</span>, ');
      $metadata.append('Errors: <span title="Errors" class="errors">0</span>, ');
      $metadata.append('Skipped: <span title="Skipped" class="skipped">0</span>');
      $metadata.append(')');
      $title.append($metadata);

      $testcase.append($title);

      var $tests = $('<div class="tests container" />')
      $testcase.append($tests);

      $testsuite.append($testcase);
    }
    assert($testcase.length);
    return $testcase;
  }


}(); // TestUp

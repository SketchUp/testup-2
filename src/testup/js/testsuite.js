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
      $(".testsuite.active .testcase > .title").each(function() {
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
            var $test_title = $test.children('.title');
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


    update_results : function() {
      var $testcases = $('.testsuite.active .testcase');
      $testcases.each(function() {
        var $testcase = $(this);

        var passed  = $testcase.find('.test.passed').length
        var failed  = $testcase.find('.test.failed').length
        var errors  = $testcase.find('.test.error').length
        var skipped = $testcase.find('.test.skipped').length

        if (failed > 0)
        {
          $testcase.prop('title', 'Failed');
          $testcase.addClass('failed');
        }
        else if (errors > 0)
        {
          $testcase.prop('title', 'Errors');
          $testcase.addClass('error');
        }
        else if (passed > 0)
        {
          $testcase.prop('title', 'Passed');
          $testcase.addClass('passed');
        }

        if (failed > 0 || errors > 0)
        {
          $testcase.find('.tests').slideDown('fast');
        }
        else
        {
          $testcase.find('.tests').slideUp('fast');
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
      var $label = $('<label/>');
      var $checkbox = $('<input type="checkbox" checked />');
      $label.text(testcase_name);
      $label.prepend($checkbox);
      $title.append($label);
      $testcase.append($title);

      var $tests = $('<div class="tests" />')
      $testcase.append($tests);

      $testsuite.append($testcase);
    }
    assert($testcase.length);
    return $testcase;
  }


}(); // TestUp

/*******************************************************************************
 *
 * module TestUp.TestCases
 *
 ******************************************************************************/

var TestUp = TestUp || {};

TestUp.TestCases = function() {

  // Public
  return {


    init :  function() {
      var $testcase_list = $('<div id="testcases"/>');
      $('body').append($testcase_list);

      // Toggle test cases on/off.
      // * Check/uncheck tests belonging to the testcase.
      $(document).on('change', '.testcase > .title input[type=checkbox]',
        function()
      {
        var $checkbox = $(this);
        var checked = $checkbox.prop('checked');
        var $testcase = $checkbox.parents('.testcase');
        var $tests = $testcase.find('input[type=checkbox]');
        $tests.prop('checked', checked);
      });

      // Toggle tests on/off.
      // * Remove checkmark from testcase when induvidual tests are checked.
      $(document).on('change', '.test > .title input[type=checkbox]',
        function()
      {
        var $checkbox = $(this);
        var checked = $checkbox.prop('checked');
        var $testcase = $checkbox.parents('.testcase');
        var $title = $testcase.children('.title');
        var $testcase_checkbox = $title.find('input[type=checkbox]');
        $testcase_checkbox.prop('checked', false);
      });
    },


    update : function(testsuite_name, testcases) {
      $('.testsuite').removeClass('active');
      var $testsuite = testsuite_from_name(testsuite_name);
      if ($testsuite.length)
      {
        $testsuite.addClass('active');
        return;
      }
      //$testsuite.empty();
      $testsuite = create_testsuite_view(testsuite_name)
      for (testcase_name in testcases)
      {
        var tests = testcases[testcase_name];

        var $testcase = $('<div class="testcase" />')
        $testcase.attr('id', testcase_id(testcase_name));

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

        update_tests($testcase, tests);
      }
      $testsuite.addClass('active');
    },


    update_results : function(results) {
      for (var i = 0; i < results.length; ++i)
      {
        update_test_result(results[i]);
      }
      update_testcase_results();
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


  };
  // Private


  // Convert the test name from Ruby to an HTML id value.
  function testcase_id(testcase_name) {
    // Convert "TC_TestCase#test_method_name" to
    //         "TC_TestCase.test_method_name".
    return testcase_name.replace('#', '.');
  }


  function get_test_by_name(testname) {
    var id = testcase_id(testname);
    var selector_id = id.replace('.', '\\.');
    var $test = $('#' + selector_id);
    assert($test.length > 0);
    return $test;
  }


  function update_tests($testcase, tests) {
    var testcase_id = $testcase.attr('id');
    var $tests = $testcase.children('.tests');
    for (index in tests)
    {
      // Remove the first character of the name as the array from Ruby is
      // made out of Symbol objects. Don't want to display the colon.
      var test_name = tests[index].slice(1);

      var $test = $('<div class="test" />')
      $test.attr('id', testcase_id + '\.' + test_name);
      var $title = $('<div class="title" />')
      var $label = $('<label/>');
      var $checkbox = $('<input type="checkbox" checked />');
      $label.text(test_name);
      $label.prepend($checkbox);
      $title.append($label);

      $test.append($title);
      $tests.append($test);
    }
  }


  function update_test_result(result) {
    var $test = get_test_by_name(result.testname);
    if (result.passed)
    {
      $test.prop('title', 'Passed');
      $test.addClass('passed');
    }
    else
    {
      if (result.skipped)
      {
        $test.prop('title', 'Skipped');
        $test.addClass('skipped');
      }
      else if (result.error)
      {
        $test.prop('title', 'Errors');
        $test.addClass('error');
      }
      else
      {
        $test.prop('title', 'Failed');
        $test.addClass('failed');
      }
      update_failures($test, result);
    }
    $test.prop('title', $test.prop('title') + ' - ' + result.testname);
  }


  function update_failures($test, result) {
    // Ensure old failure messages are removed.
    $test.find('.failures').detach();

    if (result.skipped || result.failures.length == 0)
    {
      return;
    }

    var $failures = $('<div class="failures" />');

    for (var i = 0; i < result.failures.length; ++i)
    {
      var failure = result.failures[i];
      var $failure = $('<div class="failure" />');

      var $location = $('<a/>', {
        title: 'Click to open file in editor',
        href: failure.location
      });
      $location.text(failure.location);
      $location.on('click', function() {
        var location = $(this).attr('href');
        Sketchup.callback('TestUp.on_open_source_file', location);
        return false;
      });
      $failure.append($location);

      var $message = $('<pre/>');
      $message.text(failure.message);
      $failure.append($message);

      $failures.append($failure);
    }
    $test.append($failures);
  }


  function update_testcase_results() {
    var $testcases = $('.testcase');
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
    });
  }


  function testsuite_from_name(testsuite_name) {
    var id_name = testsuite_name.replace(/[^a-z0-9]+/ig, '-');
    var $testsuite = $('#suite_' + id_name);
    /*if ($testsuite.length == 0)
    {
      debugger;
      $testsuite = $('<div class="testsuite"/>').attr({
        id: 'suite_' + id_name
      });
      $('#testcases').append($testsuite);
    }*/
    return $testsuite;
  }


  function create_testsuite_view(testsuite_name) {
    var id_name = testsuite_name.replace(/[^a-z0-9]+/ig, '-');
    assert( $('#suite_' + id_name).length == 0 );
    $testsuite = $('<div class="testsuite"/>').attr({
      id: 'suite_' + id_name
    });
    $('#testcases').append($testsuite);
    return $testsuite;
  }


}(); // TestUp

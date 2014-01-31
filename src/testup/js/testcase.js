/*******************************************************************************
 *
 * module TestUp.TestCase
 *
 ******************************************************************************/

var TestUp = TestUp || {};

TestUp.TestCase = function() {

  // Public
  return {


    init :  function(active_tab) {
      var $suite_list = $('<div id="testsuites"/>');
      $('body').append($suite_list);
    },


    update : function($testcase, tests) {

      var $tests = $testcase.children('.tests');
      for (index in tests)
      {
        // Remove the first character of the name as the array from Ruby is
        // made out of Symbol objects. Don't want to display the colon.
        var test_name = tests[index].slice(1);
        TestUp.Test.ensure_exist($testcase, test_name);
      }
    },


    ensure_exist : function($testsuite, testcase_name) {
      var $testcase = TestUp.TestCase.from_name(testcase_name);
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
    },


    from_name : function(testcase_name) {
      return $('#' + testcase_name);
    }


  };


  // Private


}(); // TestUp

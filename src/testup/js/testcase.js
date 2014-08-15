/*******************************************************************************
 *
 * Copyright 2013-2014 Trimble Navigation Ltd.
 * License: The MIT License (MIT)
 *
 ******************************************************************************/

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
        var html = '\
          <div class="testcase" id="' + testcase_name + '">\
            <div class="title">\
              <input type="checkbox" checked />\
              <span class="name">\
                ' + testcase_name + '\
              </span>\
              <span class="metadata">\
                (\
                Tests: <span title="Tests" class="size">0</span>,\
                Passed: <span title="Passed" class="passed">0</span>,\
                Failed: <span title="Failed" class="failed">0</span>,\
                Errors: <span title="Errors" class="errors">0</span>,\
                Skipped: <span title="Skipped" class="skipped">0</span>\
                )\
              </span>\
            </div>\
            <div class="tests container" />\
          </div>\
        ';
        var $testcase = $(html);
        insert_in_order($testsuite, $testcase, testcase_name);
      }
      assert($testcase.length);
      return $testcase;
    },


    from_name : function(testcase_name) {
      return $('#' + testcase_name);
    }


  };


  // Private

  function insert_in_order($testsuite, $new_testcase, testcase_name)
  {
    var $testcases = $testsuite.find('.testcase');
    for (var i = 0; i < $testcases.length; ++i)
    {
      var $testcase = $testcases.eq(i);
      var name = $.trim( $testcase.find('> .title .name').text() );
      if (testcase_name < name)
      {
        $new_testcase.insertBefore($testcase);
        return;
      }
    }
    $testsuite.append($new_testcase);
  }


}(); // TestUp

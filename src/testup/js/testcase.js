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
        ensure_test_exist($testcase, test_name);
      }
    }


  };


  // Private

  function ensure_test_exist($testcase, test_name) {
    var full_name = full_test_name($testcase, test_name);
    var $test = TestUp.Test.get_element_by_name(full_name);
    if ($test.length == 0)
    {
      var testcase_id = $testcase.attr('id');
      $test = $('<div/>').attr({
        'class' : 'test',
        'id' : testcase_id + '\.' + test_name,
      });

      var $title = $('<div class="title" />')
      var $label = $('<label/>');

      var $checkbox = $('<input type="checkbox" checked />');
      $label.append($checkbox);

      var $name = $('<span class="name" />');
      $name.text(test_name);
      $label.append($name);

      $title.append($label);

      $test.append($title);
      $testcase.children('.tests').append($test);
    }
    assert($test.length);
    return $test;
  }


  function full_test_name($testcase, test_name) {
    var testcase_id = $testcase.attr('id');
    return testcase_id + '#' + test_name;
  }


}(); // TestUp

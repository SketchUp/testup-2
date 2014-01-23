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


  };


  // Private


}(); // TestUp

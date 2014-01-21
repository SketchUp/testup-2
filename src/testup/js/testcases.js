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


    update : function(testcases) {
      var $testcases = $('#testcases');
      $testcases.empty();
      for (testcase_name in testcases)
      {
        var tests = testcases[testcase_name];

        var $testcase = $('<div class="testcase" />')
        var $title = $('<div class="title" />')
        var $label = $('<label/>');
        var $checkbox = $('<input type="checkbox" checked />');
        $label.text(testcase_name);
        $label.prepend($checkbox);
        $title.append($label);
        $testcase.append($title);
        $testcases.append($testcase);

        update_tests($testcase, tests);
      }
    },


    selected_tests : function() {
      var testcases = [];
      $(".testcase > .title").each(function() {
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


  function update_tests($testcase, tests) {
    for (index in tests)
    {
      // Remove the first character of the name as the array from Ruby is
      // made out of Symbol objects. Don't want to display the colon.
      var test_name = tests[index].slice(1);

      var $test = $('<div class="test" />')
      var $title = $('<div class="title" />')
      var $label = $('<label/>');
      var $checkbox = $('<input type="checkbox" checked />');
      $label.text(test_name);
      $label.prepend($checkbox);
      $title.append($label);

      $test.append($title);
      $testcase.append($test);
    }
  }


}(); // TestUp

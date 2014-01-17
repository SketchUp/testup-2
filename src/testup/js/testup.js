/*******************************************************************************
 *
 * module TestUp
 *
 ******************************************************************************/

var TestUp = function() {

  var testsuites_ = {};

  return {


    init :  function(testup_path) {
      $('<link/>', {
         rel: 'stylesheet',
         type: 'text/css',
         href: testup_path + '/css/testup.css'
      }).appendTo('head');

      var $body = $('body');

      var $suite_list = $('<div id="testsuites"/>');
      $body.append($suite_list);

      var $testcase_list = $('<div id="testcases"/>');
      $body.append($testcase_list);

      TestUp.init_tabs();
      TestUp.init_testcase_checkboxes();
    },


    init_tabs :  function() {
      $(document).on('click', '#testsuites .tab', function() {
        $('#testsuites .tab').removeClass('selected');
        var $tab = $(this);
        $tab.addClass('selected');
        var testcase_name = $tab.text();
        var testcases = testsuites_[testcase_name];
        TestUp.update_testcases(testcases);
      });
    },


    init_testcase_checkboxes :  function() {
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


    selected_testcases : function() {
      var testcases = $(".testcase > .title").map(function() {
        return $(this).text();
      }).get();
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
              testcases.push( testcase + '#' + test_method);
            }
          });
        }
      });
      return testcases;
    },


    update_testsuites : function(testsuites) {
      testsuites_ = testsuites;

      var $testsuites = $('#testsuites');
      $testsuites.empty();
      for (suite_name in testsuites)
      {
        var testcases = testsuites[suite_name];

        var $tab = $('<div class="tab" />')
        $tab.text(suite_name);
        $testsuites.append($tab);
      }
      // Select first tab and display test cases for that suite.
      $tabs = $('#testsuites .tab');
      if ($tabs.length > 0)
      {
        var $tab = $tabs.first();
        $tab.addClass('selected');
        var first_testsuite = $tab.text();
        var testcases = testsuites[first_testsuite];
        TestUp.update_testcases(testcases);
      }
      else
      {
        $('#testcases').empty();
      }

    },


    update_testcases : function(testcases) {
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

        TestUp.update_tests($testcase, tests);
      }
    },


    update_tests : function($testcase, tests) {
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


  };

}(); // TestUp

Sketchup.callback('TestUp.on_ready')

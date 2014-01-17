//alert('Hello TestUp World!');
//debugger;


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


    selected_testcases : function() {
      var testcases = $(".testcase > .title").map(function() {
        return $(this).text();
      }).get();
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

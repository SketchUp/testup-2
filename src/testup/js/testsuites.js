/*******************************************************************************
 *
 * module TestUp.TestSuites
 *
 ******************************************************************************/

var TestUp = TestUp || {};

TestUp.TestSuites = function() {

  // Data structure containing the testsuites, testcases, and tests.
  var testsuites_ = {};

  var last_active_tab_ = null;

  // Public
  return {


    init :  function(config) {
      last_active_tab_ = config.active_tab;

      var $suite_list = $('<div id="testsuites"/>');
      $('body').append($suite_list);

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


    active : function() {
      return TestUp.Tabs.selected();
    },


    activate : function(testsuite_name) {
      TestUp.Tabs.select(testsuite_name);
      var $testsuite = testsuite_from_name(testsuite_name);
      assert($testsuite.length);
      $('.testsuite').removeClass('active');
      $testsuite.addClass('active');
    },


    update : function(testsuites) {
      testsuites_ = testsuites;
      for (testsuite_name in testsuites_)
      {
        var testsuite_data = testsuites_[testsuite_name];
        ensure_tab_exists(testsuite_name);
        $testsuite = ensure_testsuite_exists(testsuite_name);
        TestUp.TestSuite.update($testsuite, testsuite_data);
      }
      TestUp.TestSuites.activate(last_active_tab_);
    },


  };


  // Private


  function ensure_testsuite_exists(testsuite_name) {
    var $testsuite = testsuite_from_name(testsuite_name);
    if ($testsuite.length == 0)
    {
      $testsuite = $('<div/>').attr({
        'class': 'testsuite',
        'id': testsuite_id_from_name(testsuite_name)
      });
      $('#testsuites').append($testsuite);
    }
    return $testsuite;
  }


  function testsuite_from_name(testsuite_name) {
    var id = testsuite_id_from_name(testsuite_name)
    var $testsuite = $('#' + id);
    return $testsuite;
  }


  function testsuite_id_from_name(testsuite_name) {
    var id_name = testsuite_name.replace(/[^a-z0-9]+/ig, '-');
    return 'suite_' + id_name;
  }


  function ensure_tab_exists(tab_text) {
    var $tab = TestUp.Tabs.get(tab_text);
    if ($tab.length == 0)
    {
      $tab = TestUp.Tabs.add(tab_text);
      $tab.on('click', tab_change);
    }
    assert($tab.length);
    return $tab;
  }


  function tab_change() {
    var $tab = $(this);
    var testsuite_name = $tab.text();
    Sketchup.callback('TestUp.TestSuites.on_change', testsuite_name);
    var testsuite_data = testsuites_[testsuite_name];
    TestUp.TestSuites.activate(testsuite_name, testsuite_data);
  }

}(); // TestUp

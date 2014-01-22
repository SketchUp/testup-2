/*******************************************************************************
 *
 * module TestUp.TestSuites
 *
 ******************************************************************************/

var TestUp = TestUp || {};

TestUp.TestSuites = function() {

  var testsuites_ = {};
  var last_active_tab_ = null;

  // Public
  return {


    init :  function(active_tab) {
      last_active_tab_ = active_tab;
      var $suite_list = $('<div id="testsuites"/>');
      $('body').append($suite_list);

      $(document).on('click', '#testsuites .tab', function() {
        $('#testsuites .tab').removeClass('selected');
        var $tab = $(this);
        $tab.addClass('selected');
        var testsuite_name = $tab.text();
        Sketchup.callback('TestUp.TestSuites.on_change', testsuite_name);
        var testcases = testsuites_[testsuite_name];
        TestUp.TestCases.update(testsuite_name, testcases);
      });
    },


    selected : function() {
      return $("#testsuites .tab.selected").text();
    },


    update : function(testsuites) {
      testsuites_ = testsuites;
      var $testsuites = $('#testsuites');
      $testsuites.empty();
      for (suite_name in testsuites_)
      {
        var testcases = testsuites_[suite_name];

        var $tab = $('<div class="tab" />')
        $tab.text(suite_name);
        $testsuites.append($tab);
      }
      activate_tab();
    }


  };

  // Private

  function activate_tab() {
    $tabs = $('#testsuites .tab');
    if ($tabs.length > 0)
    {
      var $tab = $('#testsuites .tab:contains("' + last_active_tab_ + '")');
      if ($tab.length == 0)
      {
        $tab = $tabs.first();
      }
      $tab.addClass('selected');
      var testsuite_name = $tab.text();
      var testcases = testsuites_[testsuite_name];
      TestUp.TestCases.update(testsuite_name, testcases);
    }
    else
    {
      // TODO(thomthom): Merge with TestUp.update_testcases. Rename to
      // TestUp.TestCases.display(testsuite);
      //$('#testcases').empty();
    }
  }

}(); // TestUp

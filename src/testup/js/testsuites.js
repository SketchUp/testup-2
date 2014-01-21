/*******************************************************************************
 *
 * module TestUp.TestSuites
 *
 ******************************************************************************/

var TestUp = TestUp || {};

TestUp.TestSuites = function() {

  var testsuites_ = {};

  // Public
  return {


    init :  function() {
      var $suite_list = $('<div id="testsuites"/>');
      $('body').append($suite_list);

      $(document).on('click', '#testsuites .tab', function() {
        $('#testsuites .tab').removeClass('selected');
        var $tab = $(this);
        $tab.addClass('selected');
        var testcase_name = $tab.text();
        var testcases = testsuites_[testcase_name];
        TestUp.TestCases.update(testcases);
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
      //var $tab = $tabs.first();
      var $tab = $('#testsuites .tab:contains("TestUp")'); // DEBUG
      $tab.addClass('selected');
      var first_testsuite = $tab.text();
      var testcases = testsuites_[first_testsuite];
      TestUp.TestCases.update(testcases);
    }
    else
    {
      // TODO(thomthom): Merge with TestUp.update_testcases. Rename to
      // TestUp.TestCases.display(testsuite);
      $('#testcases').empty();
    }
  }

}(); // TestUp

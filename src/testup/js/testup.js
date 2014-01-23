/*******************************************************************************
 *
 * module TestUp
 *
 ******************************************************************************/

var TestUp = function() {

  var debugger_ = false;
  var path_ = {};

  // Public
  return {


    init :  function(config) {
      debugger_ = config.debugger;
      path_ = config.path;
      init_error_catching();
      init_css(path_);
      TestUp.Toolbar.init(config);
      TestUp.Tabs.init();
      TestUp.TestSuites.init(config);
    },


    update_results : function(results) {
      for (var i = 0; i < results.length; ++i)
      {
        TestUp.Test.update_result(results[i]);
      }
      TestUp.TestSuite.update_results();
    }


  };
  // Private


  function init_css(testup_path) {
    $('<link/>', {
       rel: 'stylesheet',
       type: 'text/css',
       href: testup_path + '/css/testup.css'
    }).appendTo('head');
  }


  var debugger_activated = false;
  function init_error_catching() {
    window.onerror = function(message, location, linenumber, error) {
      if (!debugger_)
      {
        // Trigger an request to attach debugger.
        debugger;
        debugger_ = true;
        Sketchup.callback('TestUp.on_script_debugger_attached');
      }
      return false;
    };
  }


}(); // TestUp


function assert(value)
{
  if (!value)
  {
    // Helper variable to extract the HTML content when breaking.
    var html = $('body').html();
    debugger;
  }
}

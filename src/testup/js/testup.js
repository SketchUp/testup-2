/*******************************************************************************
 *
 * module TestUp
 *
 ******************************************************************************/

var TestUp = function() {

  var path_ = {};

  // Public
  return {


    init :  function(config) {
      path_ = config.path;
      init_error_catching();
      init_css(path_);
      TestUp.Toolbar.init(path_);
      TestUp.TestSuites.init(config.active_tab);
      TestUp.TestCases.init();
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
    window.onerror = function(message, url, linenumber) {
      if (!debugger_activated)
      {
        // Trigger IE to request if an debugger should be attached.
        debugger;
        debugger_activated = true;
      }
      return false;
    };
  }


}(); // TestUp


function assert(value)
{
  if (!value)
  {
    var html = $('body').html();
    debugger;
  }
}

/*******************************************************************************
 *
 * Copyright 2013-2014 Trimble Navigation Ltd.
 * License: The MIT License (MIT)
 *
 ******************************************************************************/

/*******************************************************************************
 *
 * module TestUp.Statusbar
 *
 ******************************************************************************/

var TestUp = TestUp || {};

TestUp.Commands = function() {

  // Public
  return {


    run_tests :  function() {
      $('body').css('cursor', 'wait');
      // Ugly hack to allow the WebDialog to display the waiting cursor as
      // otherwise it'll not be set until after the tests are run.
      setTimeout(function() {
        Sketchup.callback('TestUp.on_run');
        // The cursor is now restored in TestUp.update_results since the
        // execution of the Ruby command is also deferred to avoid the
        // "Slow running script" dialog warning.
        //$('body').css('cursor', 'default');
      }, 50);
    },


    discover : function() {
      Sketchup.callback('TestUp.on_discover');
    },


    rerun : function() {
      // TODO $('body').css('cursor', 'wait');
      // Ugly hack to allow the WebDialog to display the waiting cursor as
      // otherwise it'll not be set until after the tests are run.
      setTimeout(function() {
        Sketchup.callback('TestUp.on_rerun');
        // The cursor is now restored in TestUp.update_results since the
        // execution of the Ruby command is also deferred to avoid the
        // "Slow running script" dialog warning.
        //$('body').css('cursor', 'default');
      }, 50);
    },


    preferences : function() {
      Sketchup.callback('TestUp.on_preferences');
    },


    select_all : function() {
      $('.testsuite.active .title input').prop('checked', true);
      return false;
    },


    select_none : function() {
      $('.testsuite.active .title input').prop('checked', false);
      return false;
    }


  };

}(); // TestUp

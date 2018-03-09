/*******************************************************************************
 *
 * Copyright 2013-2014 Trimble Inc.
 * License: The MIT License (MIT)
 *
 ******************************************************************************/

/*******************************************************************************
 *
 * module TestUp.Statusbar
 *
 ******************************************************************************/

var TestUp = TestUp || {};

TestUp.Statusbar = function() {

  // Public
  return {


    init :  function() {
      var $statusbar = $('<div id="statusbar"/>');
      $('body').append($statusbar);
    },


    text : function(text) {
      $('#statusbar').text(text);
    }


  };

}(); // TestUp

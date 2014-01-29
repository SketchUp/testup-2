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

/*******************************************************************************
 *
 * module TestUp.Toolbar
 *
 ******************************************************************************/

var TestUp = TestUp || {};

TestUp.Toolbar = function() {

  var MOUSE_BUTTON_LEFT = 1;

  // Public
  return {


    init :  function(config) {
      path = config.path;

      var $toolbar = $('<div id="toolbar"/>');

      $(document).on('mousedown', '#toolbar .button', function() {
        $(this).addClass('pressed');
      });
      $(document).on('mouseup, mouseout', '#toolbar .button', function() {
        $(this).removeClass('pressed');
      });
      $(document).on('mouseover', '#toolbar .button', function(event) {
        if (event.which == MOUSE_BUTTON_LEFT)
        {
          $(this).addClass('pressed');
        }
        else
        {
          $(this).removeClass('pressed');
        }
      });

      var $run = $('<div class="button" id="run" />');
      $run.text('Run');
      $run.attr('title', 'Run selected tests');
      $run.prepend( $('<img src="' + path + '/images/run.png" />') );
      $run.on('click', function() {
        Sketchup.callback('TestUp.on_run');
      });
      $toolbar.append($run);

      var $discover = $('<div class="button" id="discover" />');
      $discover.attr('title', 'Discover/rediscover tests');
      $discover.text('Discover');
      $discover.prepend( $('<img src="' + path + '/images/find.png" />') );
      $discover.on('click', function() {
        Sketchup.callback('TestUp.on_discover');
      });
      $toolbar.append($discover);

      var $logo = $('<div id="logo" />');
      $logo.append( $('<img src="' + path + '/images/sketchup_logo.png" />') );
      $toolbar.append($logo);

      $('body').append($toolbar);
    }


  };

}(); // TestUp

/*******************************************************************************
 *
 * Copyright 2013-2014 Trimble Navigation Ltd.
 * License: The MIT License (MIT)
 *
 ******************************************************************************/

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
        TestUp.Commands.run_tests();
      });
      $toolbar.append($run);

      var $discover = $('<div class="button" id="discover" />');
      $discover.text('Discover');
      $discover.attr('title', 'Discover/rediscover tests');
      $discover.prepend( $('<img src="' + path + '/images/find.png" />') );
      $discover.on('click', function() {
        TestUp.Commands.discover();
      });
      $toolbar.append($discover);

      var $rerun = $('<div class="button" id="rerun" />');
      $rerun.text('Re-run...');
      $rerun.attr('title', 'Rerun tests');
      $rerun.prepend( $('<img src="' + path + '/images/rerun.png" />') );
      $rerun.on('click', function() {
        TestUp.Commands.rerun();
      });
      $toolbar.append($rerun);

      var $preferences = $('<div/>').attr({
        'class' : 'button panel',
        'id'    : 'preferences',
        'title' : 'Preferences'
      });
      $preferences.append( $('<img src="' + path + '/images/preferences.png" />') );
      $preferences.on('click', function() {
        TestUp.Commands.preferences();
      });
      $toolbar.append($preferences);

      var $errors = $('<div/>').attr({
        'class' : 'panel',
        'id'    : 'summary_error_tests',
        'title' : 'Number of tests with errors'
      });
      $errors.append('<span>0</span>');
      $toolbar.append($errors);

      var $failed = $('<div/>').attr({
        'class' : 'panel',
        'id'    : 'summary_failed_tests',
        'title' : 'Number of failed tests'
      });
      $failed.append('<span>0</span>');
      $toolbar.append($failed);

      var $passed = $('<div/>').attr({
        'class' : 'panel',
        'id'    : 'summary_passed_tests',
        'title' : 'Number of passed tests'
      });
      $passed.append('<span>0</span>');
      $toolbar.append($passed);

      var $total = $('<div/>').attr({
        'class' : 'panel',
        'id'    : 'summary_total_tests',
        'title' : 'Total number of tests'
      });
      $total.append('<span>0</span>');
      $toolbar.append($total);

      var $coverage = $('<div/>').attr({
        'class' : 'panel',
        'id'    : 'summary_coverage',
        'title' : 'Percent coverage'
      });
      $coverage.hide();
      $coverage.append('<span>0</span>');
      $toolbar.append($coverage);

      $('body').append($toolbar);
    }


  };

}(); // TestUp

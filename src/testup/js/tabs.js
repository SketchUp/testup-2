/*******************************************************************************
 *
 * Copyright 2013-2014 Trimble Inc.
 * License: The MIT License (MIT)
 *
 ******************************************************************************/

/*******************************************************************************
 *
 * module TestUp.Tabs
 *
 ******************************************************************************/

var TestUp = TestUp || {};

TestUp.Tabs = function() {

  // Public
  return {


    init :  function() {
      var $tabs = $('<div id="tabs"/>');
      $('body').append($tabs);

      $(document).on('click', '#tabs .tab', function() {
        var $tab = $(this);
        assert($tab.length);
        select_tab($tab);
      });
    },


    add : function(tab_text) {
      var $tabs = $('#tabs');
      var $tab = $('<div class="tab" />')
      $tab.text(tab_text);
      $tabs.append($tab);
      return $tab;
    },


    count : function() {
      return $('#tabs .tab').length;
    },


    get : function(tab_text) {
      return $('#tabs .tab').filter(function() {
          return $.trim( $(this).text() ) === tab_text;
      });
    },


    select : function(tab_text) {
      var $tab;
      if (tab_text == null)
      {
        $tab = $("#tabs .tab").first();
      }
      else
      {
        $tab = TestUp.Tabs.get(tab_text);
      }
      if ($tab.length)
      {
        select_tab($tab);
      }
      else
      {
        $tab = $("#tabs .tab").first();
      }
      return $tab;
    },


    selected : function() {
      return $.trim( $("#tabs .tab.selected").text() );
    }


  };

  // Private

  function select_tab($tab) {
    $('#tabs .tab').removeClass('selected');
    $tab.addClass('selected');
  }

}(); // TestUp.Tabs

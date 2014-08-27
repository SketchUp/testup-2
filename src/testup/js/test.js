/*******************************************************************************
 *
 * Copyright 2013-2014 Trimble Navigation Ltd.
 * License: The MIT License (MIT)
 *
 ******************************************************************************/

/*******************************************************************************
 *
 * module TestUp.Test
 *
 ******************************************************************************/

var TestUp = TestUp || {};

TestUp.Test = function() {

  // Public
  return {


    init :  function(active_tab) {
      var $suite_list = $('<div id="testsuites"/>');
      $('body').append($suite_list);
    },

    ensure_exist : function($testcase, test_name) {
      var full_name = TestUp.Test.full_name($testcase, test_name);
      var $test = TestUp.Test.get_element_by_name(full_name);
      if ($test.length == 0)
      {
        var testcase_id = $testcase.attr('id');
        var html = TestUp.Test.create_html(testcase_id, test_name)
        var $test = $(html);
        insert_in_order($testcase, $test, test_name);
      }
      assert($test.length);
      return $test;
    },


    create_html : function(testcase_id, test_name) {
      var test_id = testcase_id + '\.' + test_name;

      var html = '\
        <div class="test" id="' + test_id + '">\
          <div class="title">\
            <label>\
              <input type="checkbox" checked />\
              <span class="name">\
                ' + test_name + '\
              </span>\
            </label>\
          </div>\
        </div>\
      ';
      return html;
    },


    full_name : function($testcase, test_name) {
      var testcase_id = $testcase.attr('id');
      return testcase_id + '#' + test_name;
    },


    get_element_by_name : function(testname) {
      var id = id_from_name(testname);
      var selector_id = id.replace('.', '\\.');
      var $test = $('#' + selector_id);
      return $test;
    },


    update_result : function(result) {
      var $test = TestUp.Test.get_element_by_name(result.testname);
      assert($test.length);
      $test.removeClass('passed failed error skipped missing');
      if (result.passed)
      {
        $test.prop('title', 'Passed');
        $test.addClass('passed');
      }
      else
      {
        if (result.skipped)
        {
          $test.prop('title', 'Skipped');
          $test.addClass('skipped');
        }
        else if (result.error)
        {
          $test.prop('title', 'Errors');
          $test.addClass('error');
        }
        else
        {
          $test.prop('title', 'Failed');
          $test.addClass('failed');
        }
      }
      update_metadata($test, result);
      update_failures($test, result);
      $test.prop('title', $test.prop('title') + ' - ' + result.testname);
    },


  };


  // Private


  function insert_in_order($testcase, $new_test, test_name)
  {
    var $tests = $testcase.find('.test');
    for (var i = 0; i < $tests.length; ++i)
    {
      var $test = $tests.eq(i);
      var name = $.trim( $test.find('> .title .name').text() );
      if (test_name < name)
      {
        $new_test.insertBefore($test);
        return;
      }
    }
    $testcase.children('.tests').append($new_test);
  }


  function id_from_name(testcase_name) {
    // Convert "TC_TestCase#test_method_name" to
    //         "TC_TestCase.test_method_name".
    return testcase_name.replace('#', '.');
  }


  function update_metadata($test, result) {
    var $title = $test.children('.title');
    assert($title.length > 0);

    var $name = $title.find('.name');
    assert($name.length > 0);

    var $metadata = $title.find('.metadata');
    if ($metadata.length == 0)
    {
      $metadata = $('<div class="metadata">');
      $metadata.append('( ');
      $metadata.append('Time: <span class="time">0</span>');
      $metadata.append(' )');

      //$name.after($metadata)
      var $label = $title.find('label');
      $label.append($metadata)
    }

    $metadata.find('.time').text(result.time.toFixed(3));
  }


  function update_failures($test, result) {
    // Ensure old failure messages are removed.
    $test.find('.failures').detach();

    if (result.failures.length == 0)
    {
      return;
    }

    var $failures = $('<div class="failures" />');

    for (var i = 0; i < result.failures.length; ++i)
    {
      var failure = result.failures[i];
      var $failure = $('<div class="failure" />');

      var $location = $('<a/>', {
        title: 'Click to open file in editor',
        href: failure.location
      });
      $location.text(failure.location);
      $location.on('click', function() {
        var location = $(this).attr('href');
        Sketchup.callback('TestUp.on_open_source_file', location);
        return false;
      });
      $failure.append($location);

      var $message = $('<pre/>');

      // Create links from file paths.
      var pattern = /^(\s*)(.+\.rb[s]?:\d+)/gm;
      var replacement = "$1<a href='$2' title='Click to open file in editor'>$2</a>";
      var html_message = failure.message.replace(pattern, replacement);
      $message.html(html_message);
      $message.children('a').on('click', function() {
        var location = $(this).attr('href');
        Sketchup.callback('TestUp.on_open_source_file', location);
        return false;
      });

      $failure.append($message);

      $failures.append($failure);
    }
    $test.append($failures);
  }


}(); // TestUp

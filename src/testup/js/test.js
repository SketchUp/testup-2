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


    get_element_by_name : function(testname) {
      var id = id_from_name(testname);
      var selector_id = id.replace('.', '\\.');
      var $test = $('#' + selector_id);
      return $test;
    },


    update_result : function(result) {
      var $test = TestUp.Test.get_element_by_name(result.testname);
      assert($test.length);
      $test.removeClass('passed failed error skipped');
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
      $metadata.append('(');
      $metadata.append('Time: <span class="time">0</span>');
      $metadata.append(')');

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
      $message.text(failure.message);
      $failure.append($message);

      $failures.append($failure);
    }
    $test.append($failures);
  }


}(); // TestUp

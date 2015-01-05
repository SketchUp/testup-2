# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Bugra Barin

require "testup/testcase"

# AppObserver class to test
#
#   Each callback method sends its data back to the unit test class for
#   validation.
#
class TestUpAppObserver < Sketchup::AppObserver
  def onNewModel(model)
    TC_AppObserver.add_callback_data('onNewModel', [model])
  end

  def onOpenModel(model)
    TC_AppObserver.add_callback_data('onOpenModel', [model])
  end

  def onUnloadExtension(ext_name)
    TC_AppObserver.add_callback_data('onUnloadExtension', [ext_name])
  end

  def onActivateModel(model)
    TC_AppObserver.add_callback_data('onActivateModel', [model])
  end

  # How can these be tested?
  def onQuit()
    # ...
  end
  def expectsStartupModelNotifications()
   return true
 end
end

# class AppObserver
# http://www.sketchup.com/intl/en/developer/docs/ourdoc/appobserver
class TC_AppObserver < TestUp::TestCase

  def setup
    disable_read_only_flag_for_test_models()
    @@callback_data = nil
  end

  def teardown
    restore_read_only_flag_for_test_models()
    @@callback_data = nil
  end

  def self.add_callback_data(method, data)
    @@callback_data ||= {}
    @@callback_data[method] ||= []
    @@callback_data[method] << data
  end

  def reset_callback_data
    @@callback_data = nil
  end
  private :reset_callback_data

  def test_add_remove
    test_observer = TestUpAppObserver.new
    retVal = Sketchup.add_observer(test_observer)
    assert_equal(true, retVal, 'Adding the observer failed')
    retVal = Sketchup.add_observer(test_observer)
    assert_equal(true, retVal, 'Adding the observer again failed')

    retVal = Sketchup.remove_observer(test_observer)
    assert_equal(true, retVal, 'Removing the observer failed')
    retVal = Sketchup.remove_observer(test_observer)
    assert_equal(false, retVal, 'Removing the observer again should have failed')
  end


  # ========================================================================== #
  # method AppObserver.onNewModel
  # http://www.sketchup.com/intl/en/developer/docs/ourdoc/appobserver#onNewModel
  def test_onNewModel
    reset_callback_data()

    test_observer = TestUpAppObserver.new
    Sketchup.add_observer(test_observer)

    # Trigger the event.
    open_new_model()
    # Make sure we are only getting the expected callbacks.
    assert(@@callback_data &&
      @@callback_data.has_key?('onNewModel'),
      'onNewModel not called after ' <<
      'creating a new model')
    assert_equal(false, @@callback_data.has_key?('onOpenModel'),
      'onOpenModel callback unexpectedly called ' <<
      'after creating a new model.')
    # Check the number of times the event was triggered.
    data_count = @@callback_data['onNewModel'].length
    assert_equal(1, data_count,
      'onNewModel triggered an unexpected number of times.')
    # Check the callback data.
    data_array = @@callback_data['onNewModel'].last
    # (!) No way to enumerate open SketchUp models, so currently assume that
    #     when the new model is created it becomes the active model.
    assert_equal(Sketchup.active_model, data_array[0],
      'onNewModel returned an incorrect model entity.')
    assert(data_array[0].valid?,
      'onNewModel returned an invalid model entity.')
  ensure
    Sketchup.remove_observer(test_observer)
    close_active_model()
  end

  # ========================================================================== #
  # method AppObserver.onOpenModel
  # http://www.sketchup.com/intl/en/developer/docs/ourdoc/appobserver#onOpenModel
  def test_onOpenModel
    discard_model_changes()
    reset_callback_data()

    test_observer = TestUpAppObserver.new
    Sketchup.add_observer(test_observer)

    # Trigger the event.
    path = File.dirname(__FILE__)
    test_model = File.join(path, 'TC_AppObserver', 'Cube.skp')
    Sketchup.open_file(test_model)
    # Make sure we are only getting the expected callbacks.
    assert(@@callback_data &&
      @@callback_data.has_key?('onOpenModel'),
      'onOpenModel not called ' <<
      'after opening a model')
    assert_equal(false, @@callback_data.has_key?('onNewModel'),
      'onNewModel callback unexpectedly called ' +
      'after opening a model.')
    # Check the number of times the event was triggered.
    data_count = @@callback_data['onOpenModel'].length
    assert_equal(1, data_count,
      'onOpenModel triggered an unexpected number of times.')
    # Check the callback data.
    data_array = @@callback_data['onOpenModel'].last
    # (!) No way to enumerate open SketchUp models, so currently assume that
    #     when the new model is created it becomes the active model.
    assert_equal(Sketchup.active_model, data_array[0],
      'onOpenModel returned an incorrect model entity.')
    assert(data_array[0].valid?,
      'onOpenModel returned an invalid model entity.')
  ensure
    Sketchup.remove_observer(test_observer)
    close_active_model()
  end

  # ========================================================================== #
  # method AppObserver.onUnloadExtension
  # http://www.sketchup.com/intl/en/developer/docs/ourdoc/appobserver#onUnloadExtension
  def test_onUnloadExtension
    reset_callback_data()

    test_observer = TestUpAppObserver.new
    Sketchup.add_observer(test_observer)

    # Trigger the event.
    path = File.dirname(__FILE__)
    dummy_file = File.join(path, 'TC_AppObserver', 'dummy.rb')
    extension = SketchupExtension.new("TC_AppObserver", dummy_file)
    Sketchup.register_extension(extension, true)
    extension.check
    extension.uncheck
    # Make sure we are only getting the expected callbacks.
    assert(@@callback_data &&
      @@callback_data.has_key?('onUnloadExtension'),
      'onUnloadExtension not called ' <<
      'after disabling an extension')
    # Check the number of times the event was triggered.
    data_count = @@callback_data['onUnloadExtension'].length
    assert_equal(1, data_count,
      'onUnloadExtension triggered an unexpected number of times.')
    # Check the callback data.
    data_array = @@callback_data['onUnloadExtension'].last
    assert_equal(extension.name, data_array[0],
      'onUnloadExtension returned an ' <<
      'incorrect name for the unloaded extension.')
  ensure
    Sketchup.remove_observer(test_observer)
  end

  # ========================================================================== #
  # method AppObserver.onActivateModel
  # http://www.sketchup.com/intl/en/developer/docs/ourdoc/appobserver#onActivateModel
  def test_onActivateModel
    reset_callback_data()

    test_observer = TestUpAppObserver.new
    Sketchup.add_observer(test_observer)

    # We don't have a way to change active models programmaticaly
    # so we can't test this automatically quite yet.
  ensure
    Sketchup.remove_observer(test_observer)
  end

  def test_onActivateModel_not_fire_on_file_new
    reset_callback_data()

    test_observer = TestUpAppObserver.new
    Sketchup.add_observer(test_observer)

    # New file should not trigger the method
    open_new_model()

    # Check the callback data.
    data_array = @@callback_data['onActivateModel']
    assert_equal(nil, data_array,
        'onActivateModel should not have been called')
  ensure
    Sketchup.remove_observer(test_observer)
    close_active_model
  end

  def test_onActivateModel_not_fire_on_file_open
    reset_callback_data()

    test_observer = TestUpAppObserver.new
    Sketchup.add_observer(test_observer)

    # Opening a file should not trigger the method
    path = File.dirname(__FILE__)
    test_model = File.join(path, 'TC_AppObserver', 'Cube.skp')
    Sketchup.open_file(test_model)

    # Check the callback data.
    data_array = @@callback_data['onActivateModel']
    assert_equal(nil, data_array,
        'onActivateModel should not have been called')
  ensure
    Sketchup.remove_observer(test_observer)
    close_active_model
  end

end # class

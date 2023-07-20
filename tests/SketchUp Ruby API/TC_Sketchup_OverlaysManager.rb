# Copyright:: Copyright 2022 Trimble Inc.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen

require "testup/testcase"
require_relative "utils/feature_switch"

# class Sketchup::OverlaysManager
class TC_Sketchup_OverlaysManager < TestUp::TestCase

  include TestUp::SketchUpTests::FeatureSwitchHelper

  def self.setup_testcase
    discard_all_models
  end

  def setup
    start_with_empty_model
    clear_mock_overlays
  end

  def teardown
    clear_mock_overlays
  end


  def assert_read_only_error(&block)
    error = assert_raises(RuntimeError, &block)
    message = "no model changes should be made during overlay callbacks"
    assert_equal(message, error.message)
  end

  class MockError < StandardError; end

  # Just making a common base class to make it easier to clean up test overlays.
  class TestOverlay < Sketchup::Overlay
  end if defined?(Sketchup::Overlay)

  class MockOverlay < TestOverlay
    def initialize(id: 'sketchup.testup.overlay-manager', name: 'TestUp - OverlaysManager')
      super(id, name)
    end
  end if defined?(Sketchup::Overlay)

  class MockDuplicateIdOverlay < TestOverlay
    def initialize
      super('sketchup.testup.overlay-manager', 'TestUp - OverlaysManager')
    end
  end if defined?(Sketchup::Overlay)

  class MockMissingSuperOverlay < TestOverlay
  end if defined?(Sketchup::Overlay)

  def registered_mock_overlays
    Sketchup.active_model.overlays.select { |overlay|
      overlay.is_a?(TestOverlay)
    }
  end

  def clear_mock_overlays
    overlays = Sketchup.active_model.overlays
    registered_mock_overlays.each { |overlay|
      overlays.remove(overlay)
    }
  end


  # ========================================================================== #
  # class Sketchup::OverlaysManager

  def test_class
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0
    overlays = Sketchup.active_model.overlays
    assert_kind_of(Sketchup::OverlaysManager, overlays)
    assert_kind_of(Enumerable, overlays)
  end


  # ========================================================================== #
  # method Sketchup::OverlaysManager#add

  def test_add_unique
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0
    overlays = Sketchup.active_model.overlays
    assert_equal(0, registered_mock_overlays.size)

    overlay = MockOverlay.new
    result = overlays.add(overlay)
    assert_kind_of(TrueClass, result)
    assert_equal(1, registered_mock_overlays.size)
  end

  def test_add_same_instance_twice
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0
    overlays = Sketchup.active_model.overlays
    assert_equal(0, registered_mock_overlays.size)

    overlay = MockOverlay.new
    result = overlays.add(overlay)
    assert_kind_of(TrueClass, result)
    assert_equal(1, registered_mock_overlays.size)

    result = overlays.add(overlay)
    assert_kind_of(FalseClass, result)
    assert_equal(1, registered_mock_overlays.size)
  end

  def test_add_different_instance_twice
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0
    overlays = Sketchup.active_model.overlays
    assert_equal(0, registered_mock_overlays.size)

    overlay1 = MockOverlay.new
    result = overlays.add(overlay1)
    assert_kind_of(TrueClass, result)
    assert_equal(1, registered_mock_overlays.size)

    overlay2 = MockOverlay.new
    result = overlays.add(overlay2)
    assert_kind_of(FalseClass, result)
    assert_equal(1, registered_mock_overlays.size)
  end

  def test_add_different_overlay_same_id
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0
    overlays = Sketchup.active_model.overlays
    assert_equal(0, registered_mock_overlays.size)

    overlay1 = MockOverlay.new
    result = overlays.add(overlay1)
    assert_kind_of(TrueClass, result)
    assert_equal(1, registered_mock_overlays.size)

    overlay2 = MockDuplicateIdOverlay.new
    result = overlays.add(overlay2)
    assert_kind_of(FalseClass, result)
    assert_equal(1, registered_mock_overlays.size)
  end

  def test_add_empty_id
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0
    assert_raises(ArgumentError) do
      overlay = MockOverlay.new(id: '')
    end
  end

  def test_add_empty_name
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0
    assert_raises(ArgumentError) do
      overlay = MockOverlay.new(name: '')
    end
  end

  def test_add_overlay_missing_initialize_super
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0
    assert_raises(ArgumentError) do
      overlay = MockMissingSuperOverlay.new
    end
  end

  def test_add_overlay_life_time_check
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0
    overlays = Sketchup.active_model.overlays

    overlays.add(MockOverlay.new)
    # If we don't protect the Ruby objects from the GC then...
    GC.start # ..this would cause the Ruby object to be deleted.
    overlays.each { |overlay| # And iterating would cause access violation.
      assert_kind_of(Sketchup::Overlay, overlay)
    }
  end

  def test_add_invalid_argument_nil
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0
    overlays = Sketchup.active_model.overlays
    assert_equal(0, registered_mock_overlays.size)

    assert_raises(TypeError) do
      overlays.add(nil)
    end
    assert_equal(0, registered_mock_overlays.size)
  end

  def test_add_invalid_argument_string
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0
    overlays = Sketchup.active_model.overlays
    assert_equal(0, registered_mock_overlays.size)

    assert_raises(TypeError) do
      overlays.add("I'm an overlay, I promise!")
    end
    assert_equal(0, registered_mock_overlays.size)
  end

  def test_add_invalid_argument_number
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0
    overlays = Sketchup.active_model.overlays
    assert_equal(0, registered_mock_overlays.size)

    assert_raises(TypeError) do
      overlays.add(123)
    end
    assert_equal(0, registered_mock_overlays.size)
  end

  def test_add_too_few_arguments
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0
    overlays = Sketchup.active_model.overlays
    assert_equal(0, registered_mock_overlays.size)

    assert_raises(ArgumentError) do
      overlays.add
    end
    assert_equal(0, registered_mock_overlays.size)
  end

  def test_add_too_many_arguments
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0
    overlays = Sketchup.active_model.overlays
    assert_equal(0, registered_mock_overlays.size)

    malkovich = MockOverlay.new
    assert_raises(ArgumentError) do
      overlays.add(malkovich, malkovich)
    end
    assert_equal(0, registered_mock_overlays.size)
  end

  # ========================================================================== #
  # method Sketchup::OverlaysManager#remove

  def test_remove_same_instance
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0
    overlays = Sketchup.active_model.overlays
    assert_equal(0, registered_mock_overlays.size)

    overlay = MockOverlay.new
    result = overlays.add(overlay)
    assert_kind_of(TrueClass, result)
    assert_equal(1, registered_mock_overlays.size)
  end

  def test_remove_different_instance_same_id
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0
    overlays = Sketchup.active_model.overlays
    assert_equal(0, registered_mock_overlays.size)

    overlay1 = MockOverlay.new
    overlays.add(overlay1)
    assert_equal(1, registered_mock_overlays.size)

    overlay2 = MockOverlay.new
    result = overlays.remove(overlay2)
    assert_kind_of(FalseClass, result)
    assert_equal(1, registered_mock_overlays.size)
  end

  def test_remove_different_class_same_id
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0
    overlays = Sketchup.active_model.overlays
    assert_equal(0, registered_mock_overlays.size)

    overlay1 = MockOverlay.new
    overlays.add(overlay1)
    assert_equal(1, registered_mock_overlays.size)

    overlay2 = MockDuplicateIdOverlay.new
    result = overlays.remove(overlay2)
    assert_kind_of(FalseClass, result)
    assert_equal(1, registered_mock_overlays.size)
  end

  def test_remove_lifetime
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0
    overlays = Sketchup.active_model.overlays
    assert_equal(0, registered_mock_overlays.size)

    overlay = MockOverlay.new
    overlays.add(overlay)
    assert_equal(1, registered_mock_overlays.size)

    assert_kind_of(TrueClass, overlay.valid?)

    result = overlays.remove(overlay)
    assert(result)
    assert_equal(0, registered_mock_overlays.size)

    assert_kind_of(FalseClass, overlay.valid?)

    error = assert_raises(RuntimeError) do
      overlays.add(overlay)
    end
    assert_equal('invalid overlay', error.message)
  end

  def test_remove_invalid_argument_nil
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0
    overlays = Sketchup.active_model.overlays
    assert_equal(0, registered_mock_overlays.size)

    overlay = MockOverlay.new
    result = overlays.add(overlay)
    assert_kind_of(TrueClass, result)
    assert_equal(1, registered_mock_overlays.size)

    assert_raises(TypeError) do
      overlays.remove(nil)
    end
    assert_equal(1, registered_mock_overlays.size)
  end

  def test_remove_invalid_argument_string
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0
    overlays = Sketchup.active_model.overlays
    assert_equal(0, registered_mock_overlays.size)

    overlay = MockOverlay.new
    result = overlays.add(overlay)
    assert_kind_of(TrueClass, result)
    assert_equal(1, registered_mock_overlays.size)

    assert_raises(TypeError) do
      overlays.remove("I'm an overlay, I promise!")
    end
    assert_raises(TypeError) do
      overlays.remove(overlay.overlay_id)
    end
    assert_equal(1, registered_mock_overlays.size)
  end

  def test_remove_invalid_argument_number
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0
    overlays = Sketchup.active_model.overlays
    assert_equal(0, registered_mock_overlays.size)

    overlay = MockOverlay.new
    result = overlays.add(overlay)
    assert_kind_of(TrueClass, result)
    assert_equal(1, registered_mock_overlays.size)

    assert_raises(TypeError) do
      overlays.remove(123)
    end
    assert_equal(1, registered_mock_overlays.size)
  end

  def test_remove_too_few_arguments
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0
    overlays = Sketchup.active_model.overlays
    assert_equal(0, registered_mock_overlays.size)

    overlay = MockOverlay.new
    result = overlays.add(overlay)
    assert_kind_of(TrueClass, result)
    assert_equal(1, registered_mock_overlays.size)

    assert_raises(ArgumentError) do
      overlays.remove
    end
    assert_equal(1, registered_mock_overlays.size)
  end

  def test_remove_too_many_arguments
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0
    overlays = Sketchup.active_model.overlays
    assert_equal(0, registered_mock_overlays.size)

    overlay = MockOverlay.new
    result = overlays.add(overlay)
    assert_kind_of(TrueClass, result)
    assert_equal(1, registered_mock_overlays.size)

    assert_raises(ArgumentError) do
      overlays.remove(overlay, overlay)
    end
    assert_equal(1, registered_mock_overlays.size)
  end

  # ========================================================================== #
  # method Sketchup::OverlaysManager#size

  def test_size
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0
    overlays = Sketchup.active_model.overlays

    result1 = overlays.size
    assert_kind_of(Integer, result1)
    assert(result1 >= 0)

    assert_equal(0, registered_mock_overlays.size)
    overlay = MockOverlay.new
    overlays.add(overlay)
    assert_equal(1, registered_mock_overlays.size)

    assert_equal(result1 + 1, overlays.size)
  end

  def test_size_too_many_arguments
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0
    overlays = Sketchup.active_model.overlays

    assert_raises(ArgumentError) do
      overlays.size(nil)
    end
  end

  # ========================================================================== #
  # method Sketchup::OverlaysManager#length

  def test_length
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0
    overlays = Sketchup.active_model.overlays

    result1 = overlays.length
    assert_kind_of(Integer, result1)
    assert(result1 >= 0)

    assert_equal(0, registered_mock_overlays.size)
    overlay = MockOverlay.new
    overlays.add(overlay)
    assert_equal(1, registered_mock_overlays.size)

    assert_equal(result1 + 1, overlays.length)
  end

  # This method is an alias, not duplicating all the tests. Just the success to
  # ensure it's there and wired up.

  # ========================================================================== #
  # method Sketchup::OverlaysManager#[]

  def test_Operator_Get
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0
    overlays = Sketchup.active_model.overlays

    # Ensure at least two overlays in the list.
    overlay1 = MockOverlay.new(id: 'sketchup.testup.overlay-manager.1')
    overlays.add(overlay1)
    overlay2 = MockOverlay.new(id: 'sketchup.testup.overlay-manager.2')
    overlays.add(overlay2)
    assert(overlays.size >= 2)

    iterated = []
    (0...overlays.size).each { |i|
      result = overlays[i]
      assert_kind_of(Sketchup::Overlay, result)
      iterated << result
    }
    assert_equal(overlays.size, iterated.size)
    assert_includes(iterated, overlay1)
    assert_includes(iterated, overlay2)
  end

  def test_Operator_Get_invalid_argument_nil
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0
    overlays = Sketchup.active_model.overlays
    overlay = MockOverlay.new
    overlays.add(overlay)

    assert_raises(TypeError) do
      overlays[nil]
    end
  end

  def test_Operator_Get_invalid_argument_string
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0
    overlays = Sketchup.active_model.overlays
    overlay = MockOverlay.new
    overlays.add(overlay)

    assert_raises(TypeError) do
      overlays['hello']
    end
    assert_raises(TypeError) do
      overlays[overlay.overlay_id]
    end
  end

  def test_Operator_Get_too_few_arguments
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0
    overlays = Sketchup.active_model.overlays

    overlay1 = MockOverlay.new(id: 'sketchup.testup.overlay-manager.1')
    overlays.add(overlay1)

    assert_raises(ArgumentError) do
      overlays[]
    end
  end

  def test_Operator_Get_too_many_arguments
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0
    overlays = Sketchup.active_model.overlays

    overlay1 = MockOverlay.new(id: 'sketchup.testup.overlay-manager.1')
    overlays.add(overlay1)

    assert_raises(ArgumentError) do
      overlays[0, 0]
    end
  end

  # ========================================================================== #
  # method Sketchup::OverlaysManager#at

  def test_at
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0
    overlays = Sketchup.active_model.overlays

    # Ensure at least two overlays in the list.
    overlay1 = MockOverlay.new(id: 'sketchup.testup.overlay-manager.1')
    overlays.add(overlay1)
    overlay2 = MockOverlay.new(id: 'sketchup.testup.overlay-manager.2')
    overlays.add(overlay2)
    assert(overlays.size >= 2)

    iterated = []
    (0...overlays.size).each { |i|
      result = overlays.at(i)
      assert_kind_of(Sketchup::Overlay, result)
      iterated << result
    }
    assert_equal(overlays.size, iterated.size)
    assert_includes(iterated, overlay1)
    assert_includes(iterated, overlay2)
  end

  # This method is an alias, not duplicating all the tests. Just the success to
  # ensure it's there and wired up.

  # ========================================================================== #
  # method Sketchup::OverlaysManager#each

  def test_each
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0
    overlays = Sketchup.active_model.overlays

    # Ensure at least two overlays in the list.
    overlay1 = MockOverlay.new(id: 'sketchup.testup.overlay-manager.1')
    overlays.add(overlay1)
    overlay2 = MockOverlay.new(id: 'sketchup.testup.overlay-manager.2')
    overlays.add(overlay2)
    assert(overlays.size >= 2)

    iterated = []
    overlays.each { |overlay|
      assert_kind_of(Sketchup::Overlay, overlay)
      iterated << overlay
    }
    assert_equal(overlays.size, iterated.size)
    assert_includes(iterated, overlay1)
    assert_includes(iterated, overlay2)
  end

  def test_each_too_many_arguments
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0
    overlays = Sketchup.active_model.overlays

    overlay1 = MockOverlay.new(id: 'sketchup.testup.overlay-manager.1')
    overlays.add(overlay1)

    iterated = []
    assert_raises(ArgumentError) do
      overlays.each(123) { |overlays| iterated << overlays }
    end
    assert_empty(iterated)
  end

end
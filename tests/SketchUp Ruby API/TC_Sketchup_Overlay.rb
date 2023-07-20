# Copyright:: Copyright 2022 Trimble Inc.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen

require "testup/testcase"
require_relative "utils/feature_switch"

# class Sketchup::Overlay
class TC_Sketchup_Overlay < TestUp::TestCase

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


  # Just making a common base class to make it easier to clean up test overlays.
  class TestOverlay < Sketchup::Overlay
  end if defined?(Sketchup::Overlay)

  class MockOverlay < TestOverlay
    attr_reader :start_count, :stop_count
    def initialize(id: 'sketchup.testup.overlay')
      super(id, 'TestUp - Overlay')
      @start_count = 0
      @stop_count = 0
    end
    def start(*args)
      @start_count += 1 unless @suspend_counts
    end
    def stop(*args)
      @stop_count += 1
    end
    def suspend_counts(&block)
      @suspend_counts = true unless @suspend_counts
      block.call
    ensure
      @suspend_counts = false
    end
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
  # method Sketchup::Overlay#initialize

  def test_initialize
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0

    overlay = Sketchup::Overlay.new('sketchup.testup.overlay', 'TestUp - Overlay')
    assert_kind_of(Sketchup::Overlay, overlay)
  end

  def test_initialize_with_description
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0

    id = 'sketchup.testup.overlay'
    name = 'TestUp - Overlay'
    description = 'Overlay test description.'
    overlay = Sketchup::Overlay.new(id, name, description: description)
    assert_kind_of(Sketchup::Overlay, overlay)
    assert_equal(id, overlay.overlay_id)
    assert_equal(name, overlay.name)
    assert_equal(description, overlay.description)
  end

  def test_initialize_too_few_arguments_missing_id_and_name
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0

    assert_raises(ArgumentError) do
      Sketchup::Overlay.new
    end
  end

  def test_initialize_too_few_arguments_missing_name
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0

    assert_raises(ArgumentError) do
      Sketchup::Overlay.new('sketchup.testup.overlay')
    end
  end

  def test_initialize_too_many_arguments
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0

    assert_raises(ArgumentError) do
      Sketchup::Overlay.new('sketchup.testup.overlay', 'TestUp - Overlay', 123)
    end
  end

  def test_initialize_invalid_arguments_id_is_nil
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0

    assert_raises(TypeError) do
      Sketchup::Overlay.new(nil, 'TestUp - Overlay')
    end
  end

  def test_initialize_invalid_arguments_name_is_nil
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0

    assert_raises(TypeError) do
      Sketchup::Overlay.new('sketchup.testup.overlay', nil)
    end
  end

  def test_initialize_invalid_arguments_id_is_number
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0

    assert_raises(TypeError) do
      Sketchup::Overlay.new(123, 'TestUp - Overlay')
    end
  end

  def test_initialize_invalid_arguments_name_is_number
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0

    assert_raises(TypeError) do
      Sketchup::Overlay.new('sketchup.testup.overlay', 123)
    end
  end


  # ========================================================================== #
  # method Sketchup::Overlay#clone

  def test_clone
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0

    overlay = Sketchup::Overlay.new('sketchup.testup.overlay', 'TestUp - Overlay')
    assert_raises(TypeError) do
      overlay.clone
    end
  end


  # ========================================================================== #
  # method Sketchup::Overlay#dup

  def test_dup
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0

    overlay = Sketchup::Overlay.new('sketchup.testup.overlay', 'TestUp - Overlay')
    assert_raises(TypeError) do
      overlay.dup
    end
  end


  # ========================================================================== #
  # method Sketchup::Overlay#overlay_id

  def test_overlay_id
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0

    overlay = Sketchup::Overlay.new('sketchup.testup.overlay', 'TestUp - Overlay')
    assert_kind_of(String, overlay.overlay_id)
    assert_equal('sketchup.testup.overlay', overlay.overlay_id)
  end

  def test_overlay_id_too_many_arguments
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0

    overlay = Sketchup::Overlay.new('sketchup.testup.overlay', 'TestUp - Overlay')
    assert_raises(ArgumentError) do
      overlay.overlay_id(123)
    end
  end


  # ========================================================================== #
  # method Sketchup::Overlay#name

  def test_name
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0

    overlay = Sketchup::Overlay.new('sketchup.testup.overlay', 'TestUp - Overlay')
    assert_kind_of(String, overlay.name)
    assert_equal('TestUp - Overlay', overlay.name)
  end

  def test_name_too_many_arguments
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0

    overlay = Sketchup::Overlay.new('sketchup.testup.overlay', 'TestUp - Overlay')
    assert_raises(ArgumentError) do
      overlay.name(123)
    end
  end


  # ========================================================================== #
  # method Sketchup::Overlay#description

  def test_description
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0

    id = 'sketchup.testup.overlay'
    name = 'TestUp - Overlay'
    description = 'Overlay test description.'
    overlay = Sketchup::Overlay.new(id, name, description: description)
    assert_kind_of(String, overlay.description)
    assert_equal(description, overlay.description)
  end

  def test_description_too_many_arguments
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0

    id = 'sketchup.testup.overlay'
    name = 'TestUp - Overlay'
    description = 'Overlay test description.'
    overlay = Sketchup::Overlay.new(id, name, description: description)
    assert_raises(ArgumentError) do
      overlay.description(123)
    end
  end


  # ========================================================================== #
  # method Sketchup::Overlay#description=

  def test_description_Set
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0

    overlay = Sketchup::Overlay.new('sketchup.testup.overlay', 'TestUp - Overlay')
    assert_kind_of(String, overlay.description)
    assert_equal('', overlay.description)
    overlay.description = 'Hello World'
    assert_equal('Hello World', overlay.description)
  end


  # ========================================================================== #
  # method Sketchup::Overlay#enabled?

  def test_enabled_Query
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0

    overlay = Sketchup::Overlay.new('sketchup.testup.overlay', 'TestUp - Overlay')
    assert_includes([TrueClass, FalseClass], overlay.enabled?.class)
  end

  def test_enabled_Query_too_many_arguments
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0

    overlay = MockOverlay.new
    assert_raises(ArgumentError) do
      overlay.enabled?(123)
    end
  end


  # ========================================================================== #
  # method Sketchup::Overlay#enabled=

  def test_enabled_Set_not_added_to_model
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0

    overlay = MockOverlay.new
    assert_raises(RuntimeError) do
      overlay.enabled = false
      overlay.enabled = true
    end
  end

  def test_enabled_Set_added_to_model
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0

    overlay = MockOverlay.new
    overlay.suspend_counts do
      Sketchup.active_model.overlays.add(overlay)
      overlay.enabled = true
    end
    assert_kind_of(TrueClass, overlay.enabled?)
    assert_equal(0, overlay.start_count)
    assert_equal(0, overlay.stop_count)

    overlay.enabled = false
    assert_kind_of(FalseClass, overlay.enabled?)
    assert_equal(0, overlay.start_count)
    assert_equal(1, overlay.stop_count)

    overlay.enabled = true
    assert_kind_of(TrueClass, overlay.enabled?)
    assert_equal(1, overlay.start_count)
    assert_equal(1, overlay.stop_count)

    # Start should not be called when enabled state doesn't change.
    overlay.enabled = true
    assert_kind_of(TrueClass, overlay.enabled?)
    assert_equal(1, overlay.start_count)
    assert_equal(1, overlay.stop_count)

    # Stop should not be called when enabled state doesn't change.
    overlay.enabled = false
    assert_kind_of(FalseClass, overlay.enabled?)
    assert_equal(1, overlay.start_count)
    assert_equal(2, overlay.stop_count)

    overlay.enabled = false
    assert_kind_of(FalseClass, overlay.enabled?)
    assert_equal(1, overlay.start_count)
    assert_equal(2, overlay.stop_count)
  end

  def test_enabled_Set_falsy
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0

    overlay = MockOverlay.new
    Sketchup.active_model.overlays.add(overlay)
    overlay.enabled = true
    assert_kind_of(TrueClass, overlay.enabled?)

    overlay.enabled = nil
    assert_kind_of(FalseClass, overlay.enabled?)
  end

  def test_enabled_Set_truthy
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0

    overlay = MockOverlay.new
    Sketchup.active_model.overlays.add(overlay)
    overlay.enabled = false
    assert_kind_of(FalseClass, overlay.enabled?)
    
    overlay.enabled = 123
    assert_kind_of(TrueClass, overlay.enabled?)
  end


  # ========================================================================== #
  # method Sketchup::Overlay#source

  def test_source
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0

    overlay = MockOverlay.new
    result = overlay.source
    assert_kind_of(String, result)
    assert_includes(result, TestUp::EXTENSION[:name])
  end

  def test_source_too_many_arguments
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0

    overlay = MockOverlay.new
    assert_raises(ArgumentError) do
      overlay.source(123)
    end
  end


  # ========================================================================== #
  # method Sketchup::Overlay#valid_

  def test_valid_Query
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0

    overlay = MockOverlay.new
    assert_kind_of(TrueClass, overlay.valid?)

    Sketchup.active_model.overlays.add(overlay)
    assert_kind_of(TrueClass, overlay.valid?)

    Sketchup.active_model.overlays.remove(overlay)
    assert_kind_of(FalseClass, overlay.valid?)
  end

  def test_valid_Query_too_many_arguments
    skip('Added in 2023.0') if Sketchup.version.to_f < 23.0

    overlay = MockOverlay.new
    assert_raises(ArgumentError) do
      overlay.valid?(123)
    end
  end

end
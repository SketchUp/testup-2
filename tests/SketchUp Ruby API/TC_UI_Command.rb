# Copyright:: Copyright 2018 Trimble Inc.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen

require "testup/testcase"


# class UI::Command
class TC_UI_Command < TestUp::TestCase

  def self.setup_testcase
    discard_all_models
  end

  def setup
    # ...
  end

  def teardown
    # ...
  end

  class CustomCommand < UI::Command
    def custom_menu_text
      menu_text
    end
  end

  # ========================================================================== #
  # method UI::Command.initialize

  def test_initialize_subclass
    skip("Fixed in SU2019") if Sketchup.version.to_i < 19
    command1 = UI::Command.new('Command1') {}
    assert_kind_of(UI::Command, command1)

    command2 = CustomCommand.new('Command2') {}
    assert_kind_of(UI::Command, command2)
    assert_kind_of(CustomCommand, command2)
    assert_equal('Command2', command2.custom_menu_text)
    refute(command1 == command2, 'command1 != command2')

    command3 = CustomCommand.new('Command3') {}
    refute(command1 == command2, 'command2 != command3')
    assert_kind_of(UI::Command, command3)
    assert_kind_of(CustomCommand, command3)
    assert_equal('Command3', command3.custom_menu_text)
  end

  # ========================================================================== #
  # method UI::Command.proc

  def test_proc
    command1 = UI::Command.new('Command1') { 123 }
    assert_kind_of(Proc, command1.proc)
    assert_equal(123, command1.proc.call)
  end

  def test_proc_too_many_arguments
    command1 = UI::Command.new('Command1') { 123 }
    assert_raises(ArgumentError) do
      command1.proc('nope!')
    end
  end

  # ========================================================================== #
  # method UI::Command.get_validation_proc

  def test_get_validation_proc
    command1 = UI::Command.new('Command1') { 123 }
    command1.set_validation_proc { 456 }
    assert_kind_of(Proc, command1.get_validation_proc)
    assert_equal(456, command1.get_validation_proc.call)
  end

  def test_get_validation_proc_too_many_arguments
    command1 = UI::Command.new('Command1') { 123 }
    command1.set_validation_proc { 456 }
    assert_raises(ArgumentError) do
      command1.get_validation_proc('nope!')
    end
  end

  # ========================================================================== #
  # method UI::Command.extension

  def test_extension
    command1 = UI::Command.new('Command1') { 123 }
    assert_nil(command1.extension)
    extension = Sketchup.extensions[TestUp::EXTENSION[:name]]
    refute_nil(extension)
    command1.extension = extension
    assert_kind_of(SketchupExtension, command1.extension)
    assert_equal(extension, command1.extension)
  end

  def test_extension_too_many_arguments
    command1 = UI::Command.new('Command1') { 123 }
    assert_raises(ArgumentError) do
      command1.extension('nope!')
    end
  end

  # ========================================================================== #
  # method UI::Command.extension=

  def test_extension_Set
    command1 = UI::Command.new('Command1') { 123 }
    assert_nil(command1.extension)
    extension = Sketchup.extensions[TestUp::EXTENSION[:name]]
    refute_nil(extension)
    command1.extension = extension
    assert_kind_of(SketchupExtension, command1.extension)
    assert_equal(extension, command1.extension)
    command1.extension = nil
    assert_nil(command1.extension)
  end

  def test_extension_invalid_arguments
    command1 = UI::Command.new('Command1') { 123 }
    assert_raises(TypeError) do
      command1.extension = 123
    end
  end

end # class

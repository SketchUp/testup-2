# Copyright:: Copyright 2018 Trimble Inc.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen

require "testup/testcase"


# class UI::Command
class TC_UI_Command < TestUp::TestCase

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
  # method Sketchup::InputPoint.instance_path

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

end # class

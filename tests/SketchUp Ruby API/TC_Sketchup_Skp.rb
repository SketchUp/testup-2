# Copyright:: Copyright 2020 Trimble Inc.
# License:: The MIT License (MIT)
# Original Author:: Eneroth

require 'testup/testcase'

# module Sketchup::Skp
class TC_Sketchup_Skp < TestUp::TestCase

  # @param [String] filename
  # @return [String]
  def get_test_case_file(filename)
    File.join(__dir__, File.basename(__FILE__, '.*'), filename)
  end

  # ========================================================================== #
  # method Sketchup::SKP.guid

  def test_read_guid_2020
    skip('Added in SU2021.0') if Sketchup.version.to_f < 21.0

    # Old file format.
    path = get_test_case_file("2020.skp")
    guid = "17ef5b03-623d-43e4-a630-b12e07b7751b"
    assert_equal(guid, Sketchup::Skp.read_guid(path))
  end

  def test_read_guid_2021
    skip('Added in SU2021.0') if Sketchup.version.to_f < 21.0

    # Versionless file format.
    path = get_test_case_file("2021.skp")
    guid = "35929446-5a06-475f-9590-b9b14c1b2876"
    assert_equal(guid, Sketchup::Skp.read_guid(path))
  end

  def test_read_guid_missing_file
    skip('Added in SU2021.0') if Sketchup.version.to_f < 21.0

    path = get_test_case_file("no_such_file.skp")
    assert_raises(ArgumentError) do
      Sketchup::Skp.read_guid(path)
    end
  end

  def test_read_guid_invalid_file
    skip('Added in SU2021.0') if Sketchup.version.to_f < 21.0

    path = get_test_case_file("not_a_sketchup_file.skp")
    assert_raises(ArgumentError) do
      Sketchup::Skp.read_guid(path)
    end
  end

  def test_read_guid_too_many_arguments
    skip('Added in SU2021.0') if Sketchup.version.to_f < 21.0

    path = get_test_case_file("2021.skp")
    assert_raises(ArgumentError) do
      Sketchup::Skp.read_guid(path, path)
    end
  end

  def test_read_guid_too_few_arguments
    skip('Added in SU2021.0') if Sketchup.version.to_f < 21.0

    assert_raises(ArgumentError) do
      Sketchup::Skp.read_guid
    end
  end

  def test_read_guid_nil_argument
    skip('Added in SU2021.0') if Sketchup.version.to_f < 21.0

    assert_raises(TypeError) do
      Sketchup::Skp.read_guid(nil)
    end
  end

  def test_read_guid_bogus_arguments
    skip('Added in SU2021.0') if Sketchup.version.to_f < 21.0

    assert_raises(TypeError) { Sketchup::Skp.read_guid(14) }
    assert_raises(TypeError) { Sketchup::Skp.read_guid(2.718281828459045) }
    assert_raises(TypeError) { Sketchup::Skp.read_guid(Object.new) }
  end
end

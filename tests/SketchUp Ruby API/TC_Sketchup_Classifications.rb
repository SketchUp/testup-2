# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: All Rights Reserved.
# Original Author:: Bugra Barin


require 'testup/testcase'


# class Sketchup::Classifications
# http://www.sketchup.com/intl/developer/docs/ourdoc/classifications
class TC_Sketchup_Classifications < TestUp::TestCase

  def setup
    disable_read_only_flag_for_test_models()
    open_test_model_with_multiple_schemas()
  end

  def teardown
    restore_read_only_flag_for_test_models()
  end


  def open_test_model_with_multiple_schemas
    basename = File.basename(__FILE__, ".*")
    path = File.dirname(__FILE__)
    test_model = File.join(path, basename, "MultipleClassifications.skp")
    # To speed up tests the model is reused is possible. Tests that modify the
    # model should discard the model changes: close_active_model()
    # TODO(thomthom): Add a Ruby API method to expose the `dirty` state of the
    # model - whether it's been modified since last save/open.
    # Model.path must be converted to Ruby style path as SketchUp returns an
    # OS dependant path string.
    model = Sketchup.active_model
    if model.nil? || File.expand_path(model.path) != test_model
      close_active_model()
      Sketchup.open_file(test_model)
    end
    Sketchup.active_model
  end


  # ========================================================================== #
  # method Sketchup::Classifications.[]
  # http://www.sketchup.com/intl/developer/docs/ourdoc/classifications#[]

  def test_Operator_Get_api_example
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    # Get schema by name:
    schema = Sketchup.active_model.classifications["IFC 2x3"]

    # Get schema by index:
    schema = Sketchup.active_model.classifications[1]
  end

  def test_Operator_Get_string_schema_name
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    schema = Sketchup.active_model.classifications["IFC 2x3"]
    assert_kind_of(Sketchup::ClassificationSchema, schema)
    assert_equal("IFC 2x3", schema.name)
  end

  def test_Operator_Get_integer_index
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    schema = Sketchup.active_model.classifications[1]
    assert_kind_of(Sketchup::ClassificationSchema, schema)
    # TODO(thomthom): The returned schema seem to differ from debug to release,
    # from x86 to x64.
    #assert_equal("gbXML", schema.name)
  end

  def test_Operator_Get_integer_negative_index
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    schema = Sketchup.active_model.classifications[-1]
    assert_kind_of(Sketchup::ClassificationSchema, schema)
  end

  def test_Operator_Get_float_index
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    # Float get cast into integer - so it's a working index type.
    schema = Sketchup.active_model.classifications[1.23]
    assert_kind_of(Sketchup::ClassificationSchema, schema)
  end

  def test_Operator_Get_incorrect_number_of_arguments_zero
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    assert_raises ArgumentError do
      schema = Sketchup.active_model.classifications[]
    end
  end

  def test_Operator_Get_invalid_argument_nil
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    assert_raises TypeError do
      schema = Sketchup.active_model.classifications[nil]
    end
  end

  def test_Operator_Get_invalid_argument_point3d
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    assert_raises TypeError do
      schema = Sketchup.active_model.classifications[ORIGIN]
    end
  end


  # ========================================================================== #
  # method Sketchup::Classifications.each
  # http://www.sketchup.com/intl/developer/docs/ourdoc/classifications#each

  def test_each_api_example
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    Sketchup.active_model.classifications.each { |schema|
      puts schema.name
    }
  end

  def test_each
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    schema_iterated = []
    Sketchup.active_model.classifications.each { |schema|
      assert_kind_of(Sketchup::ClassificationSchema, schema)
      schema_iterated << schema.name
    }
    assert_equal(3, schema_iterated.size, "Incorrect number of schemas")
    expected_schemas = [
      "CityGML 2.0",
      "IFC 2x3",
      "gbXML"
    ]
    assert_equal(expected_schemas, schema_iterated.sort, "Unexpected schemas")
  end

  def test_each_incorrect_number_of_arguments_one
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    c = Sketchup.active_model.classifications
    assert_raises ArgumentError do
      c.each(1) {}
    end
  end


  # ========================================================================== #
  # method Sketchup::Classifications.keys
  # http://www.sketchup.com/intl/developer/docs/ourdoc/classifications#keys

  def test_keys_api_example
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    schema_names = Sketchup.active_model.classifications.keys
  end

  def test_keys
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    schemas = Sketchup.active_model.classifications.keys
    assert_equal(3, schemas.size, "Incorrect number of schemas")
    expected_schemas = [
      "CityGML 2.0",
      "IFC 2x3",
      "gbXML"
    ]
    assert_equal(expected_schemas, schemas.sort, "Unexpected schemas")
  end

  def test_keys_incorrect_number_of_arguments_one
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    c = Sketchup.active_model.classifications
    assert_raises ArgumentError do
      c.keys(1)
    end
  end


  # ========================================================================== #
  # method Sketchup::Classifications.length
  # http://www.sketchup.com/intl/developer/docs/ourdoc/classifications#length

  def test_length_api_example
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    Sketchup.active_model.classifications.length
  end

  def test_length
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    assert_equal(3, Sketchup.active_model.classifications.length)
  end

  def test_length_incorrect_number_of_arguments_one
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    assert_raises ArgumentError do
      Sketchup.active_model.classifications.length(123)
    end
  end


  # ========================================================================== #
  # method Sketchup::Classifications.load_schema
  # http://www.sketchup.com/intl/developer/docs/ourdoc/classifications#load_schema

  def test_load_schema_api_example
    c = Sketchup.active_model.classifications
    file = Sketchup.find_support_file('ifcXML4.xsd', 'Classifications')
    status = c.load_schema(file) if !file.nil?
  ensure
    close_active_model()
  end

  def test_load_schema
    classifications = Sketchup.active_model.classifications
    classifications.unload_schema("IFC 2x3")
    if Sketchup.version.to_i >= 15
      assert_nil(classifications["IFC 2x3"])
    end

    file = Sketchup.find_support_file('IFC 2x3.skc', 'Classifications')
    status = classifications.load_schema(file)
    assert(status)
    if Sketchup.version.to_i >= 15
      schema = classifications["IFC 2x3"]
      assert_equal("IFC 2x3", schema.name)
    end
  ensure
    close_active_model()
  end

  def test_load_schema_bad_params
    c = Sketchup.active_model.classifications
    assert_raises ArgumentError do
      c.load_schema
    end
    assert_raises ArgumentError do
      c.load_schema(1,1)
    end
    assert_raises ArgumentError do
      c.load_schema('','','')
    end
  end


  # ========================================================================== #
  # method Sketchup::Classifications.size
  # http://www.sketchup.com/intl/developer/docs/ourdoc/classifications#size

  def test_size_api_example
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    Sketchup.active_model.classifications.size
  end

  def test_size
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    assert_equal(3, Sketchup.active_model.classifications.size)
  end

  def test_size_incorrect_number_of_arguments_one
    skip("Implemented in SU2015") if Sketchup.version.to_i < 15
    assert_raises ArgumentError do
      Sketchup.active_model.classifications.size(123)
    end
  end


  # ========================================================================== #
  # method Sketchup::Classifications.unload_schema
  # http://www.sketchup.com/intl/developer/docs/ourdoc/classifications#unload_schema

  def test_unload_schema_api_example
    c = Sketchup.active_model.classifications
    status = c.unload_schema('IFC 2x3')
  ensure
    close_active_model()
  end

  def test_unload_schema
    skip("Test functional in SU2015+") if Sketchup.version.to_i < 15
    classifications = Sketchup.active_model.classifications
    file = Sketchup.find_support_file('IFC 2x3.skc', 'Classifications')
    classifications.load_schema(file)
    schema = classifications["IFC 2x3"]
    assert_equal("IFC 2x3", schema.name, "Schema not loaded")

    status = classifications.unload_schema('IFC 2x3')
    assert(status)
    assert_nil(classifications["IFC 2x3"])
  ensure
    close_active_model()
  end

  def test_unload_schema_bad_params
    c = Sketchup.active_model.classifications
    assert_raises ArgumentError do
      c.unload_schema
    end
    assert_raises TypeError do
      c.unload_schema(1)
    end
    assert_raises ArgumentError do
      c.unload_schema('','')
    end
  end

end # class

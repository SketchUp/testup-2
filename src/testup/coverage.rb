#-------------------------------------------------------------------------------
#
# Copyright 2013-2014 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------


module TestUp
 # TODO: Refactor this class to be less hacky! Return a CoverageResult object.
 class Coverage

  # @param [String] settings_id
  def initialize(testsuite_path)
    unless File.directory?(testsuite_path)
      raise ArgumentError, "Not a valid directory: #{testsuite_path}"
    end
    # Array of method names declared in the manifest.
    @manifest_file = File.join(testsuite_path, 'coverage.manifest')
    update()
  end

  def has_manifest?
    !@manifest.empty?
  end

  # TODO: Needs refactoring.
  def percent(missing_tests)
    num_missing_tests = 0
    missing_tests.map { |klass, tests| num_missing_tests += tests.size }
    return 0.0 if num_missing_tests.zero?
    coverage = @manifest.size - num_missing_tests
    (coverage.to_f / @manifest.size.to_f) * 100.0
  end

  # @return [Array<String>]
  def expected_test_methods
    expected = {}
    for declaration in @manifest
      parts = split(declaration)
      method_name = parts.pop
      test_klass_name = "TC_#{parts.join('_')}"
      test_name = method_test_name(method_name)
      unless test_name =~ /[a-z_0-9]/i
        raise "Invalid test name: #{test_name}"
      end
      expected[test_klass_name] ||= []
      expected[test_klass_name] << test_name
    end
    expected
  end

  # Takes the results for the discovered test suite returned by the discoverer.
  #
  # @param [Hash<Class, Array>] testsuite
  def missing_tests(testsuite)
    missing = {}
    expected_testsuite = expected_test_methods()
    for expected_testcase, expected_tests in expected_testsuite
      testcase = klass_from_string(expected_testcase)
      if testsuite.key?(testcase)
        # Expected test case is found. Each expected test is compared against
        # the list of discovered tests. The comparison is done by matching the
        # name of the expected test to the first part of the discovered part.
        # This is done because tests often have appended name to them.
        tests = testsuite[testcase]
        for expected_test in expected_tests
          pattern = Regexp.new(/^#{expected_test}$|^#{expected_test}_/)
          next if tests.any? { |test| test.to_s =~ pattern }
          # Test method not found in list of discovered tests.
          missing[expected_testcase] ||= []
          missing[expected_testcase] << expected_test
        end
      else
        # The whole test case was missing from the list of discovered test
        # cases. Adding all the tests that are missing.
        missing[expected_testcase] = expected_tests.dup
      end
    end
    missing
  end

  def update
    @manifest = parse_manifest(@manifest_file)
    nil
  end

  def testmethod_basename(method_name)

  end

  def method_test_name(method_name)
    case method_name

    when '+'
      'test_Operator_Plus'
    when '-'
      'test_Operator_Minus'
    when '*'
      'test_Operator_Multiply'
    when '\\'
      'test_Operator_Divide'
    when '%'
      'test_Operator_Modulo'
    when '**'
      'test_Operator_Pow'

    when '=='
      'test_Operator_Equal'
    when '!='
      'test_Operator_NotEqual'
    when '>'
      'test_Operator_GreaterThan'
    when '<'
      'test_Operator_LessThan'
    when '>='
      'test_Operator_GreaterThanOrEqual'
    when '<='
      'test_Operator_LessThanOrEqual'
    when '<=>'
      'test_Operator_Sort'
    when '==='
      'test_Operator_CaseEquality'

    when '&'
      'test_Operator_And'
    when '|'
      'test_Operator_Or'
    when '^'
      'test_Operator_Xor'
    when '~'
      'test_Operator_Not'
    when '<<'
      'test_Operator_LeftShift'
    when '<<'
      'test_Operator_RightShift'

    when '[]'
      'test_Operator_Get'
    when '[]='
      'test_Operator_Set'

    else
      test_name = "test_#{method_name}"
      test_name.gsub!("!", "_Bang")
      test_name.gsub!("?", "_Query")
      test_name.gsub!("=", "_Set")
      test_name
    end
  end

  private

  def klass_from_string(string)
    unless Object.constants.include?(string.intern)
      return nil
    end
    Object.const_get(string)
  end

  # @param [String] manifest_file
  #
  # @return [Array<String>]
  def parse_manifest(manifest_file)
    return [] unless File.exist?(manifest_file)
    File.readlines(manifest_file).each { |line|
      line.strip!
    }
  end

  # Split the declaration string into its components:
  # "Sketchup::Edge.other_vertex" > ["Sketchup", "Edge", "other_vertex"]
  def split(declaration)
    klass, method = declaration.split('.')
    klass.split('::') << method
  end

 end # class
end # module TestUp

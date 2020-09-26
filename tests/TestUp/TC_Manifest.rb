# Copyright:: Copyright 2018 Trimble Inc
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen

require 'testup/testcase'
require 'testup/manifest'


module TestUp
module Tests
  class TC_Manifest < TestUp::TestCase

    def setup
      # ...
    end

    def teardown
      # ...
    end


    TESTS_PATH = File.expand_path('..', __dir__)
    TESTUP_TESTS_PATH = File.join(TESTS_PATH, 'TestUp')
    TESTUP_UI_TESTS_PATH = File.join(TESTS_PATH, 'TestUp UI Tests')


    def fake_path
      File.join(TESTS_PATH, 'Fake Suite', TestUp::Manifest::FILENAME)
    end

    def existing_path
      File.join(TESTUP_TESTS_PATH, 'TC_Manifest', TestUp::Manifest::FILENAME)
    end


    def test_initialize_missing_file
      manifest = TestUp::Manifest.new(fake_path)
      refute(manifest.exist?, "manifest exist: #{fake_path}")
      assert_empty(manifest.expected_methods)
    end

    def test_initialize_with_file
      manifest = TestUp::Manifest.new(existing_path)
      assert(manifest.exist?, "manifest does not exist: #{existing_path}")
      expected = %w[
        TC_TestSamples.test_equal_failure
        TC_TestSamples.test_error
        TC_TestSamples.test_failure
        TC_TestSamples.test_pass
        TC_TestSamples.test_skip
      ]
      assert_equal(expected, manifest.expected_methods)
    end

  end # class
end
end

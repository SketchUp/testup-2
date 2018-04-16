#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------


module TestUp
  class Manifest

    FILENAME = 'coverage.manifest'.freeze

    attr_reader :filename

    # @param [String] filename
    def initialize(manifest_filename)
      @filename = manifest_filename
      @expected = parse_manifest(manifest_filename)
    end

    def exist?
      !@expected.empty?
    end

    # @return [Array<String>]
    def expected_methods
      @expected
    end

    private

    # @param [String] filename
    #
    # @return [Array<String>]
    def parse_manifest(filename)
      return [] unless File.exist?(filename)
      File.readlines(filename).map { |line|
        line.strip!
      }
    end

  end # class
end # module

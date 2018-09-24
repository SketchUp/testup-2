#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

require 'optparse'

module TestUp
  class ArgumentsParser

    def self.parse
      ruby_args = ARGV.empty? ? '' : ARGV.first
      self.new(ruby_args)
    end

    attr_reader :arguments

    # @param [String] argument_string
    def initialize(argument_string)
      @arguments = parse(argument_string)
    end

    private

    BANNER = 'TestUp:'.freeze
    CI_PATH = 'TestUp:CI:Path:'.freeze
    CI_CONFIG = 'TestUp:CI:Config:'.freeze


    # @param [String] argument_string
    def parse(argument_string)
      args = {}

      if argument_string.start_with?(CI_PATH)
        arguments = argument_string[CI_PATH.length..-1].strip
        args[:ci_suite_path] = arguments
      elsif argument_string.start_with?(CI_CONFIG)
        arguments = argument_string[CI_CONFIG.length..-1].strip
        args[:ci_config_path] = arguments
      end

      # options = {}
      # OptionParser.new do |opts|
      #   opts.on("-w", "--suite", "Suite path") do |suite_path|
      #     options[:suite] = suite_path
      #   end
      #   opts.on("-o", "--out", "Output path") do |out_path|
      #     options[:out] = out_path
      #   end
      #   opts.on("-f", "--format", "Format") do |format|
      #     options[:format] = format
      #   end
      # end.parse!(arguments.split(/\s/))

      args
    end

  end
end # module TestUp

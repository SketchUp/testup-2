#-------------------------------------------------------------------------------
#
# Copyright 2013-2020 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------


require 'json'
require 'pp'
require 'stringio'
require 'testup/minitest_setup.rb'
require 'testup/app_files.rb'


# Patching Minitest because we currently use 5.4.3 which doesn't have `prerecord`.
module Minitest
  class Runnable

    class << self # rubocop:disable Style/MultilineIfModifier
      puts "Alias old_run_one_method..."
      alias_method :old_run_one_method, :run_one_method
    end unless respond_to?(:old_run_one_method)

    def self.run_one_method(klass, method_name, reporter)
      reporter.prerecord(klass, method_name) if reporter.respond_to?(:prerecord)
      self.old_run_one_method(klass, method_name, reporter)
    end

    ##
    # About to start running a test. This allows a reporter to show
    # that it is starting or that we are in the middle of a test run.
    def prerecord(klass, method_name)
    end

  end

  class CompositeReporter < AbstractReporter
    def prerecord(klass, method_name)
      self.reporters.each do |reporter|
        reporter.prerecord(klass, method_name) if reporter.respond_to?(:prerecord)
      end
    end
  end
end


# Patch minitest-reporter to support `prerecord`.
module Minitest
  module Reporters
    class DelegateReporter < Minitest::AbstractReporter

      def prerecord(klass, method_name)
        all_reporters.each do |reporter|
          reporter.prerecord(klass, method_name) if reporter.respond_to?(:prerecord)
        end
      end

    end
  end
end


module TestUp
# Based on Minitest::SummaryReporter
class DebugReporter < Minitest::StatisticsReporter

  def initialize(options)
    io_null = StringIO.new
    super(io_null, options)
  end

  def prerecord(klass, name)
    puts "> Running test: #{klass}##{name}"
    # super
  end

end # class
end # module TestUp

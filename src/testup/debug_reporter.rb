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

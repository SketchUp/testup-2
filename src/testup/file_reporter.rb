#-------------------------------------------------------------------------------
#
# Copyright 2013-2016 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------


require 'json'
require 'pp'
require File.join(__dir__, 'minitest_setup.rb')


module TestUp
class FileReporter < MiniTest::StatisticsReporter

  attr_accessor :sync
  attr_accessor :old_sync

  def initialize(options)
    super(create_log_file, options)
  end

  #def finish
  #  io.close
  #end

  def start # :nodoc:
    super

    # TestUp create a really long and noisy filter string. We don't want to
    # output this.
    # TODO(thomthom): See if the filter string from TestUp's webdialog can
    # be simplified when running all tests in a unit.
    opts = options.dup
    opts.delete(:filter)
    opts.delete(:args)
    opts.delete(:io)
    opts_str = JSON.pretty_generate(opts)

    io.puts "Run options: #{opts_str}"
    io.puts
    io.puts "# Running:"
    io.puts

    self.sync = io.respond_to? :"sync=" # stupid emacs
    self.old_sync, io.sync = io.sync, true if self.sync
  end

  def report # :nodoc:
    super

    io.sync = self.old_sync

    io.puts unless options[:verbose] # finish the dots
    io.puts
    io.puts statistics
    io.puts aggregated_results
    io.puts summary

  ensure
    io.flush
    io.close
  end

  def record(result)
    super
    #io.puts "#{result.class.name}##{result.name}"
    io.puts "%s#%s = %.2f s = %s" % [result.class, result.name, result.time, result.result_code]
  end

  def statistics # :nodoc:
    "Finished in %.6fs, %.4f runs/s, %.4f assertions/s." %
      [total_time, count / total_time, assertions / total_time]
  end

  def aggregated_results # :nodoc:
    filtered_results = results.dup
    filtered_results.reject!(&:skipped?) unless options[:verbose]

    s = filtered_results.each_with_index.map { |result, i|
      "\n%3d) %s" % [i+1, result]
    }.join("\n") + "\n"

    #s.force_encoding(io.external_encoding) if
    #  ENCS and io.external_encoding and s.encoding != io.external_encoding

    s
  end

  alias to_s aggregated_results

  def summary # :nodoc:
    extra = ""

    extra = "\n\nYou have skipped tests. Run with --verbose for details." if
      results.any?(&:skipped?) unless options[:verbose] or ENV["MT_NO_SKIP_MSG"]

    "%d runs, %d assertions, %d failures, %d errors, %d skips%s" %
      [count, assertions, failures, errors, skips, extra]
  end

  private

  def create_log_file
    # File system friendly version of ISO 8601. Makes the logs be sortable in
    # the file browser.
    timestamp = Time.now.strftime('%F_%H-%M-%S')
    filename = "testup_#{timestamp}.log"
    # TODO(thomthom): Find a good place for log files. (Configurable?)
    filepath = File.join(ENV['HOME'], 'Desktop', 'testup', filename)
    File.open(filepath, 'w')
  end

end # class
end # module TestUp

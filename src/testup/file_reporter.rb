#-------------------------------------------------------------------------------
#
# Copyright 2013-2016 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------


require 'json'
require 'pp'
require 'testup/minitest_setup.rb'
require 'testup/app_files.rb'


module TestUp
# Based on Minitest::SummaryReporter
class FileReporter < MiniTest::StatisticsReporter

  include AppFiles

  attr_accessor :sync
  attr_accessor :old_sync

  def initialize(options)
    super(create_log_file, options)
  end

  def start
    super

    create_run_log(options)

    # TestUp create a really long and noisy filter string. We don't want to
    # output this.
    # TODO(thomthom): See if the filter string from TestUp's webdialog can
    # be simplified when running all tests in a unit.
    opts = options.dup
    opts.delete(:filter)
    opts.delete(:args)
    opts.delete(:io)
    opts_str = JSON.pretty_generate(opts)

    io.puts "SketchUp: #{Sketchup.version}"
    io.puts "    Ruby: #{RUBY_VERSION}"
    io.puts "  TestUp: #{PLUGIN_VERSION}"
    io.puts "Minitest: #{Minitest::VERSION}"
    io.puts
    io.puts "Platform: #{Sketchup.platform}"
    io.puts "  Locale: #{Sketchup.get_locale}"
    io.puts
    io.puts "Run options: #{opts_str}"
    io.puts
    io.puts "# Running:"
    io.puts

    self.sync = io.respond_to? :"sync=" # stupid emacs
    self.old_sync, io.sync = io.sync, true if self.sync
  end

  def report
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
    io.puts "%s#%s = %.2f s = %s" % [result.class,
                                     result.name,
                                     result.time,
                                     result.result_code]
  end

  def statistics
    "Finished in %.6fs, %.4f runs/s, %.4f assertions/s." %
      [total_time, count / total_time, assertions / total_time]
  end

  def aggregated_results
    filtered_results = results.dup
    filtered_results.reject!(&:skipped?) unless options[:verbose]

    s = filtered_results.each_with_index.map { |result, i|
      "\n%3d) %s" % [i+1, result]
    }.join("\n") + "\n"

    s
  end

  alias to_s aggregated_results

  def summary
    extra = ""

    extra = "\n\nYou have skipped tests. Run with --verbose for details." if
      results.any?(&:skipped?) unless options[:verbose] or ENV["MT_NO_SKIP_MSG"]

    "%d runs, %d assertions, %d failures, %d errors, %d skips%s" %
      [count, assertions, failures, errors, skips, extra]
  end

  private

  def log_basename
    # File system friendly version of ISO 8601. Makes the logs be sortable in
    # the file browser.
    version = Sketchup.version.split('.').first
    timestamp = Time.now.strftime('%F_%H-%M-%S')
    "testup_#{timestamp}_su#{version}"
  end

  def create_run_log(options)
    tests = options[:filter].scan(/[(|]([A-za-z0-9#_]+)/).flatten.sort
    log = {
      seed: options[:seed],
      tests: tests
    }
    filename = "su#{log_basename}.run"
    filepath = File.join(log_path, filename)
    puts "Run log: #{filepath}"
    File.write(filepath, JSON.pretty_generate(log))
  end

  def create_log_file
    filename = "#{log_basename}.log"
    filepath = File.join(log_path, filename)
    puts "Logging to: #{filepath}"
    File.open(filepath, 'w')
  end

end # class
end # module TestUp

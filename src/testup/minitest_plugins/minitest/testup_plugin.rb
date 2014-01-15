# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require File.join(__dir__, '..', '..', 'xml_reporter.rb')


puts 'MiniTest TestUp Extension discovered...' # DEBUG

module Minitest

  def self.plugin_testup_init(options)
    puts 'MiniTest TestUp Extension loading...' # DEBUG

    unless TestUp.run_in_console
      # Disable the default reporters as otherwise they'll print lots of data to
      # the console while the test runs. No need for that.
      self.reporter.reporters.clear
      # Add the reporters needed for TestUp.
      self.reporter << TestUp::XmlReporter.new($stdout, options)
    end
  end

end # module Minitest

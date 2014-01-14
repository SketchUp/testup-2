# Copyright:: Copyright 2014 Trimble Navigation Ltd.
# License:: The MIT License (MIT)
# Original Author:: Thomas Thomassen


require File.join(__dir__, 'minitest_setup.rb')


module TestUp
class XmlReporter < MiniTest::StatisticsReporter

  def report
    super
    io.puts separator
    io.puts
    io.puts 'Hello World!'
    io.puts
    io.puts separator
  end

  def separator
    '-' * 40
  end

end # class
end # module TestUp

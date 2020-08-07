# (Assuming current directory is where this file is.)
#
# SketchUp tests:
#   ruby dupes.rb
#
# LayOut tests:
#  ruby dupes.rb ../../../../../layout/ruby/ruby_tests
module TestTools

  TEST_REGEX = /\s*def (test_.+)/

  def self.find_duplicates(test_suite_path)
    test_suite_path = File.expand_path(test_suite_path)
    unless File.directory?(test_suite_path)
      warn "Directory does not exist: #{test_suite_path}"
      return
    end
    pattern = "#{test_suite_path}/TC_*.rb"
    puts "Checking for duplicate tests..."
    Dir.glob(pattern).sort.each { |file|
      # puts File.basename(file)
      methods = []
      content = File.read(file)
      content.each_line.with_index { |line, index|
        matches = line.match(TEST_REGEX)
        next if matches.nil?
        line_number = index + 1
        test_name = matches.captures.first
        methods << [line_number, test_name]
      }
      dupes = methods.select { |line_number, test_name|
        methods.count { |l, t| test_name == t } > 1
      }
      next if dupes.empty?
      dupes.sort! { |a, b|
        # Sort by method name, but for identical names, sort by line number.
        if a[1] == b[1]
          a[0] <=> b[0]
        else
          a[1] <=> b[1]
        end
      }
      puts File.basename(file)
      puts "  Duplicate Tests:"
      dupes.each { |line_number, test_name|
        puts "    #{line_number.to_s.rjust(4)}: #{test_name}"
      }
    }
    puts "Done!"
  end

end

default_path = File.expand_path('..', __dir__)
path = ARGV[0] || default_path
TestTools.find_duplicates(path)

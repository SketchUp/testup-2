#-------------------------------------------------------------------------------
#
# Copyright 2013-2014 Trimble Navigation Ltd.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

if RUBY_PLATFORM =~ /mswin|mingw/
  require "win32/registry"
end


# This is a helper module to quickly switch tests for difference branches for
# the SketchUp Team.
module TestUp
 module Perforce

  def self.get_p4_info
    if RUBY_PLATFORM =~ /mswin|mingw/
      self.get_p4_info_windows
    else
      self.get_p4_info_osx
    end
  end


  def self.get_p4_info_windows
    path = 'Software\Perforce\Environment'
    Win32::Registry::HKEY_CURRENT_USER.open(path) do |reg|
      {
        :p4config => reg["P4CONFIG"],
        :p4user   => reg["P4USER"],
        :p4port   => reg["P4PORT"]
      }
    end
  rescue Win32::Registry::Error => error
    return nil
  end


  def self.get_p4_info_osx
    path = File.expand_path('~/.bash_profile')
    return nil unless File.exist?(path)
    content = File.read(path)
    result = content.match(/^\s*export\s+P4CONFIG\s*=\s*(\S*)\s*$/)
    return nil if result.nil?
    {
      :p4config => result[1]
    }
  #rescue
    #return nil
  end


  # TestUp::Perforce.find_p4_paths
  def self.find_p4_paths
    p4info = self.get_p4_info
    return nil if p4info.nil?

    # Look in the user home directory and computer root.
    search_locations = [File.expand_path("/")]
    if ENV.key?("HOME")
      search_locations << File.expand_path(ENV["HOME"])
    else
      puts "Warning: Missing 'HOME' environment variable."
    end

    # Look for folders with these names for where the clients might be located.
    client_roots = ["src", "source"]

    # Now search for client directories.
    locations = []
    search_locations.each { |location|
      client_roots.each { |client_root|
        filter = "#{location}/#{client_root}/*/#{p4info[:p4config]}"
        matches = Dir.glob(filter).map { |file|
          File.dirname(file)
        }
        locations.concat(matches)
      }
    }
    locations.empty? ? nil : locations
  end


  # TODO(thomthom): Rename to `expected_test_suites`
  def self.expected_tests
    ["SketchUp Ruby API", "Observers 1.0", "Observers 2.0", "Bugs", "Ruby"]
  end


  def self.find_sketchup_tests(client_path)
    tests = File.join(client_path, "src", "googleclient", "sketchup", "source",
      "sketchup", "ruby", "tests")
    return nil unless File.directory?(tests)
    self.expected_tests.map { |test|
      File.join(tests, test)
    }
  end


  # TestUp::Perforce.find_trunk_client
  def self.find_trunk_client
    trunks = self.find_p4_paths.grep(/trunk/i)
    trunks = trunks.grep(/win|pc|mac|osx/i)
    return nil if trunks.size != 1
    trunks[0]
  end


  # TestUp::Perforce.default_sketchup_testsuites
  def self.default_sketchup_testsuites(testup_tests)
    trunk_client = self.find_trunk_client
    # Will be nil if no trunk client was found or there was ambiguity.
    return nil if trunk_client.nil?
    paths = self.find_sketchup_tests(trunk_client)
    return nil if paths.nil?
    # Add the TestUp paths.
    paths << File.join(testup_tests, 'TestUp')
    paths
  end


  def self.replace_sketchup_testsuites(client_path)
    testsuites = self.find_sketchup_tests(client_path)
    return nil if testsuites.nil? || testsuites.empty?
    # Remove the current SketchUp tests.
    other_tests = TestUp.settings[:paths_to_testsuites].reject { |path|
      testsuite_name = File.basename(path)
      self.expected_tests.include?(testsuite_name)
    }
    # Append the new.
    testsuites + other_tests
  end


  # TestUp::Perforce::P4Window.new.show
  class P4Window < SKUI::Window

    attr_reader :result

    def initialize
      options = {
        :title           => "#{PLUGIN_NAME} - Perforce Clients",
        :preferences_key => "#{PLUGIN_ID}_P4",
        :width           => 400,
        :height          => 200,
        :resizable       => false
      }
      super(options)
      init_controls()
    end

    # TODO: Fix this in SKUI.
    # Hack, as SKUI currently doesn't support subclassing of it's controls.
    def typename
      SKUI::Window.to_s.split('::').last
    end

    private

    def init_controls()
      # Test Suite Paths

      paths = TestUp::Perforce.find_p4_paths
      lst_paths = SKUI::Listbox.new(paths)
      lst_paths.name = :paths
      lst_paths.size = 10
      lst_paths.multiple = false
      lst_paths.position(5, 25)
      lst_paths.right = 5
      lst_paths.bottom = 35
      self.add_control(lst_paths)

      lbl_paths = SKUI::Label.new('Perforce Clients:', lst_paths)
      lbl_paths.position(5, 5)
      self.add_control(lbl_paths)

      # Dialog Save and Cancel

      btn_cancel = SKUI::Button.new('Cancel') { |control|
        @result = nil
        control.window.close
      }
      btn_cancel.position(-85, -5)
      self.add_control(btn_cancel)

      btn_save = SKUI::Button.new('Save') { |control|
        client_path = control.window[:paths].value
        @result = TestUp::Perforce.replace_sketchup_testsuites(client_path)
        control.window.close
      }
      btn_save.position(-5, -5)
      self.add_control(btn_save)

      self.cancel_button = btn_cancel
      self.default_button = btn_save
    end

  end # class


 end # Perforce
end # module

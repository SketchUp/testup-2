#-------------------------------------------------------------------------------
#
# Copyright 2013-2014 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------


module TestUp

  # TODO(thomthom): Split this file into smaller files.

  module Debug

    module Timing

      def time(title = '', &block)
        start = Time.now
        result = block.call
        lapsed_time = Time.now - start
        Log.debug "Timing #{title}: #{lapsed_time}s"
        result
      end

    end # module

  end # module


  module Debugger

    # TestUp::Debugger.attached?
    def self.attached?
      require 'Win32API'
      @IsDebuggerPresent ||=
        Win32API.new('kernel32', 'IsDebuggerPresent', 'V', 'I')
      @IsDebuggerPresent.call == 1
    end

    # TestUp::Debugger.break
    def self.break
      if self.attached?
        require 'Win32API'
        @DebugBreak ||=
          Win32API.new('kernel32', 'DebugBreak', 'V', 'V')
        @DebugBreak.call
      else
        # SketchUp crashes without BugSplat or triggering a debugger if none is
        # attached.
        false
      end
    end

    # TestUp::Debugger.output
    def self.output(value)
      return nil unless TestUp.settings[:debugger_output_enabled]
      require 'Win32API'
      @OutputDebugString ||=
        Win32API.new('kernel32', 'OutputDebugString', 'P', 'V')
      @OutputDebugString.call("#{value}\n\0")
    end

    def self.debugger_output?
      TestUp.settings[:debugger_output_enabled]
    end

    # TestUp::Debugger.debugger_output = true
    def self.debugger_output=(value)
      TestUp.settings[:debugger_output_enabled] = value ? true : false
    end

    def self.time(title, &block)
      start = Time.now
      block.call
    ensure
      lapsed_time = Time.now - start
      self.output("TestUp::Debugger.time: #{title} #{lapsed_time}s")
      nil
    end

  end # module Debugger

  # Calling IsDebuggerPresent doesn't appear to detect the Script Debugger.
  # As a workaround to avoid the break in window.onerror we keep track of this
  # flag for the session. It will be incorrect if debugging is cancelled.
  module ScriptDebugger

    # TestUp::ScriptDebugger.attached?
    def self.attached?
      @attached ||= false
      @attached
    end

    def self.attach
      @attached = true
    end

  end # module Debug


  def self.display_minitest_help
    TESTUP_CONSOLE.show
    MiniTest.run(['--help'])
  rescue SystemExit
  end

  # TestUp.reload
  def self.reload
    original_verbose = $VERBOSE
    $VERBOSE = nil
    filter = File.join(PATH, '**/*.{rb,rbs}')
    files = Dir.glob(filter).each { |file|
      load file
    }
    @window_vue = nil
    files.length
  ensure
    $VERBOSE = original_verbose
  end

end # module

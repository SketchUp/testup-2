#-------------------------------------------------------------------------------
#
# Copyright 2014, Trimble Navigation Limited
#
# This software is provided as an example of using the Ruby interface
# to SketchUp.
#
# Permission to use, copy, modify, and distribute this software for
# any purpose and without fee is hereby granted, provided that the above
# copyright notice appear in all copies.
#
# THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
#
#-------------------------------------------------------------------------------

module TestUp

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
      require 'Win32API'
      @OutputDebugString ||=
        Win32API.new('kernel32', 'OutputDebugString', 'P', 'V')
      @OutputDebugString.call("#{value}\0")
    end

  end # module Debug

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
    SKETCHUP_CONSOLE.show
    MiniTest.run(['--help'])
  rescue SystemExit
  end

  # TestUp.reload
  def self.reload
    original_verbose = $VERBOSE
    $VERBOSE = nil
    filter = File.join(PATH, '*.{rb,rbs}')
    files = Dir.glob(filter).each { |file|
      load file
    }
    files.length
  ensure
    $VERBOSE = original_verbose
  end

end # module

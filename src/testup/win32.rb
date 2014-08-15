#-------------------------------------------------------------------------------
#
# Copyright 2013-2014 Trimble Navigation Ltd.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------


require 'fiddle'
require 'fiddle/types'
require 'fiddle/import'


module TestUp
 module Win32

  include Fiddle

  FALSE = 0
  TRUE  = 1


  module Kernel32
    extend Fiddle::Importer
    dlload 'kernel32.dll'
    include Fiddle::Win32Types
    extern 'DWORD GetCurrentThreadId()'
  end


  # http://msdn.microsoft.com/en-us/library/ms633502%28v=vs.85%29.aspx
  GA_PARENT     = 1
  GA_ROOT       = 2
  GA_ROOTOWNER  = 3
  module User32
    extend Fiddle::Importer
    dlload 'user32.dll'
    include Fiddle::Win32Types
    extern 'HWND GetAncestor(HWND, UINT)'
    #extern 'BOOL EnumThreadWindows(DWORD, WNDENUMPROC, LPARAM)'
    extern 'BOOL EnumThreadWindows(DWORD, PVOID, PVOID)'
  end


  # TestUp::Win32.get_main_window_handle
  #
  # Returns the window handle of the SketchUp window for the input queue of the
  # calling ruby method.
  #
  # @return [Integer] Returns a window handle on success or +nil+ on failure
  def self.get_main_window_handle
    thread_id = Kernel32.GetCurrentThreadId()
    main_hwnd = 0
    param = 0

    enumWindowsProc = Closure::BlockCaller.new(TYPE_INT,
      [TYPE_VOIDP, TYPE_VOIDP]) { |hwnd, lparam|
        main_hwnd = User32.GetAncestor(hwnd, GA_ROOTOWNER)
        next FALSE
    }

    User32.EnumThreadWindows(thread_id, enumWindowsProc, param)
    main_hwnd
  end

 end # module Win32
end # module TestUp

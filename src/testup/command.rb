module TestUp
# It's not possible to subclass UI::Command as the subclass's #new will
# return a UI::Command object. So instead this module is used that will extend
# the instance created with it's #create method.
#
# @example
#   cmd = Command.create('Hello World') {
#     Extension.hello_world
#   }
#   cmd.icon = 'path_to_icon/icon_base_name'
#   cmd.tooltip = 'Hello Tooltip'
#   cmd.status_bar_text = 'Everything else a UI::Command does.'
module Command

  PLATFORM_OSX = Sketchup.platform == :platform_osx

  # SketchUp allocate the object by implementing `new` - probably part of
  # older legacy implementation when that was the norm. Because of that the
  # class cannot be sub-classed directly. This module simulates the interface
  # for how UI::Command is created. `new` will create an instance of
  # UI::Command but mix itself into the instance - effectively subclassing it.
  # (yuck!)
  def self.new(title, &block)
    command = UI::Command.new(title) {
      begin
        block.call
      rescue Exception => exception
        ERROR_REPORTER.handle(exception)
      end
    }
    command.extend(self)
    command
  end

  # @param [String] basename Filename without file extension and size postfix.
  def icon=(basename)
    small_icon_file = "#{basename}-16.png"
    large_icon_file = "#{basename}-24.png"
    if Sketchup.version.to_i > 15
      extension = PLATFORM_OSX ? 'pdf' : 'svg'
      small_icon = "#{basename}.#{extension}"
      large_icon = "#{basename}.#{extension}"
      small_icon_file = small_icon if File.exist?(small_icon)
      large_icon_file = large_icon if File.exist?(large_icon)
    end
    self.small_icon = small_icon_file
    self.large_icon = large_icon_file
  end

end # module Command
end # module

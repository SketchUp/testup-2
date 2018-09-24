module Inkscape

  PROGRAM_FILES = File.expand_path(ENV['PROGRAMW6432'])

  INKSCAPE_PATH = File.join(PROGRAM_FILES, 'Inkscape')
  INKSCAPE = File.join(INKSCAPE_PATH, 'inkscape.exe')

  # puts "Inkscape: #{INKSCAPE} (#{File.exist?(INKSCAPE)})"

  def self.convert_svg_to_pdf(input, output)
    svg_filename = self.normalise_path(input)
    pdf_filename = self.normalise_path(output)
    arguments = %(-f "#{svg_filename}" -A "#{pdf_filename}")
    self.command(arguments)
  end

  def self.convert_svg_to_png(input, output, size)
    svg_filename = self.normalise_path(input)
    png_filename = self.normalise_path(output)
    arguments = %(-f "#{svg_filename}" -e "#{png_filename}" -w #{size} -h #{size})
    self.command(arguments)
  end

  def self.normalise_path(path)
    path.tr('/', '\\')
  end

  def self.command(arguments)
    inkscape = self.normalise_path(INKSCAPE)
    command = %("#{inkscape}" #{arguments})
    puts command
    # puts `#{command}`
    system(command)
    # id = spawn(command)
    # Process.detach(id)
  end

end # module

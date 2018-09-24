require 'colorize'
require 'fileutils'
require_relative 'lib/inkscape'

class Build < Skippy::Command

  IS_MAC = RUBY_PLATFORM.include?('darwin')

  desc 'images', 'Generates PNG and PDF versions of original SVG icon sources.'
  def images
    Dir.glob("#{extension_image_path}/*.svg") { |svg_file|
      base_svg = File.basename(svg_file)
      basename = File.basename(svg_file, '.*')
      puts base_svg
      # Generate PDF versions for Mac.
      base_pdf = "#{basename}.pdf"
      pdf_file = File.join(extension_image_path, base_pdf)
      puts "> #{base_svg} => #{base_pdf}".green
      Inkscape.convert_svg_to_pdf(svg_file, pdf_file).inspect.yellow
      # Generate PNG versions for SU2015 and older.
      png_small = File.join(extension_image_path, "#{basename}-16.png")
      png_large = File.join(extension_image_path, "#{basename}-24.png")
      puts "> #{base_svg} => #{png_small}".green
      Inkscape.convert_svg_to_png(svg_file, png_small, 16).inspect.yellow
      puts "> #{base_svg} => #{png_large}".green
      Inkscape.convert_svg_to_png(svg_file, png_large, 24).inspect.yellow
    }
  end

  desc 'webdialogs', 'Build webdialog content.'
  def webdialogs
    run('npm run build')
  end

  private

  # TODO: Move these paths into a reusable file.

  def solution_path
    File.expand_path('../..', __dir__)
  end

  def ruby_source_path
    File.join(solution_path, 'src')
  end

  def extension_support_path
    File.join(ruby_source_path, 'testup')
  end

  def extension_image_path
    File.join(extension_support_path, 'images')
  end

end

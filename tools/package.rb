#!/usr/bin/env ruby

begin

require "fileutils"
require "pathname"
require "zip"

require_relative 'lib/extension'

### Configure Paths ############################################################

project_root = File.expand_path('..', __dir__)

ruby_source_path = File.join(project_root, "src")
ruby_source_pathname = Pathname.new(ruby_source_path)

build_path = File.join(project_root, "build")
build_pathname = Pathname.new(build_path)

archive_path = File.join(project_root, "archive")
FileUtils.mkdir_p(archive_path)


### Configure Files ############################################################

extension = Extension.read_info(ruby_source_path)

extension_name = extension[:name]
puts "Extension Name: #{extension_name}"

extension_id = extension[:product_id]

version = extension[:version]
puts "Version: #{version}"

# Useful for stuff like git sha.
# ruby tools/package 02f5d6
postfix = ARGV[0] ? "-#{ARGV[0]}" : ''


build_version = version
build_date = Time.now.strftime("%Y-%m-%d")

archive_name = "#{extension_id}_#{build_version}_#{build_date}#{postfix}"
archive = File.join(archive_path, "#{archive_name}.rbz")

build_files_pattern = File.join(build_path, "**", "**")


### Create Build Directory #####################################################

puts "Creating build directory..."

puts "> Removing old build directory..."
p FileUtils.rm_rf(build_path)

# puts "Removing transient binaries..."
# source_libraries = File.join(ruby_source_path, extension_id, "libraries")
# pattern = File.join(source_libraries, "[0-9]*")
# Dir.glob(pattern) { |path|
#   p FileUtils.rm_rf(path)
# }

puts "> Copy source to build directory..."
source = File.join(ruby_source_path, ".") # Copy the content - not the folder.
p FileUtils.cp_r(source, build_path)

puts "> Removing unwanted system cache files..."
unwanted_files = Dir.glob("#{build_path}/**/Thumbs.db")
p FileUtils.remove(unwanted_files)


### Verify Source ##############################################################

# TODO (?)
# * Check that dialogs have been built.

### Build Source ###############################################################

# TODO (?)
# * Build binary source.
# * Copy binaries to build directory.
# * Clean libraries folder in build directory.


### Package ####################################################################

puts "Creating RBZ archive..."
puts "Source: #{build_path}"
puts "Destination: #{archive}"

if File.exist?(archive)
  puts "Archive already exist. Deleting existing archive."
  File.delete(archive)
end

Zip::File.open(archive, Zip::File::CREATE) do |zipfile|
  build_files = Dir.glob(build_files_pattern)
  build_files.each { |file_item|
    next if File.directory?(file_item)
    pathname = Pathname.new(file_item)
    relative_name = pathname.relative_path_from(build_pathname)
    puts "Archiving: #{relative_name}"
    zipfile.add(relative_name, file_item)
  }
end

puts "Packing done!"
puts "#{archive}"


### Pause at End ###############################################################

rescue => error

p error
puts "\tfrom #{error.backtrace.join("\n\tfrom ")}"

ensure

#puts "Press any key to continue..."
#gets

end

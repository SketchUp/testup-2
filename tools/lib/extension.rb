require 'json'

module Extension

  # @param [String] source_path
  # @return [Hash]
  def self.read_info(source_path)
    pattern = File.join(source_path, '*.rb')
    root_rb = Dir.glob(pattern).to_a.first
    basename = File.basename(root_rb, '.*')
    support_folder = File.join(source_path, basename)
    json_file = File.join(support_folder, 'extension.json')
    extension_json = File.read(json_file, :encoding => 'utf-8')
    JSON.parse(extension_json, symbolize_names: true)
  end

end # module

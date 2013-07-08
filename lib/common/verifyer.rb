module Verifyer
  def run
    fail "type must be set in class that includes mixin" unless @type
    results = {}
    get_files_from(@location).each do |manifest|
      manifest_key = @location == manifest ? manifest : manifest.gsub(@location, "")
      results[manifest_key] = {}
      results[manifest_key][@type] = execute manifest
    end
    results
  end

  def get_files_from location
    return Locater.find_all_manifests(location) if File.directory?(location)
    return [location] if File.file? location
    raise "Given location does not exist"
  end
end
